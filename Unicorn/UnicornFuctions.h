//
//  UnicornFuctions.h
//  Unicorn
//
//  Created by emsihyo on 2017/1/5.

#ifndef UNFuctions_h
#define UNFuctions_h
#import "UnicornModelInfo.h"
#import <objc/message.h>
typedef char Int8;
typedef short Int16;
typedef int Int32;
typedef long long Int64;
#pragma mark --
#pragma mark -- model set

static inline void uni_model_set_id(__unsafe_unretained id model, SEL setter, __unsafe_unretained id value){
    ((void (*)(id, SEL, id))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_void(__unsafe_unretained id model, SEL setter, void *value){
    ((void (*)(id, SEL, void *))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_bool(__unsafe_unretained id model, SEL setter, bool value){
    ((void (*)(id, SEL, bool))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_int8(__unsafe_unretained id model, SEL setter, Int8 value){
    ((void (*)(id, SEL, Int8))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_uint8(__unsafe_unretained id model, SEL setter, UInt8 value){
    ((void (*)(id, SEL, UInt8))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_int16(__unsafe_unretained id model, SEL setter, Int16 value){
    ((void (*)(id, SEL, Int16))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_uint16(__unsafe_unretained id model, SEL setter, UInt16 value){
    ((void (*)(id, SEL, UInt16))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_int32(__unsafe_unretained id model, SEL setter, Int32 value){
    ((void (*)(id, SEL, Int32))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_uint32(__unsafe_unretained id model, SEL setter, UInt32 value){
    ((void (*)(id, SEL, UInt32))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_int64(__unsafe_unretained id model, SEL setter, Int64 value){
    ((void (*)(id, SEL, Int64))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_uint64(__unsafe_unretained id model, SEL setter, UInt64 value){
    ((void (*)(id, SEL, UInt64))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_float(__unsafe_unretained id model, SEL setter, float value){
    ((void (*)(id, SEL, float))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_double(__unsafe_unretained id model, SEL setter, double value){
    ((void (*)(id, SEL, double))(void *) objc_msgSend)(model, setter, value);
}

static inline void uni_model_set_value(__unsafe_unretained id model, __unsafe_unretained UNPropertyInfo *propertyInfo, __unsafe_unretained id value){
    UnicornPropertyEncodingType encodingType = propertyInfo.encodingType;
    SEL setter = propertyInfo.setter;
    if (encodingType & UnicornPropertyEncodingTypeObject) {
        if (value == (id)kCFNull) {
            value = nil;
        }
        uni_model_set_id(model, setter, value);
    } else if (value == nil || value == (id)kCFNull) {
        uni_model_set_double(model, setter, 0);
    } else {
        if (![value isKindOfClass:NSNumber.class]) {
            value = [propertyInfo.numberFormatter numberFromString:value];
        }
        switch (encodingType) {
            case UnicornPropertyEncodingTypeBool:
                uni_model_set_bool(model, setter, [value boolValue]);
                break;
            case UnicornPropertyEncodingTypeInt8:
                uni_model_set_int8(model, setter, [value charValue]);
                break;
            case UnicornPropertyEncodingTypeUInt8:
                uni_model_set_uint8(model, setter, [value unsignedCharValue]);
                break;
            case UnicornPropertyEncodingTypeInt16:
                uni_model_set_int16(model, setter, [value shortValue]);
                break;
            case UnicornPropertyEncodingTypeUInt16:
                uni_model_set_uint16(model, setter, [value unsignedShortValue]);
                break;
            case UnicornPropertyEncodingTypeInt32:
                uni_model_set_int32(model, setter, [value intValue]);
                break;
            case UnicornPropertyEncodingTypeUInt32:
                uni_model_set_uint32(model, setter, [value unsignedIntValue]);
                break;
            case UnicornPropertyEncodingTypeInt64:
                uni_model_set_int64(model, setter, [value longLongValue]);
                break;
            case UnicornPropertyEncodingTypeUInt64:
                uni_model_set_uint64(model, setter, [value unsignedLongLongValue]);
                break;
            case UnicornPropertyEncodingTypeFloat:
                uni_model_set_float(model, setter, [value floatValue]);
                break;
            case UnicornPropertyEncodingTypeDouble:
                uni_model_set_double(model, setter, [value doubleValue]);
                break;
            default:
                NSCParameterAssert(encodingType != UnicornPropertyEncodingTypeUnsupportedCType);
                break;
        }
    }
}

#pragma mark --
#pragma mark -- model get
static inline id uni_model_get_id(__unsafe_unretained id model, SEL getter){
    return ((id (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline void *uni_model_get_void(__unsafe_unretained id model, SEL getter){
    return ((void * (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline bool uni_model_get_bool(__unsafe_unretained id model, SEL getter){
    return ((bool (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline Int8 uni_model_get_int8(__unsafe_unretained id model, SEL getter){
    return ((Int8 (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline UInt8 uni_model_get_uint8(__unsafe_unretained id model, SEL getter){
    return ((UInt8 (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline Int16 uni_model_get_int16(__unsafe_unretained id model, SEL getter){
    return ((Int16 (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline UInt16 uni_model_get_uint16(__unsafe_unretained id model, SEL getter){
    return ((UInt16 (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline Int32 uni_model_get_int32(__unsafe_unretained id model, SEL getter){
    return ((Int32 (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline UInt32 uni_model_get_uint32(__unsafe_unretained id model, SEL getter){
    return ((UInt32 (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline Int64 uni_model_get_int64(__unsafe_unretained id model, SEL getter){
    return ((Int64 (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline UInt64 uni_model_get_uint64(__unsafe_unretained id model, SEL getter){
    return ((UInt64 (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline float uni_model_get_float(__unsafe_unretained id model, SEL getter){
    return ((float (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline double uni_model_get_double(__unsafe_unretained id model, SEL getter){
    return ((double (*)(id, SEL))(void *) objc_msgSend)(model, getter);
}

static inline id uni_model_get_value(__unsafe_unretained id model, __unsafe_unretained UNPropertyInfo *propertyInfo){
    id value = nil;
    UnicornPropertyEncodingType encodingType = propertyInfo.encodingType;
    SEL getter = propertyInfo.getter;
    if (encodingType & UnicornPropertyEncodingTypeObject) {
        value = ((id (*)(id, SEL))(void *) objc_msgSend)(model, getter);
    } else {
        switch (encodingType) {
            case UnicornPropertyEncodingTypeBool:
                value = @(uni_model_get_bool(model, getter));
                break;
            case UnicornPropertyEncodingTypeInt8:
                value = @(uni_model_get_int8(model, getter));
                break;
            case UnicornPropertyEncodingTypeUInt8:
                value = @(uni_model_get_uint8(model, getter));
                break;
            case UnicornPropertyEncodingTypeInt16:
                value = @(uni_model_get_int16(model, getter));
                break;
            case UnicornPropertyEncodingTypeUInt16:
                value = @(uni_model_get_uint16(model, getter));
                break;
            case UnicornPropertyEncodingTypeInt32:
                value = @(uni_model_get_int32(model, getter));
                break;
            case UnicornPropertyEncodingTypeUInt32:
                value = @(uni_model_get_uint32(model, getter));
                break;
            case UnicornPropertyEncodingTypeInt64:
                value = @(uni_model_get_int64(model, getter));
                break;
            case UnicornPropertyEncodingTypeUInt64:
                value = @(uni_model_get_uint64(model, getter));
                break;
            case UnicornPropertyEncodingTypeFloat:
                value = @(uni_model_get_float(model, getter));
                break;
            case UnicornPropertyEncodingTypeDouble:
                value = @(uni_model_get_double(model, getter));
                break;
            default:
                NSCParameterAssert(encodingType != UnicornPropertyEncodingTypeUnsupportedCType);
                break;
        }
    }
    return value;
}

#pragma mark --
#pragma mark -- model merge
static inline void uni_model_merge(__unsafe_unretained id target_model, __unsafe_unretained id source_model, __unsafe_unretained UnicornClassInfo *classInfo){
    NSCParameterAssert([target_model class] == [source_model class]);
    if (target_model==source_model) {
        return;
    }
    for (UNPropertyInfo *propertyInfo in classInfo.propertyInfos) {
        UnicornPropertyEncodingType encodingType = propertyInfo.encodingType;
        SEL getter = propertyInfo.getter;
        SEL setter = propertyInfo.setter;
        if (encodingType&UnicornPropertyEncodingTypeObject) {
            id value = uni_model_get_id(source_model, getter);
            if (value == (id)kCFNull) {
                value = nil;
            }
            if (value) {
                uni_model_set_id(target_model, setter, value);
            }
        } else {
            switch (encodingType) {
                case UnicornPropertyEncodingTypeBool:
                    uni_model_set_bool(target_model, setter, uni_model_get_bool(source_model, getter));
                    break;
                case UnicornPropertyEncodingTypeInt8:
                    uni_model_set_int8(target_model, setter, uni_model_get_int8(source_model, getter));
                    break;
                case UnicornPropertyEncodingTypeUInt8:
                    uni_model_set_uint8(target_model, setter, uni_model_get_uint8(source_model, getter));
                    break;
                case UnicornPropertyEncodingTypeInt16:
                    uni_model_set_int16(target_model, setter, uni_model_get_int16(source_model, getter));
                    break;
                case UnicornPropertyEncodingTypeUInt16:
                    uni_model_set_uint16(target_model, setter, uni_model_get_uint16(source_model, getter));
                    break;
                case UnicornPropertyEncodingTypeInt32:
                    uni_model_set_int32(target_model, setter, uni_model_get_int32(source_model, getter));
                    break;
                case UnicornPropertyEncodingTypeUInt32:
                    uni_model_set_uint32(target_model, setter, uni_model_get_uint32(source_model, getter));
                    break;
                case UnicornPropertyEncodingTypeInt64:
                    uni_model_set_int64(target_model, setter, uni_model_get_int64(source_model, getter));
                    break;
                case UnicornPropertyEncodingTypeUInt64:
                    uni_model_set_uint64(target_model, setter, uni_model_get_uint64(source_model, getter));
                    break;
                case UnicornPropertyEncodingTypeFloat:
                    uni_model_set_float(target_model, setter, uni_model_get_float(source_model, getter));
                    break;
                case UnicornPropertyEncodingTypeDouble:
                    uni_model_set_double(target_model, setter, uni_model_get_double(source_model, getter));
                    break;
                default:
                    NSCParameterAssert(encodingType != UnicornPropertyEncodingTypeUnsupportedCType);
                    break;
            }
        }
    }
}

#pragma mark --
#pragma mark -- MT DB

static inline NSString *uni_sql_column_text(UnicornDatabaseColumnType type) {
    NSString *dbColumnType = nil;
    switch (type) {
        case UnicornDatabaseColumnTypeText:
            dbColumnType = @"text";
            break;
        case UnicornDatabaseColumnTypeInteger:
            dbColumnType = @"integer";
            break;
        case UnicornDatabaseColumnTypeReal:
            dbColumnType = @"real";
            break;
        case UnicornDatabaseColumnTypeBlob:
            dbColumnType = @"blob";
            break;
        default:
            NSCParameterAssert(type != UnicornDatabaseColumnTypeUnknow);
            break;
    }
    return dbColumnType;
}

typedef struct {
    __unsafe_unretained id model;
    __unsafe_unretained id dictionary;
}dictionary_context;

static void forward_applier(const void *_value, void *_context){
    __unsafe_unretained UNPropertyInfo *propertyInfo = (__bridge __unsafe_unretained UNPropertyInfo *)_value;
    dictionary_context *context = _context;
    __unsafe_unretained id model = context->model;
    __unsafe_unretained NSDictionary *dictionary = context->dictionary;
    __unsafe_unretained NSValueTransformer *valueTransformer = propertyInfo.dbValueTransformer;
    id value = dictionary[propertyInfo.propertyName];
    if (valueTransformer) {
        value = [valueTransformer transformedValue:value];
    }
    if (propertyInfo.encodingType == UnicornPropertyEncodingTypeUnsupportedObject) {
        if (propertyInfo.isConformingToUnicornMT) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            value = ((id (*)(id, SEL, id))(void *) objc_msgSend)([propertyInfo.cls class], @selector(uni_modelWithValue:), value);
            uni_model_set_value(model, propertyInfo, value);
#pragma clang diagnostic pop
        } else {
            uni_model_set_value(model, propertyInfo, nil);
        }
    } else {
        uni_model_set_value(model, propertyInfo, value);
    }
}

static inline id uni_model_get_unique_value(__unsafe_unretained id model, __unsafe_unretained UnicornClassInfo *classInfo){
    __unsafe_unretained UNPropertyInfo *propertyInfo = classInfo.mtUniquePropertyInfo;
    UnicornPropertyEncodingType encodingType = propertyInfo.encodingType;
    NSCParameterAssert(encodingType != UnicornPropertyEncodingTypeNSData && encodingType != UnicornPropertyEncodingTypeUnsupportedCType);
    id value = uni_model_get_value(model, propertyInfo);
    if (value == nil) {
        return value;
    }
    if (encodingType&UnicornPropertyEncodingTypeUnsupportedObject) {
        return uni_model_get_unique_value(value, classInfo);
    }
    return value;
}

static inline void uni_bind_value_to_stmt_with_column_type(__unsafe_unretained id value, UnicornDatabaseColumnType columnType, sqlite3_stmt *stmt, int idx){
    switch (columnType) {
        case UnicornDatabaseColumnTypeInteger:
            sqlite3_bind_int64(stmt, idx, [value longLongValue]);
            break;
        case UnicornDatabaseColumnTypeReal:
            sqlite3_bind_double(stmt, idx, [value doubleValue]);
            break;
        case UnicornDatabaseColumnTypeText:
            sqlite3_bind_text(stmt, idx, [[value description] UTF8String], -1, SQLITE_STATIC);
            break;
        case UnicornDatabaseColumnTypeBlob:
            sqlite3_bind_blob(stmt, idx, [value bytes], (int)[value length], SQLITE_STATIC);
            break;
        default:
            NSCParameterAssert(columnType != UnicornDatabaseColumnTypeUnknow);
            sqlite3_bind_null(stmt, idx);
            break;
    }
}

static inline void uni_bind_value_to_stmt_with_property(__unsafe_unretained id model, __unsafe_unretained UNPropertyInfo *propertyInfo, sqlite3_stmt *stmt, int idx) {
    UnicornPropertyEncodingType encodingType = propertyInfo.encodingType;
    __unsafe_unretained NSValueTransformer *valueTransformer = propertyInfo.dbValueTransformer;
    if (valueTransformer) {
        id value = [valueTransformer reverseTransformedValue:((id (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter)];
        uni_bind_value_to_stmt_with_column_type(value, propertyInfo.dbColumnType, stmt, idx);
        return;
    }
    if (encodingType & UnicornPropertyEncodingTypeObject) {
        switch (encodingType) {
            case UnicornPropertyEncodingTypeNSString:
                sqlite3_bind_text(stmt, idx, [((NSString * (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter) UTF8String], -1, SQLITE_STATIC);
                break;
            case UnicornPropertyEncodingTypeNSNumber:
                sqlite3_bind_text(stmt, idx, [[NSString stringWithFormat:@"%@", ((NSNumber * (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter)] UTF8String], -1, SQLITE_STATIC);
                break;
            case UnicornPropertyEncodingTypeNSURL:
                sqlite3_bind_text(stmt, idx, [[((NSURL * (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter) absoluteString] UTF8String], -1, SQLITE_STATIC);
                break;
            case UnicornPropertyEncodingTypeNSData: {
                NSData *value = ((NSData * (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter);
                sqlite3_bind_blob(stmt, idx, [value bytes], (int)[value length], SQLITE_STATIC);
                break;
            }
            default:
                NSCParameterAssert(propertyInfo.isConformingToUnicornMT);
                uni_bind_value_to_stmt_with_column_type(uni_model_get_unique_value(uni_model_get_value(model, propertyInfo), [propertyInfo.cls uni_classInfo]), propertyInfo.dbColumnType, stmt, idx);
                break;
        }
    } else {
        switch (encodingType) {
            case UnicornPropertyEncodingTypeBool:
                sqlite3_bind_int64(stmt, idx, (long long)((bool (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter));
                break;
            case UnicornPropertyEncodingTypeInt8:
                sqlite3_bind_int64(stmt, idx, (long long)((char (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter));
                break;
            case UnicornPropertyEncodingTypeUInt8:
                sqlite3_bind_int64(stmt, idx, (long long)((unsigned char (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter));
                break;
            case UnicornPropertyEncodingTypeInt16:
                sqlite3_bind_int64(stmt, idx, (long long)((short (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter));
                break;
            case UnicornPropertyEncodingTypeUInt16:
                sqlite3_bind_int64(stmt, idx, (long long)((UInt16 (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter));
                break;
            case UnicornPropertyEncodingTypeInt32:
                sqlite3_bind_int64(stmt, idx, (long long)((int (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter));
                break;
            case UnicornPropertyEncodingTypeUInt32:
                sqlite3_bind_int64(stmt, idx, (long long)((UInt32 (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter));
                break;
            case UnicornPropertyEncodingTypeInt64:
                sqlite3_bind_int64(stmt, idx, ((long long (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter));
                break;
            case UnicornPropertyEncodingTypeUInt64: {
                unsigned long long v = ((unsigned long long (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter);
                long long dst;
                memcpy(&dst, &v, sizeof(long long));
                sqlite3_bind_int64(stmt, idx, dst);
                break;
            }
            case UnicornPropertyEncodingTypeFloat:
                sqlite3_bind_double(stmt, idx, (double)((float (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter));
                break;
            case UnicornPropertyEncodingTypeDouble:
                sqlite3_bind_double(stmt, idx, ((double (*)(id, SEL))(void *) objc_msgSend)(model, propertyInfo.getter));
                break;
            default:
                NSCParameterAssert(encodingType != UnicornPropertyEncodingTypeUnsupportedCType);
                sqlite3_bind_null(stmt, idx);
                break;
        }
    }
}

static inline void uni_mt_set(__unsafe_unretained id model,__unsafe_unretained id uniqueValue,__unsafe_unretained UnicornMapTable *mt){
    [mt setObject:model forKey:uniqueValue];
}

static inline id uni_mt_unique_model(__unsafe_unretained id uniqueValue, __unsafe_unretained UnicornMapTable *mt){
    return [mt objectForKey:uniqueValue];
}

static inline id uni_db_unique_model(__unsafe_unretained id uniqueValue, __unsafe_unretained UnicornClassInfo *classInfo, __unsafe_unretained UnicornDatabase *db){
    NSDictionary *modelDict = [[db executeQuery:classInfo.dbSelectSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
        uni_bind_value_to_stmt_with_column_type(uniqueValue, classInfo.mtUniquePropertyInfo.dbColumnType, stmt, idx);
    } error:nil] firstObject];
    if (modelDict.count==0) {
        return nil;
    }
    dictionary_context context = {};
    context.dictionary = modelDict;
    id model = [[classInfo.cls alloc] init];
    context.model = model;
    CFArrayRef ref = (__bridge CFArrayRef)classInfo.dbPropertyInfos;
    CFArrayApplyFunction(ref, CFRangeMake(0, CFArrayGetCount(ref)), forward_applier, &context);
    return model;
}

static inline id uni_unique_model(__unsafe_unretained id uniqueValue, __unsafe_unretained UnicornClassInfo *classInfo, __unsafe_unretained UnicornMapTable *mt, __unsafe_unretained UnicornDatabase *db){
    __block id model = nil;
    if (mt) {
        model = uni_mt_unique_model(uniqueValue, mt);
        if (!model) {
            model = uni_db_unique_model(uniqueValue, classInfo, db);
            if (model) {
                uni_mt_set(model,uniqueValue,mt);
            }
        }
    }
    return model;
}

static inline void uni_db_update(__unsafe_unretained id model, __unsafe_unretained UnicornClassInfo *classInfo, __unsafe_unretained UnicornDatabase *db){
    NSInteger count = classInfo.dbPropertyInfos.count;
    [db executeUpdate:classInfo.dbUpdateSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
#ifdef uni_DB_AUTO_UPDATE_TIMESTAMP
        if (idx == count+1) {
            sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
        } else if (idx == count+2) {
            uni_bind_value_to_stmt_with_property(model, classInfo.mtUniquePropertyInfo, stmt, idx);
        } else {
            uni_bind_value_to_stmt_with_property(model, classInfo.dbPropertyInfos[idx-1], stmt, idx);
        }
#else
        if (idx == count+1) {
            uni_bind_value_to_stmt_with_property(model, classInfo.mtUniquePropertyInfo, stmt, idx);
        } else {
            uni_bind_value_to_stmt_with_property(model, classInfo.dbPropertyInfos[idx-1], stmt, idx);
        }
#endif
    } error:nil];
}

static inline void uni_db_insert(__unsafe_unretained id model, __unsafe_unretained UnicornClassInfo *classInfo, __unsafe_unretained UnicornDatabase *db){
#ifdef uni_DB_AUTO_UPDATE_TIMESTAMP
    NSInteger count = classInfo.dbPropertyInfos.count;
    [db executeUpdate:classInfo.dbInsertSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
        if (idx == count+1) {
            sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
        } else {
            uni_bind_value_to_stmt_with_property(model, classInfo.dbPropertyInfos[idx-1], stmt, idx);
        }
        uni_bind_value_to_stmt_with_property(model, classInfo.dbPropertyInfos[idx-1], stmt, idx);
    } error:nil];
#else
    [db executeUpdate:classInfo.dbInsertSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
        uni_bind_value_to_stmt_with_property(model, classInfo.dbPropertyInfos[idx-1], stmt, idx);
    } error:nil];
#endif
}

static inline NSArray *uni_select(__unsafe_unretained NSString *afterWhereSql, __unsafe_unretained NSArray *arguments, __unsafe_unretained UnicornClassInfo *classInfo, __unsafe_unretained UnicornMapTable *mt, __unsafe_unretained UnicornDatabase *db){
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", classInfo.className];
    if (afterWhereSql) {
        sql = [sql stringByAppendingFormat:@" WHERE %@", afterWhereSql];
    }
    NSArray *modelDicts = [db executeQuery:sql arguments:arguments error:nil];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:modelDicts.count];
    __unsafe_unretained NSValueTransformer *valueTransformer = classInfo.mtUniquePropertyInfo.dbValueTransformer;
    CFArrayRef ref = (__bridge CFArrayRef)classInfo.dbPropertyInfos;
    dictionary_context context = {};
    for (NSDictionary *modelDict in modelDicts) {
        id uniqueValue = modelDict[classInfo.mtUniquePropertyName];
        if (valueTransformer) {
            uniqueValue = [valueTransformer transformedValue:uniqueValue];
        }
        id model = uni_mt_unique_model(uniqueValue, mt);
        if (!model) {
            model = [[classInfo.cls alloc] init];
            context.dictionary = modelDict;
            context.model = model;
            CFArrayApplyFunction(ref, CFRangeMake(0, CFArrayGetCount(ref)), forward_applier, &context);
            uni_mt_set(model, uniqueValue, mt);
        }
        [models addObject:model];
    }
    return models;
}

//static inline id uni_value_get_from_stmt(sqlite3_stmt *stmt, int idx){
//    int type = sqlite3_column_type(stmt, idx);
//    id value = nil;
//    switch (type) {
//        case SQLITE_INTEGER:
//            value = @(sqlite3_column_int64(stmt, idx));
//            break;
//        case SQLITE_TEXT:
//            value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, idx)];
//            break;
//        case SQLITE_FLOAT:
//            value = @(sqlite3_column_double(stmt, idx));
//            break;
//        case SQLITE_BLOB:
//        {
//            int length = sqlite3_column_bytes(stmt, idx);
//            value = [NSData dataWithBytes:sqlite3_column_blob(stmt, idx) length:length];
//        }
//        break;
//        default:
//            NSCParameterAssert(type == SQLITE_INTEGER || type == SQLITE_TEXT || type == SQLITE_FLOAT || type == SQLITE_BLOB);
//            break;
//    }
//    return value;
//}

//static inline void uni_model_set_stmt(__unsafe_unretained id model, __unsafe_unretained UNPropertyInfo *propertyInfo, sqlite3_stmt *stmt, int idx) {
//    int type = sqlite3_column_type(stmt, idx);
//    UnicornPropertyEncodingType encodingType = propertyInfo.encodingType;
//    SEL setter = propertyInfo.setter;
//    __unsafe_unretained NSValueTransformer *valueTransformer = propertyInfo.dbValueTransformer;
//    if (valueTransformer) {
//        id value = uni_value_get_from_stmt(stmt, idx);
//        value = [valueTransformer transformedValue:value];
//        if (value) {
//            uni_model_set_id(model, setter, value);
//        }
//        return;
//    }
//    if (type == SQLITE_NULL) {
//        return;
//    }
//    if (encodingType & UnicornPropertyEncodingTypeObject) {
//        id value = nil;
//        switch (encodingType) {
//            case UnicornPropertyEncodingTypeNSString:
//                value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, idx)];
//                break;
//            case UnicornPropertyEncodingTypeNSNumber:
//                value = [propertyInfo.numberFormatter numberFromString:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, idx)]];
//                break;
//            case UnicornPropertyEncodingTypeNSURL:
//                value = [NSURL URLWithString:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, idx)]];
//                break;
//            case UnicornPropertyEncodingTypeNSData: {
//                int length = sqlite3_column_bytes(stmt, idx);
//                const void *bytes = sqlite3_column_blob(stmt, idx);
//                value = [NSData dataWithBytes:bytes length:length];
//                break;
//            }
//            default:
//                NSCParameterAssert(propertyInfo.isConformingToUnicornMT);
//                value = uni_value_get_from_stmt(stmt, idx);
//                if (value) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//                    value = ((id (*)(id, SEL, id))(void *) objc_msgSend)([model class], @selector(uni_modelWithValue:), value);
//#pragma clang diagnostic pop
//                }
//                break;
//        }
//        if (value) {
//            uni_model_set_id(model, setter, value);
//        }
//    } else {
//        switch (encodingType) {
//            case UnicornPropertyEncodingTypeBool: {
//                uni_model_set_bool(model, setter, (bool)sqlite3_column_int64(stmt, idx));
//                break;
//            }
//            case UnicornPropertyEncodingTypeInt8: {
//                uni_model_set_int8(model, setter, (Int8)sqlite3_column_int64(stmt, idx));
//                break;
//            }
//            case UnicornPropertyEncodingTypeUInt8: {
//                uni_model_set_uint8(model, setter, (UInt8)sqlite3_column_int64(stmt, idx));
//                break;
//            }
//            case UnicornPropertyEncodingTypeInt16: {
//                uni_model_set_int16(model, setter, (Int16)sqlite3_column_int64(stmt, idx));
//                break;
//            }
//            case UnicornPropertyEncodingTypeUInt16: {
//                uni_model_set_uint16(model, setter, (UInt16)sqlite3_column_int64(stmt, idx));
//                break;
//            }
//            case UnicornPropertyEncodingTypeInt32: {
//                uni_model_set_int32(model, setter, (Int32)sqlite3_column_int64(stmt, idx));
//                break;
//            }
//            case UnicornPropertyEncodingTypeUInt32: {
//                uni_model_set_uint32(model, setter, (UInt32)sqlite3_column_int64(stmt, idx));
//                break;
//            }
//            case UnicornPropertyEncodingTypeInt64: {
//                uni_model_set_int64(model, setter, sqlite3_column_int64(stmt, idx));
//                break;
//            }
//            case UnicornPropertyEncodingTypeUInt64: {
//                uni_model_set_uint64(model, setter, (UInt64)sqlite3_column_int64(stmt, idx));
//                break;
//            }
//            case UnicornPropertyEncodingTypeFloat: {
//                uni_model_set_float(model, setter, (float)sqlite3_column_double(stmt, idx));
//                break;
//            }
//            case UnicornPropertyEncodingTypeDouble: {
//                uni_model_set_double(model, setter, sqlite3_column_double(stmt, idx));
//                break;
//            }
//            default:
//                NSCParameterAssert(encodingType != UnicornPropertyEncodingTypeUnsupportedCType);
//                break;
//        }
//    }
//}

//static inline void uni_model_merge_with_stmt(__unsafe_unretained id model, __unsafe_unretained UnicornClassInfo *classInfo, sqlite3_stmt *stmt) {
//    int count = sqlite3_column_count(stmt);
//    for (int i = 0; i < count; ) {
//        i++;
//        const char *columnName = sqlite3_column_name(stmt, i);
//        if (columnName) {
//            UNPropertyInfo *propertyInfo = classInfo.propertyInfosByPropertyName[[NSString stringWithUTF8String:columnName]];
//            if ([classInfo.dbPropertyInfos containsObject:propertyInfo]) {
//                uni_model_set_stmt(model, propertyInfo, stmt, i);
//            }
//        }
//    }
//}

#endif /* UNFuctions_h */
