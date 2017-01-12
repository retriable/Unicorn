//
//  UnicornDatabase.h
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.

#import <Foundation/Foundation.h>
#import "UnicornBlockValueTransformer.h"
#import <sqlite3.h>

extern NSString *const UnicornDatabaseErrorDomain;

typedef NS_ENUM (NSInteger, UnicornDatabaseColumnType) {
    UnicornDatabaseColumnTypeUnknow,
    UnicornDatabaseColumnTypeText,
    UnicornDatabaseColumnTypeInteger,
    UnicornDatabaseColumnTypeReal,
    UnicornDatabaseColumnTypeBlob
};

@interface UnicornDatabaseTransformer : NSObject

@property (nonatomic, strong, readonly) UnicornBlockValueTransformer *valueTransformer;
@property (nonatomic, assign, readonly) UnicornDatabaseColumnType columnType;

+ (UnicornBlockValueTransformer *)transformerWithValueTransformer:(UnicornBlockValueTransformer *)valueTransformer columnType:(UnicornDatabaseColumnType)columnType;

@end

@interface UnicornDatabase : NSObject

+ (instancetype)databaseWithFile:(NSString *)file error:(NSError * *)error;

- (void)sync:(void (^)(UnicornDatabase *db))block;

- (void)async:(void (^)(UnicornDatabase *db))block;

- (BOOL)executeUpdate:(NSString *)sql arguments:(NSArray *)arguments error:(NSError **)error;

- (BOOL)executeUpdate:(NSString *)sql stmtBlock:(void (^)(sqlite3_stmt *stmt, int idx))stmtBlock error:(NSError * *)error;

- (void)executeQuery:(NSString *)sql arguments:(NSArray *)arguments resultBlock:(void (^)(sqlite3_stmt *stmt, bool *stop))resultBlock error:(NSError **)error;

- (void)executeQuery:(NSString *)sql stmtBlock:(void (^)(sqlite3_stmt *stmt, int idx))stmtBlock resultBlock:(void (^)(sqlite3_stmt *stmt, bool *stop))resultBlock error:(NSError **)error;

- (NSArray *)executeQuery:(NSString *)sql stmtBlock:(void (^)(sqlite3_stmt *stmt, int idx))stmtBlock error:(NSError **)error;

- (NSArray *)executeQuery:(NSString *)sql arguments:(NSArray *)arguments error:(NSError **)error;

- (BOOL)beginTransaction;

- (BOOL)commit;

@end
