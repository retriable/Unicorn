//
//  UnicornInfo.m
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.


#import "UnicornModelInfo.h"
#import "UnicornFuctions.h"

typedef NS_ENUM (NSInteger, UnicornPropertyPropertyType) {
    UnicornPropertyPropertyTypeUnknow = 0,
    UnicornPropertyPropertyTypeNonatomic = 1 << 0,
    UnicornPropertyPropertyTypeDynamic = 1 << 1,
    UnicornPropertyPropertyTypeReadonly = 1 << 2
};

static UnicornDatabase *global_database = nil;

NSString *const uni_on_update_timestamp = @"uni_on_update_timestamp";

static inline bool uni_db_check_table(UnicornDatabase *db, NSString *table){
    NSString *sql = @"SELECT * FROM sqlite_master WHERE tbl_name=? AND type='table'";
    NSArray *sets = [db executeQuery:sql arguments:@[table] error:nil];
    if (sets.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

static inline bool uni_db_check_column(UnicornDatabase *db, NSString *table, NSString *column){
    BOOL ret = NO;
    NSString *sql = @"SELECT * FROM sqlite_master WHERE tbl_name=? AND type='table'";
    NSArray *sets = [db executeQuery:sql arguments:@[table] error:nil];
    column = [NSString stringWithFormat:@"'%@'", column];
    if (sets.count > 0) {
        for (NSDictionary *set in sets) {
            NSString *createSql = set[@"sql"];
            if (createSql &&
                [createSql rangeOfString:column].location != NSNotFound) {
                ret = YES;
                break;
            }
        }
    }
    return ret;
}

static inline bool uni_check_index(UnicornDatabase *db, NSString *table, NSString *index){
    __block BOOL ret = NO;
    NSString *sql = @"SELECT * FROM sqlite_master WHERE tbl_name=? AND type='index'";
    NSArray *sets = [db executeQuery:sql arguments:@[table] error:nil];
    index = [NSString stringWithFormat:@"(%@)", index];
    if (sets.count > 0) {
        for (NSDictionary *set in sets) {
            NSString *createSql = set[@"sql"];
            if (createSql && [createSql rangeOfString:index].location != NSNotFound) {
                ret = YES;
                break;
            }
        }
    }
    return ret;
}

static inline void uni_db_add_table(UnicornClassInfo *classInfo, UnicornDatabase *db){
    NSString *table = classInfo.className;
    if (!uni_db_check_table(db, table)) {
        NSString *uniquePropertyName = classInfo.mtUniquePropertyInfo.propertyName;
        UNPropertyInfo *propertyInfo = classInfo.propertyInfosByPropertyName[uniquePropertyName];
        NSString *uniqueDbColumn = propertyInfo.propertyName;
        NSString *uniqueDbColumnType = uni_sql_column_text(propertyInfo.dbColumnType);
        NSString *sql = nil;
#ifdef uni_DB_AUTO_UPDATE_TIMESTAMP
        sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'%@' %@ NOT NULL UNIQUE,'%@' REAL)", table, uniqueDbColumn, uniqueDbColumnType, uni_on_update_timestamp];
#else
        sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'%@' %@ NOT NULL UNIQUE)", table, uniqueDbColumn, uniqueDbColumnType];
#endif

        [db executeUpdate:sql arguments:nil error:nil];
    }
}

static inline void uni_db_add_column(UnicornClassInfo *classInfo, UnicornDatabase *db){
    NSString *table = classInfo.className;
    [classInfo.dbPropertyInfos enumerateObjectsUsingBlock:^(UNPropertyInfo *_Nonnull propertyInfo, NSUInteger idx, BOOL *_Nonnull stop) {
        if (propertyInfo == classInfo.mtUniquePropertyInfo) {
            return;
        }
        NSString *column = propertyInfo.propertyName;
        if (!uni_db_check_column(db, table, column)) {
            NSString *dbColumnType = uni_sql_column_text(propertyInfo.dbColumnType);
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE '%@' ADD COLUMN '%@' %@", table, column, dbColumnType];
            [db executeUpdate:sql arguments:nil error:nil];
        }
    }];
}

static inline void uni_db_add_indexes(UnicornClassInfo *classInfo, UnicornDatabase *db){
    NSMutableArray *indexes = [NSMutableArray array];
    [classInfo.dbIndexes enumerateObjectsUsingBlock:^(NSString *_Nonnull propertyName, NSUInteger idx, BOOL *_Nonnull stop) {
        [indexes addObject:propertyName];
    }];
#ifdef uni_DB_AUTO_UPDATE_TIMESTAMP
    [indexes addObject:uni_on_update_timestamp];
#endif
    [indexes enumerateObjectsUsingBlock:^(NSString *_Nonnull databaseIndex, NSUInteger idx, BOOL *_Nonnull stop) {
        if (!uni_check_index(db, classInfo.className, databaseIndex)) {
            NSString *index = [NSString stringWithFormat:@"%@_%@_index", classInfo.className, databaseIndex];
            NSString *sql = [NSString stringWithFormat:@"CREATE INDEX %@ on %@(%@)", index, classInfo.className, databaseIndex];
            [db executeUpdate:sql arguments:nil error:nil];
        }
    }];
}

static inline void  uni_db_create(UnicornClassInfo *classInfo, UnicornDatabase *db){
    uni_db_add_table(classInfo, db);
    uni_db_add_column(classInfo, db);
    uni_db_add_indexes(classInfo, db);
}

@interface UnicornClassInfo ()

@property (nonatomic, assign) Class cls;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSDictionary *propertyInfosByPropertyName;
@property (nonatomic, strong) NSArray *propertyNames;
@property (nonatomic, strong) NSArray *propertyInfos;

@property (nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, strong) UnicornMapTable *mt;
@property (nonatomic, copy) NSString *mtUniquePropertyName;
@property (nonatomic, strong) UNPropertyInfo *mtUniquePropertyInfo;

@property (nonatomic, strong) UnicornDatabase *db;
@property (nonatomic, strong) NSArray *dbPropertyInfos;
@property (nonatomic, strong) NSArray *dbIndexes;
@property (nonatomic, copy) NSString *dbSelectSql;
@property (nonatomic, copy) NSString *dbUpdateSql;
@property (nonatomic, copy) NSString *dbInsertSql;

@property (nonatomic, strong) NSArray *jsonPropertyInfos;
@end

@interface UNPropertyInfo ()

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *ivarName;
@property (nonatomic, assign) Class cls;
@property (nonatomic, assign) Class parentClass;
@property (nonatomic, assign) UnicornPropertyEncodingType encodingType;
@property (nonatomic, assign) SEL setter;
@property (nonatomic, assign) SEL getter;
@property (nonatomic, assign) bool isConformingToUnicornJSONModel;
@property (nonatomic, assign) bool isConformingToUnicornMT;
@property (nonatomic, assign) bool isConformingToUnicornDB;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@property (nonatomic, assign) UnicornDatabaseColumnType dbColumnType;
@property (nonatomic, assign) UnicornBlockValueTransformer *dbValueTransformer;

@property (nonatomic, strong) NSString *jsonKeyPathInString;
@property (nonatomic, strong) NSArray *jsonKeyPathInArray;
@property (nonatomic, strong) NSValueTransformer *jsonValueTransformer;

@end

@implementation UnicornClassInfo

- (instancetype)initWithClass:(Class)cls {
    self = [self init];
    if (self) {
        self.cls = cls;
        self.className = NSStringFromClass(cls);
        self.lock = [[NSRecursiveLock alloc] init];
        NSMutableDictionary *propertyInfosByPropertyName = [NSMutableDictionary dictionary];
        [self enumeratePropertiesUsingBlock:^(objc_property_t property) {
            UNPropertyInfo *propertyInfo = [[UNPropertyInfo alloc] initWithProperty:property parentClass:cls];
            [propertyInfosByPropertyName setObject:propertyInfo forKey:propertyInfo.propertyName];
        }];
        self.propertyInfosByPropertyName = [propertyInfosByPropertyName copy];
        self.propertyNames = [self.propertyInfosByPropertyName allKeys];
        self.propertyInfos = [self.propertyInfosByPropertyName allValues];
        if ([cls conformsToProtocol:@protocol(UnicornJSON)]) {
            NSMutableArray *jsonPropertyInfos = [NSMutableArray array];
            [[cls uni_jsonKeyPathsByPropertyName] enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull propertyName, NSString *_Nonnull jsonKeyPath, BOOL *_Nonnull stop) {
                UNPropertyInfo *propertyInfo = self.propertyInfosByPropertyName[propertyName];
                propertyInfo.jsonKeyPathInString = jsonKeyPath;
                propertyInfo.jsonKeyPathInArray = [jsonKeyPath componentsSeparatedByString:@"."];
                [jsonPropertyInfos addObject:propertyInfo];
                if ([cls respondsToSelector:@selector(uni_jsonValueTransformerForPropertyName:)]) {
                    propertyInfo.jsonValueTransformer = [cls uni_jsonValueTransformerForPropertyName:propertyName];
                }
            }];
            self.jsonPropertyInfos = jsonPropertyInfos;
        }
        if ([cls conformsToProtocol:@protocol(UnicornMT)]) {
            self.mtUniquePropertyName = [self.cls uni_mtUniquePropertyName];
            self.mtUniquePropertyInfo = self.propertyInfosByPropertyName[self.mtUniquePropertyName];
            UNPropertyInfo *mtUniquePropertyInfo = self.propertyInfosByPropertyName[self.mtUniquePropertyName];
            NSAssert(mtUniquePropertyInfo && (mtUniquePropertyInfo.encodingType & UnicornPropertyEncodingTypeSupportedCType || mtUniquePropertyInfo.encodingType&UnicornPropertyEncodingTypeNSString || mtUniquePropertyInfo.encodingType&UnicornPropertyEncodingTypeNSURL || mtUniquePropertyInfo.encodingType&UnicornPropertyEncodingTypeNSNumber), @"[class:%@,propertyName:%@] [property class do not supported for unique constraint]", NSStringFromClass(cls), mtUniquePropertyInfo.propertyName);
            self.mt = [UnicornMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
        }
        if ([cls conformsToProtocol:@protocol(UnicornDB)]) {
            NSMutableArray *dbPropertyInfos = [NSMutableArray array];
            if ([cls respondsToSelector:@selector(uni_dbIndexesInPropertyName)]) {
                self.dbIndexes = [[cls uni_dbIndexesInPropertyName] copy];
            }
            NSArray *dbColumnNames = [cls uni_dbColumnNamesInPropertyName];
            [dbColumnNames enumerateObjectsUsingBlock:^(NSString *_Nonnull propertyName, NSUInteger idx, BOOL *_Nonnull stop) {
                UNPropertyInfo *propertyInfo = self.propertyInfosByPropertyName[propertyName];
                NSAssert(propertyInfo.ivarName.length > 0, @"[class:%@,propertyName:%@] [property do not have ivar]", NSStringFromClass(cls), propertyName);
                UnicornDatabaseTransformer *dataBaseTransformer = nil;
                if ([cls respondsToSelector:@selector(uni_dbValueTransformerForPropertyName:)]) {
                    dataBaseTransformer = [cls uni_dbValueTransformerForPropertyName:propertyName];
                }
                if (dataBaseTransformer) {
                    propertyInfo.dbColumnType = dataBaseTransformer.columnType;
                    propertyInfo.dbValueTransformer = dataBaseTransformer.valueTransformer;
                } else {
                    NSParameterAssert(propertyInfo.encodingType != UnicornPropertyEncodingTypeUnsupportedCType);
                    if (propertyInfo.encodingType >= UnicornPropertyEncodingTypeBool && propertyInfo.encodingType <= UnicornPropertyEncodingTypeUInt64) {
                        propertyInfo.dbColumnType = UnicornDatabaseColumnTypeInteger;
                    } else if (propertyInfo.encodingType == UnicornPropertyEncodingTypeFloat || propertyInfo.encodingType == UnicornPropertyEncodingTypeDouble) {
                        propertyInfo.dbColumnType = UnicornDatabaseColumnTypeReal;
                    } else if (propertyInfo.encodingType & UnicornPropertyEncodingTypeNSData) {
                        propertyInfo.dbColumnType = UnicornDatabaseColumnTypeBlob;
                    } else if (propertyInfo.encodingType == UnicornPropertyEncodingTypeNSString || propertyInfo.encodingType == UnicornPropertyEncodingTypeNSURL || propertyInfo.encodingType == UnicornPropertyEncodingTypeNSNumber) {
                        propertyInfo.dbColumnType = UnicornDatabaseColumnTypeText;
                    } else {
                        if ([propertyInfo.cls conformsToProtocol:@protocol(UnicornDB)]) {
                            UnicornClassInfo *childClassInfo = [propertyInfo.cls uni_classInfo];
                            propertyInfo.dbColumnType = childClassInfo.mtUniquePropertyInfo.dbColumnType;
                        } else {
                            NSParameterAssert([cls respondsToSelector:@selector(uni_dbValueTransformerForPropertyName:)]);
                        }
                    }
                }
                [dbPropertyInfos addObject:propertyInfo];
            }];
            self.dbPropertyInfos = dbPropertyInfos.count ? dbPropertyInfos : nil;
            if (self.mtUniquePropertyName) {
                self.dbSelectSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=?", self.className, self.mtUniquePropertyName];
            }
            NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", self.className];
            NSMutableString *sql1 = [NSMutableString stringWithFormat:@"INSERT INTO %@ (", self.className];
            NSMutableString *sql2 = [NSMutableString stringWithFormat:@" VALUES ("];
            [self.dbPropertyInfos enumerateObjectsUsingBlock:^(UNPropertyInfo *_Nonnull propertyInfo, NSUInteger idx, BOOL *_Nonnull stop) {
                [sql appendFormat:@"%@=?,", propertyInfo.propertyName];
                [sql1 appendFormat:@"%@,", propertyInfo.propertyName];
                [sql2 appendFormat:@"?,"];
            }];
#ifdef uni_DB_AUTO_UPDATE_TIMESTAMP
            [sql appendFormat:@"%@=?,", uni_on_update_timestamp];
#endif
            [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
            [sql appendFormat:@" WHERE %@=?;", self.mtUniquePropertyName];
            self.dbUpdateSql = sql;
#ifdef uni_DB_AUTO_UPDATE_TIMESTAMP
            [sql1 appendFormat:@"%@,", uni_on_update_timestamp];
            [sql2 appendFormat:@"?,"];
#endif
            [sql1 deleteCharactersInRange:NSMakeRange(sql1.length - 1, 1)];
            [sql1 appendFormat:@")"];
            [sql2 deleteCharactersInRange:NSMakeRange(sql2.length - 1, 1)];
            [sql2 appendFormat:@")"];
            self.dbInsertSql = [NSString stringWithFormat:@"%@%@", sql1, sql2];
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                global_database = [UnicornDatabase databaseWithFile:UNI_DB_MODEL_DB_PATH error:nil];
            });
            self.db = global_database;
        }
    }
    return self;
}

- (void)sync:(void (^)(UnicornMapTable *mt, UnicornDatabase *db))block {
    [self.lock lock];
    if (self.db) {
        [self.db sync:^(UnicornDatabase *db) {
            block(self.mt, self.db);
        }];
    } else {
        block(self.mt, self.db);
    }
    [self.lock unlock];
}

- (void)setMt:(UnicornMapTable *)mt db:(UnicornDatabase *)db{
    [self.lock lock];
    if (_mt != mt) {
        _mt = mt;
    }
    if (_db != db) {
        _db = db;
        uni_db_create(self, _db);
    }
    [self.lock unlock];
}

- (void)enumeratePropertiesUsingBlock:(void (^)(objc_property_t property))block {
    Class cls = self.cls;
    while (YES) {
        if (cls == NSObject.class) {
            break;
        }
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        if (properties == NULL) {
            cls = cls.superclass;
            continue;
        }
        for (unsigned i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            block(property);
        }
        free(properties);
        cls = cls.superclass;
    }
}

@end

@implementation UNPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property parentClass:(Class)parentClass {
    self = [super init];
    if (self) {
        self.parentClass = parentClass;
        self.propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *attributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        UnicornPropertyPropertyType propertyType = 0;
        for (NSString *attr in [attributes componentsSeparatedByString:@","]) {
            const char *attribute = [attr UTF8String];
            switch (attribute[0]) {
                case 'T': {
                    const char *encoding = attribute + 1;
                    if (encoding[0] == '@') {
                        if (strcmp(encoding, "@\"NSString\"") == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeNSString;
                        } else if (strcmp(encoding, "@\"NSNumber\"") == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeNSNumber;
                        } else if (strcmp(encoding, "@\"NSURL\"") == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeNSURL;
                        } else {
                            self.encodingType = UnicornPropertyEncodingTypeUnsupportedObject;
                        }
                        size_t size = strlen(encoding);
                        if (size > 3) {
                            NSString *clsName = [[NSString alloc] initWithBytes:encoding + 2 length:size - 3 encoding:NSUTF8StringEncoding];
                            self.cls = NSClassFromString(clsName);
                        }
                    } else {
                        if (strcmp(encoding, @encode(char)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeInt8;
                        } else if (strcmp(encoding, @encode(unsigned char)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeUInt8;
                        } else if (strcmp(encoding, @encode(short)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeInt16;
                        } else if (strcmp(encoding, @encode(unsigned short)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeUInt16;
                        } else if (strcmp(encoding, @encode(int)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeInt32;
                        } else if (strcmp(encoding, @encode(unsigned int)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeUInt32;
                        } else if (strcmp(encoding, @encode(long)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeInt64;
                        } else if (strcmp(encoding, @encode(unsigned long)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeUInt64;
                        } else if (strcmp(encoding, @encode(long long)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeInt64;
                        } else if (strcmp(encoding, @encode(unsigned long long)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeUInt64;
                        } else if (strcmp(encoding, @encode(float)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeFloat;
                        } else if (strcmp(encoding, @encode(double)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeDouble;
                        } else if (strcmp(encoding, @encode(bool)) == 0) {
                            self.encodingType = UnicornPropertyEncodingTypeBool;
                        } else {
                            self.encodingType = UnicornPropertyEncodingTypeUnsupportedCType;
                        }
                    }
                } break;
                case 'V': {
                    const char *ivar_key = attribute + 1;
                    if (strlen(ivar_key) > 0) {
                        self.ivarName = [NSString stringWithCString:ivar_key encoding:NSUTF8StringEncoding];
                    }
                } break;
                case 'G': {
                    NSString *getterString = [NSString stringWithCString:attribute + 1 encoding:NSUTF8StringEncoding];
                    self.getter = NSSelectorFromString(getterString);
                } break;
                case 'S': {
                    NSString *setterString = [NSString stringWithCString:attribute + 1 encoding:NSUTF8StringEncoding];
                    self.setter = NSSelectorFromString(setterString);
                }
                case 'R': {
                    propertyType |= UnicornPropertyPropertyTypeReadonly;
                } break;
                case 'N': {
                    propertyType |= UnicornPropertyPropertyTypeNonatomic;
                } break;
                case 'D': {
                    propertyType |= UnicornPropertyPropertyTypeDynamic;
                } break;
                default:
                    break;
            }
        }
        if (self.ivarName && !(propertyType & UnicornPropertyPropertyTypeDynamic)) {
            if (!self.getter) {
                NSString *getterString = self.propertyName;
                self.getter = NSSelectorFromString(getterString);
            }
            if (!self.setter && !(propertyType & UnicornPropertyPropertyTypeReadonly)) {
                NSString *setterString = self.propertyName;
                setterString = [NSString stringWithFormat:@"set%@:", [NSString stringWithFormat:@"%@%@", [[setterString substringToIndex:1] capitalizedString], [setterString substringFromIndex:1]]];
                self.setter = NSSelectorFromString(setterString);
            }
        }
        if (self.encodingType&UnicornPropertyEncodingTypeSupportedCType) {
            self.numberFormatter = [[NSNumberFormatter alloc] init];
            self.numberFormatter.numberStyle = NSNumberFormatterNoStyle;
        }
        self.isConformingToUnicornJSONModel = [self.cls conformsToProtocol:@protocol(UnicornJSON)];
        self.isConformingToUnicornMT = [self.cls conformsToProtocol:@protocol(UnicornMT)];
        self.isConformingToUnicornDB = [self.cls conformsToProtocol:@protocol(UnicornDB)];

    }
    return self;
}

@end

@implementation NSObject (UnicornInfo)

+ (UnicornClassInfo *)uni_classInfo {
    @synchronized(self) {
        UnicornClassInfo *classInfo = objc_getAssociatedObject(self, @selector(uni_classInfo));
        if (!classInfo) {
            classInfo = [[UnicornClassInfo alloc] initWithClass:self];
            objc_setAssociatedObject(self, @selector(uni_classInfo), classInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return classInfo;
    }
}

@end

@implementation NSDictionary (Unicorn)

- (id)uni_valueForKeyPaths:(NSArray *)keyPaths {
    if (keyPaths.count == 0) {
        return nil;
    }
    __unsafe_unretained id value = self;
    for (id key in keyPaths) {
        value = value[key];
    }
    return value;
}

@end
