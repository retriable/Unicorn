//
//  UnicornDatabase.m
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.


#import "UnicornDatabase.h"

NSString *const UnicornDatabaseErrorDomain = @"UnicornDatabaseErrorDomain";

#ifndef UNI_DB_LOG
#define UNI_DB_LOG(code) _log(__LINE__, code, sqlite3_errmsg(self.db))
#endif

static inline int _log(int line, int code, const char *desc) {
#ifdef DEBUG
    if (code != SQLITE_DONE && code != SQLITE_OK && code != SQLITE_ROW) {
        NSLog(@"[file:%s][line:%d] [code:%d,desc:%s]", __FILE__, line, code, desc);
    }
#endif
    return code;
}



@interface UnicornDatabaseTransformer ()

@property (nonatomic, strong) UnicornBlockValueTransformer *valueTransformer;
@property (nonatomic, assign) UnicornDatabaseColumnType columnType;

@end

@implementation UnicornDatabaseTransformer

+ (UnicornDatabaseTransformer *)transformerWithValueTransformer:(UnicornBlockValueTransformer *)valueTransformer columnType:(UnicornDatabaseColumnType)columnType {
    UnicornDatabaseTransformer *transformer = [[UnicornDatabaseTransformer alloc] init];
    transformer.valueTransformer = valueTransformer;
    transformer.columnType = columnType;
    return transformer;
}

@end

@interface UnicornStmt : NSObject

@property (nonatomic, assign) sqlite3_stmt *stmt;
@property (nonatomic, copy) NSString *sql;

@end

@implementation UnicornStmt

- (void)dealloc {
    if (self.stmt) {
        sqlite3_finalize(self.stmt);
    }
}

@end

@interface UnicornDatabase ()

@property (nonatomic, assign) sqlite3 *db;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) void *queueKey;
@property (nonatomic, assign) UInt64 transactionReferenceCount;
@property (nonatomic, strong) NSMutableDictionary *stmts;

@end

@implementation UnicornDatabase

- (void)sync:(void (^)(UnicornDatabase *db))block {
    if (dispatch_get_specific(self.queueKey)) {
        block(self);
    } else {
        dispatch_sync(self.queue, ^{
            block(self);
        });
    }
}

- (void)async:(void (^)(UnicornDatabase *db))block {
    if (dispatch_get_specific(self.queueKey)) {
        block(self);
    } else {
        dispatch_async(self.queue, ^{
            block(self);
        });
    }
}

- (void)dealloc {
    [self removeAllStmt];
    [self close];
}

+ (instancetype)databaseWithFile:(NSString *)file error:(NSError * *)error {
    UnicornDatabase *database = [[self alloc] init];
    return [database open:file error:error] ? database : nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.transactionReferenceCount = 0;
        self.queue = dispatch_queue_create("UnicornDatabase", NULL);
        self.queueKey = &_queueKey;
        dispatch_queue_set_specific(self.queue, self.queueKey, (__bridge void *)self, NULL);
        self.stmts = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark--
#pragma mark-- open and close

- (BOOL)open:(NSString *)file error:(NSError * *)error {
    sqlite3 *db;
    if (UNI_DB_LOG(sqlite3_open([file cStringUsingEncoding:NSUTF8StringEncoding], &db)) != SQLITE_OK) {
        if (error) {
            *error = [self error];
        }
        return NO;
    }
    self.db = db;
    return YES;
}

- (BOOL)close {
    if (self.db) {
        if (UNI_DB_LOG(sqlite3_close(self.db)) != SQLITE_OK) {
            return NO;
        }
        self.db = nil;
    }
    return YES;
}

#pragma mark--
#pragma mark-- stmt

- (sqlite3_stmt *)stmtForSql:(NSString *)sql error:(NSError * *)error {
    UnicornStmt *s = self.stmts[sql];
    if (!s) {
        sqlite3_stmt *stmt = NULL;
        if (UNI_DB_LOG(sqlite3_prepare_v2(self.db, [sql UTF8String], -1, &stmt, 0)) != SQLITE_OK) {
            sqlite3_finalize(stmt);
            if (error) {
                *error = [self error];
            }
            return NULL;
        }
        s = [[UnicornStmt alloc] init];
        s.stmt = stmt;
        s.sql = sql;
        self.stmts[sql] = s;
    }
    UNI_DB_LOG(sqlite3_reset(s.stmt));
    UNI_DB_LOG(sqlite3_clear_bindings(s.stmt));
    return s.stmt;
}

- (void)removeStmtForSql:(NSString *)sql {
    [self.stmts removeObjectForKey:sql];
}

- (void)removeAllStmt {
    [self.stmts removeAllObjects];
}

#pragma mark--
#pragma mark-- query

- (NSArray *)executeQuery:(NSString *)sql arguments:(NSArray *)arguments error:(NSError * *)error {
    return [self executeQuery:sql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
        [self _bindObject:arguments[idx - 1] toColumn:idx inStatement:stmt];
    } error:error];
}

- (NSArray *)executeQuery:(NSString *)sql stmtBlock:(void (^)(sqlite3_stmt *stmt, int idx))stmtBlock error:(NSError * *)error {
    __block NSMutableArray *array = [NSMutableArray array];
    [self executeQuery:sql stmtBlock:stmtBlock resultBlock:^(sqlite3_stmt *stmt, bool *stop) {
        int count = sqlite3_data_count(stmt);
        NSDictionary *dictionary = [self _dictionaryInStmt:stmt count:count];
        if (dictionary.count > 0) {
            [array addObject:dictionary];
        }
    } error:error];
    return array;
}

- (void)executeQuery:(NSString *)sql arguments:(NSArray *)arguments resultBlock:(void (^)(sqlite3_stmt *stmt, bool *stop))resultBlock error:(NSError * *)error {
    [self executeQuery:sql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
        [self _bindObject:arguments[idx-1] toColumn:idx inStatement:stmt];
    } resultBlock:resultBlock error:error];
}

- (void)executeQuery:(NSString *)sql stmtBlock:(void (^)(sqlite3_stmt *stmt, int idx))stmtBlock resultBlock:(void (^)(sqlite3_stmt *stmt, bool *stop))resultBlock error:(NSError * *)error {
    NSParameterAssert(stmtBlock);
    NSParameterAssert(resultBlock);
    sqlite3_stmt *stmt = [self stmtForSql:sql error:error];
    if (!stmt) {
        return;
    }
    int count = sqlite3_bind_parameter_count(stmt);
    for (int i = 0; i < count; i++) {
        stmtBlock(stmt, i + 1);
    }
    bool stop = NO;
    while (UNI_DB_LOG(sqlite3_step(stmt)) == SQLITE_ROW) {
        resultBlock(stmt, &stop);
        if (stop) {
            return;
        }
    }
}

#pragma mark--
#pragma mark-- update

- (BOOL)executeUpdate:(NSString *)sql arguments:(NSArray *)arguments error:(NSError * *)error {
    return [self executeUpdate:sql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
        [self _bindObject:arguments[idx-1] toColumn:idx inStatement:stmt];
    } error:error];
}

- (BOOL)executeUpdate:(NSString *)sql stmtBlock:(void (^)(sqlite3_stmt *stmt, int idx))stmtBlock error:(NSError * *)error {
    sqlite3_stmt *stmt = [self stmtForSql:sql error:error];
    if (!stmt) {
        if (error) {
            *error = [self error];
        }
        return NO;
    }
    int count = sqlite3_bind_parameter_count(stmt);
    for (int i = 0; i < count; i++) {
        stmtBlock(stmt, i + 1);
    }
    if (UNI_DB_LOG(sqlite3_step(stmt)) != SQLITE_DONE) {
        if (error) {
            *error = [self error];
        }
        return NO;
    }
    return YES;
}

#pragma mark--
#pragma mark--transaction

- (BOOL)beginTransaction {
    self.transactionReferenceCount++;
    if (self.transactionReferenceCount == 1) {
        return [self executeUpdate:@"BEGIN" arguments:nil error:nil];
    }
    return YES;
}

- (BOOL)commit {
    if (self.transactionReferenceCount > 0) {
        self.transactionReferenceCount--;
        if (self.transactionReferenceCount == 0) {
            return [self executeUpdate:@"COMMIT" arguments:nil error:nil];
        }
    }
    return YES;
}

#pragma mark--
#pragma mark-- bind object to column

- (void)_bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)stmt {
    int result = SQLITE_OK;
    if ((!obj) || obj == (id)kCFNull) {
        result = sqlite3_bind_null(stmt, idx);
    } else if ([obj isKindOfClass:NSNumber.class]) {
        if (strcmp([obj objCType], @encode(char)) == 0) {
            result = sqlite3_bind_int(stmt, idx, [obj charValue]);
        } else if (strcmp([obj objCType], @encode(unsigned char)) == 0) {
            result = sqlite3_bind_int(stmt, idx, [obj unsignedCharValue]);
        } else if (strcmp([obj objCType], @encode(short)) == 0) {
            result = sqlite3_bind_int(stmt, idx, [obj shortValue]);
        } else if (strcmp([obj objCType], @encode(unsigned short)) == 0) {
            result = sqlite3_bind_int(stmt, idx, [obj unsignedShortValue]);
        } else if (strcmp([obj objCType], @encode(int)) == 0) {
            result = sqlite3_bind_int(stmt, idx, [obj intValue]);
        } else if (strcmp([obj objCType], @encode(unsigned int)) == 0) {
            result = sqlite3_bind_int64(stmt, idx, (long long)[obj unsignedIntValue]);
        } else if (strcmp([obj objCType], @encode(long)) == 0) {
            result = sqlite3_bind_int64(stmt, idx, [obj longValue]);
        } else if (strcmp([obj objCType], @encode(unsigned long)) == 0) {
            result = sqlite3_bind_int64(stmt, idx, (long long)[obj unsignedLongValue]);
        } else if (strcmp([obj objCType], @encode(long long)) == 0) {
            result = sqlite3_bind_int64(stmt, idx, [obj longLongValue]);
        } else if (strcmp([obj objCType], @encode(unsigned long long)) == 0) {
            result = sqlite3_bind_int64(stmt, idx, (long long)[obj unsignedLongLongValue]);
        } else if (strcmp([obj objCType], @encode(float)) == 0) {
            result = sqlite3_bind_double(stmt, idx, [obj floatValue]);
        } else if (strcmp([obj objCType], @encode(double)) == 0) {
            result = sqlite3_bind_double(stmt, idx, [obj doubleValue]);
        } else if (strcmp([obj objCType], @encode(bool)) == 0) {
            result = sqlite3_bind_int(stmt, idx, ([obj boolValue] ? 1 : 0));
        } else {
            result = sqlite3_bind_text(stmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
        }
    } else if ([obj isKindOfClass:NSData.class]) {
        const void *bytes = [obj bytes];
        if (bytes) {
            result = sqlite3_bind_blob(stmt, idx, bytes, (int)[obj length], SQLITE_STATIC);
        } else {
            result = sqlite3_bind_null(stmt, idx);
        }
    } else {
        result = sqlite3_bind_text(stmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
    }
    UNI_DB_LOG(result);
}

#pragma mark--
#pragma mark-- getter

- (NSDictionary *)_dictionaryInStmt:(sqlite3_stmt *)stmt count:(int)count {
    NSMutableDictionary *set = [NSMutableDictionary dictionary];
    for (int idx = 0; idx < count; idx++) {
        NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(stmt, idx)];
        int type = sqlite3_column_type(stmt, idx);
        id value = nil;
        switch (type) {
            case SQLITE_INTEGER:
                value = @(sqlite3_column_int64(stmt, idx));
                break;
            case SQLITE_FLOAT:
                value = @(sqlite3_column_double(stmt, idx));
                break;

            case SQLITE_BLOB:
            {
                int bytes = sqlite3_column_bytes(stmt, idx);
                value = [NSData dataWithBytes:sqlite3_column_blob(stmt, idx) length:bytes];
            }
            break;
            case SQLITE_NULL:
                break;
            default:
                value = [[NSString alloc] initWithCString:(const char *)sqlite3_column_text(stmt, idx) encoding:NSUTF8StringEncoding];
                break;
        }
        if (value && value != (id)kCFNull) {
            set[columnName] = value;
        }
    }
    return set;
}

- (NSError *)error {
    return [NSError errorWithDomain:NSStringFromClass(self.class) code:sqlite3_errcode(self.db) userInfo:@{NSLocalizedDescriptionKey:[[NSString alloc] initWithCString:sqlite3_errmsg(self.db) encoding:NSUTF8StringEncoding]}];
}

@end
