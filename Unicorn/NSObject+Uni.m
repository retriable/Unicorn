//
//  NSObject+Uni.m
//  Unicorn
//
//  Created by emsihyo on 2018/2/24.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <objc/message.h>

#import "NSObject+Uni.h"
#import "UniClass.h"
#import "UniProtocol.h"

@implementation NSNumberFormatter(Uni)
+ (instancetype)uni_default{
    static NSNumberFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ formatter=[[NSNumberFormatter alloc]init]; });
    return formatter;
}
@end

static __inline__ __attribute__((always_inline)) void uni_set_value(id target,UniProperty *property,id value){
    if (!value) return;
    switch (property.typeEncoding) {
        case UniTypeEncodingBool:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,bool))(void *) objc_msgSend)(target, property.setter,[value boolValue]);
            else if ([value isKindOfClass:NSString.class]) {
                NSString *low=[value lowercaseString];
                ((void (*)(id, SEL,bool))(void *) objc_msgSend)(target, property.setter,[low isEqualToString:@"true"]||[low isEqualToString:@"yes"]||[value boolValue]);
            }else if(value==(id)kCFNull) ((void (*)(id, SEL,bool))(void *) objc_msgSend)(target, property.setter,false);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingInt8:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,int8_t))(void *) objc_msgSend)(target, property.setter,[value charValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,int8_t))(void *) objc_msgSend)(target, property.setter,(int8_t)[value longLongValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,int8_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingUInt8:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,uint8_t))(void *) objc_msgSend)(target, property.setter,[value unsignedCharValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,uint8_t))(void *) objc_msgSend)(target, property.setter,(uint8_t)[value longLongValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,uint8_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingInt16:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,int16_t))(void *) objc_msgSend)(target, property.setter,[value shortValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,int16_t))(void *) objc_msgSend)(target, property.setter,(int16_t)[value longLongValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,int16_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingUInt16:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,uint16_t))(void *) objc_msgSend)(target, property.setter,[value unsignedShortValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,uint16_t))(void *) objc_msgSend)(target, property.setter,(uint16_t)[value longLongValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,uint16_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingInt32:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,int32_t))(void *) objc_msgSend)(target, property.setter,[value intValue]);
            else if ([value isKindOfClass:NSString.class]) {
                value=[[NSNumberFormatter uni_default] numberFromString:value];
                ((void (*)(id, SEL,int32_t))(void *) objc_msgSend)(target, property.setter,[value intValue]);
            }else if(value==(id)kCFNull) ((void (*)(id, SEL,int32_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingUInt32:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,uint32_t))(void *) objc_msgSend)(target, property.setter,[value unsignedIntValue]);
            else if ([value isKindOfClass:NSString.class]) {
                value=[[NSNumberFormatter uni_default] numberFromString:value];
                ((void (*)(id, SEL,uint32_t))(void *) objc_msgSend)(target, property.setter,(uint32_t)[value longLongValue]);
            }else if(value==(id)kCFNull) ((void (*)(id, SEL,uint32_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingInt64:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,int64_t))(void *) objc_msgSend)(target, property.setter,[value longLongValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,int64_t))(void *) objc_msgSend)(target, property.setter,[value longLongValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,int64_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        }break;
        case UniTypeEncodingUInt64:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,uint64_t))(void *) objc_msgSend)(target, property.setter,[value unsignedLongLongValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,uint64_t))(void *) objc_msgSend)(target, property.setter,(uint64_t)[value longLongValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,uint64_t))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingFloat:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,float))(void *) objc_msgSend)(target, property.setter,[value floatValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,float))(void *) objc_msgSend)(target, property.setter,[value floatValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,float))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingDouble:{
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,double))(void *) objc_msgSend)(target, property.setter,[value doubleValue]);
            else if ([value isKindOfClass:NSString.class])  ((void (*)(id, SEL,double))(void *) objc_msgSend)(target, property.setter,[value doubleValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,double))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
        } break;
        case UniTypeEncodingLongDouble:
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,long double))(void *) objc_msgSend)(target, property.setter,(long double)[value doubleValue]);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,long double))(void *) objc_msgSend)(target, property.setter,(long double)[value doubleValue]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,long double))(void *) objc_msgSend)(target, property.setter,0);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSString:
            if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if ([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[NSNumberFormatter uni_default] stringFromNumber:value]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[value description]);
            break;
        case UniTypeEncodingNSMutableString:
            if([value isKindOfClass:NSMutableString.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[value mutableCopy]);
            else if ([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[[NSNumberFormatter uni_default] stringFromNumber:value] mutableCopy]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[value description] mutableCopy]);
            break;
        case UniTypeEncodingNSURL:
            if([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[NSURL URLWithString:value]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSNumber:
            if([value isKindOfClass:NSNumber.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if ([value isKindOfClass:NSString.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[NSNumberFormatter uni_default] numberFromString:value]);
            else if(value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSDate:
        case UniTypeEncodingNSData:
            if ([value isKindOfClass:property.cls]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if (value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        case UniTypeEncodingNSMutableData:
            if ([value isKindOfClass:NSMutableData.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            else if([value isKindOfClass:NSData.class]) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[value mutableCopy]);
            else if (value==(id)kCFNull) ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,nil);
            else NSCAssert(0,@"unsupported value'class %@ for property %@",NSStringFromClass([value class]),property.name);
            break;
        default: [target setValue:value forKey:property.name]; break;
    }
}

static __inline__ __attribute__((always_inline)) id uni_get_value(id target,UniProperty *property){
    switch (property.typeEncoding) {
        case UniTypeEncodingBool: return @(((BOOL (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingInt8: return @(((int8_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingUInt8: return @(((uint8_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingInt16: return @(((int16_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingUInt16: return @(((uint16_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingInt32: return @(((int32_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingUInt32: return @(((uint32_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingInt64: return @(((int64_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingUInt64: return @(((uint64_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingFloat: return @(((float (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingDouble:
        case UniTypeEncodingLongDouble: return @(((double (*)(id, SEL))(void *) objc_msgSend)(target, property.getter));
        case UniTypeEncodingNSString:
        case UniTypeEncodingNSMutableString:
        case UniTypeEncodingNSURL:
        case UniTypeEncodingNSNumber:
        case UniTypeEncodingNSDate:
        case UniTypeEncodingNSData:
        case UniTypeEncodingNSMutableData:
        case UniTypeEncodingNSObject: return ((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
        default: return [target valueForKey:property.name];
    }
}

static __inline__ __attribute__((always_inline)) id uni_get_value_from_dict(NSDictionary *dict,NSArray * key){
    id value=dict;
    for (NSString *k in key) value=value[k];
    return value;
}

static __inline__ __attribute__((always_inline)) void _uni_bind_stmt(__unsafe_unretained id value,  UniColumnType columnType, sqlite3_stmt *stmt, int idx){
    switch (columnType) {
        case UniColumnTypeInteger: sqlite3_bind_int64(stmt, idx, [value longLongValue]); break;
        case UniColumnTypeReal: sqlite3_bind_double(stmt, idx, [value doubleValue]); break;
        case UniColumnTypeText: sqlite3_bind_text(stmt, idx, [[value description] UTF8String], -1, SQLITE_STATIC); break;
        case UniColumnTypeBlob: sqlite3_bind_blob(stmt, idx, [value bytes], (int)[value length], SQLITE_STATIC); break;
        default: NSCAssert(0,@"unsupported db column type"); sqlite3_bind_null(stmt, idx); break;
    }
}

static __inline__ __attribute__((always_inline)) void uni_bind_stmt(id target,UniProperty *property, sqlite3_stmt *stmt, int idx) {
    if (property.dbValueTransformer) {
        id value = [property.dbValueTransformer reverseTransformedValue:((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)];
        _uni_bind_stmt(value, property.columnType, stmt, idx); return;
    }
    switch (property.typeEncoding) {
        case UniTypeEncodingBool: sqlite3_bind_int64(stmt, idx, (long long)((bool (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingInt8: sqlite3_bind_int64(stmt, idx, (long long)((char (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingUInt8: sqlite3_bind_int64(stmt, idx, (long long)((unsigned char (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingInt16: sqlite3_bind_int64(stmt, idx, (long long)((short (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingUInt16: sqlite3_bind_int64(stmt, idx, (long long)((UInt16 (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingInt32: sqlite3_bind_int64(stmt, idx, (long long)((int (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingUInt32: sqlite3_bind_int64(stmt, idx, (long long)((UInt32 (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingInt64: sqlite3_bind_int64(stmt, idx, ((long long (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingUInt64: {
            unsigned long long v = ((unsigned long long (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            long long dst;
            memcpy(&dst, &v, sizeof(long long));
            sqlite3_bind_int64(stmt, idx, dst);
        } break;
        case UniTypeEncodingFloat: sqlite3_bind_double(stmt, idx, (double)((float (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingDouble: sqlite3_bind_double(stmt, idx, ((double (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingLongDouble: sqlite3_bind_double(stmt, idx, ((double (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
        case UniTypeEncodingNSString:
        case UniTypeEncodingNSMutableString: {
            id value=((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            if (value&&[value isKindOfClass:NSString.class]) sqlite3_bind_text(stmt, idx, [value UTF8String], -1, SQLITE_STATIC);
            else sqlite3_bind_null(stmt, idx);
        }break;
        case UniTypeEncodingNSURL: {
            id value=((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            if (value&&[value isKindOfClass:NSURL.class]) sqlite3_bind_text(stmt, idx, [[value absoluteString] UTF8String], -1, SQLITE_STATIC);
            else sqlite3_bind_null(stmt, idx);
        }break;
        case UniTypeEncodingNSNumber:{
            id value=((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            if (value&&[value isKindOfClass:NSNumber.class]) sqlite3_bind_text(stmt, idx, [[[NSNumberFormatter uni_default] stringFromNumber:value] UTF8String], -1, SQLITE_STATIC);
            else sqlite3_bind_null(stmt, idx);
        } break;
        case UniTypeEncodingNSDate:{
            id value=((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            if (value&&[value isKindOfClass:NSDate.class]) sqlite3_bind_double(stmt, idx, [value timeIntervalSince1970]);
            else sqlite3_bind_null(stmt, idx);
        } break;
        case UniTypeEncodingNSData:
        case UniTypeEncodingNSMutableData:{
            NSData *value = ((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
            if (value&&[value isKindOfClass:NSData.class])sqlite3_bind_blob(stmt, idx, [value bytes], (int)[value length], SQLITE_STATIC);
            else sqlite3_bind_null(stmt, idx);
        } break;
        case UniTypeEncodingNSObject:{
            UniClass *clz=[UniClass classWithClass:property.cls];
            if (clz.isConformsToUniDB) {
                id value=uni_get_value(target, property);
                if (value) _uni_bind_stmt(uni_get_value(value,clz.primaryProperty), property.columnType, stmt, idx);
            }else NSCAssert(0,@"property %@ should conforms to protocol UniDB",property.name);
        } break;
        default: NSCAssert(0,@"unsupported encoding type for property %@",property.name); sqlite3_bind_null(stmt, idx); break;
    }
}

static __inline__ __attribute__((always_inline)) void uni_merge_from_obj(id target,id source,UniClass *cls){
    for (UniProperty *property in cls.propertyArr){
        switch (property.typeEncoding) {
            case UniTypeEncodingBool: ((void (*)(id, SEL,bool))(void *) objc_msgSend)(target, property.setter,((bool (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingInt8: ((void (*)(id, SEL,int8_t))(void *) objc_msgSend)(target, property.setter,((int8_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingUInt8: ((void (*)(id, SEL,uint8_t))(void *) objc_msgSend)(target, property.setter,((uint8_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingInt16: ((void (*)(id, SEL,int16_t))(void *) objc_msgSend)(target, property.setter,((int16_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingUInt16: ((void (*)(id, SEL,uint16_t))(void *) objc_msgSend)(target, property.setter,((uint16_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingInt32: ((void (*)(id, SEL,int32_t))(void *) objc_msgSend)(target, property.setter,((int32_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingUInt32: ((void (*)(id, SEL,uint32_t))(void *) objc_msgSend)(target, property.setter,((uint32_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingInt64: ((void (*)(id, SEL,int64_t))(void *) objc_msgSend)(target, property.setter,((int64_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingUInt64: ((void (*)(id, SEL,uint64_t))(void *) objc_msgSend)(target, property.setter,((uint64_t (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingFloat: ((void (*)(id, SEL,float))(void *) objc_msgSend)(target, property.setter,((float (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingDouble: ((void (*)(id, SEL,double))(void *) objc_msgSend)(target, property.setter,((double (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingLongDouble: ((void (*)(id, SEL,long double))(void *) objc_msgSend)(target, property.setter,((long double (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingNSString:
            case UniTypeEncodingNSMutableString:
            case UniTypeEncodingNSURL:
            case UniTypeEncodingNSNumber:
            case UniTypeEncodingNSDate:
            case UniTypeEncodingNSData:
            case UniTypeEncodingNSMutableData:((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter)); break;
            case UniTypeEncodingNSObject: {
                id value=((id (*)(id, SEL))(void *) objc_msgSend)(target, property.getter);
                if ([property.cls conformsToProtocol:@protocol(UniMM)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                    value=((id (*)(id, SEL,id))(void *) objc_msgSend)(value,@selector(_uni_update:),[UniClass classWithClass:property.cls]);
#pragma clang diagnostic pop
                }
                ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,value);
            } break;
            default: [target setValue:[source valueForKey:property.name] forKey:property.name]; break;
        }
    }
}

static __inline__ __attribute__((always_inline)) void uni_merge_from_stmt(id target,sqlite3_stmt *stmt,UniClass *cls){
    int count = sqlite3_data_count(stmt);
    for (int i=0;i<count;i++){
        NSString *name = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
        UniProperty *property=cls.propertyDict[name];
        if (![cls.dbPropertyArr containsObject:property]) continue;
        int type = sqlite3_column_type(stmt, i);
        if (property) {
            if (property.dbValueTransformer) {
                id value = nil;
                switch (type) {
                    case SQLITE_INTEGER: value=@(sqlite3_column_int64(stmt, i)); break;
                    case SQLITE_FLOAT: value=@(sqlite3_column_double(stmt, i)); break;
                    case SQLITE_TEXT: value = [[NSString alloc] initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]; break;
                    case SQLITE_BLOB:{
                        int bytes = sqlite3_column_bytes(stmt, i);
                        value = [NSData dataWithBytes:sqlite3_column_blob(stmt, i) length:bytes];
                    } break;
                    default: break;
                }
                value = [property.dbValueTransformer transformedValue:value];
                uni_set_value(target, property, value);
                return;
            }
            switch (property.typeEncoding) {
                case UniTypeEncodingBool:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,bool))(void *) objc_msgSend)(target, property.setter,sqlite3_column_int64(stmt, i)>0?true:false); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingInt8:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,int8_t))(void *) objc_msgSend)(target, property.setter,(int8_t)sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingUInt8:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,uint8_t))(void *) objc_msgSend)(target, property.setter,(uint8_t)sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingInt16:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,int16_t))(void *) objc_msgSend)(target, property.setter,(int16_t)sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingUInt16:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,uint16_t))(void *) objc_msgSend)(target, property.setter,(uint16_t)sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingInt32:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,int32_t))(void *) objc_msgSend)(target, property.setter,(int32_t)sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingUInt32:{
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,uint32_t))(void *) objc_msgSend)(target, property.setter,(uint32_t)sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    }
                } break;
                case UniTypeEncodingInt64:
                    switch (type) {
                        case SQLITE_INTEGER: ((void (*)(id, SEL,int64_t))(void *) objc_msgSend)(target, property.setter,sqlite3_column_int64(stmt, i)); break;
                        default: break;
                    } break;
                case UniTypeEncodingUInt64:
                    switch (type) {
                        case SQLITE_INTEGER: {
                            int64_t v=sqlite3_column_int64(stmt, i);
                            uint64_t dst;
                            memcpy(&dst, &v, sizeof(uint64_t));
                            ((void (*)(id, SEL,uint64_t))(void *) objc_msgSend)(target, property.setter,dst);
                        }break;
                        default: break;
                    }  break;
                case UniTypeEncodingFloat:
                    switch (type) {
                        case SQLITE_FLOAT: ((void (*)(id, SEL,float))(void *) objc_msgSend)(target, property.setter,(float)sqlite3_column_double(stmt, i)); break;
                        default: break;
                    } break;
                case UniTypeEncodingDouble:
                    switch (type) {
                        case SQLITE_FLOAT: ((void (*)(id, SEL,double))(void *) objc_msgSend)(target, property.setter,sqlite3_column_double(stmt, i));
                            break;
                        default: break;
                    } break;
                case UniTypeEncodingLongDouble:
                    switch (type) {
                        case SQLITE_FLOAT: ((void (*)(id, SEL,long double))(void *) objc_msgSend)(target, property.setter,(long double)sqlite3_column_double(stmt, i)); break;
                        default:break;
                    } break;
                case UniTypeEncodingNSString:
                case UniTypeEncodingNSMutableString:
                    switch (type) {
                        case SQLITE_TEXT: ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[property.cls alloc] initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]); break;
                        default: break;
                    } break;
                case UniTypeEncodingNSURL:
                    switch (type) {
                        case SQLITE_TEXT: ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[property.cls alloc]initWithString:[[NSString alloc] initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]]); break;
                        default: break;
                    } break;
                case UniTypeEncodingNSNumber:
                    switch (type) {
                        case SQLITE_TEXT: ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[NSNumberFormatter uni_default] numberFromString:[[NSString alloc] initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]]); break;
                        default: break;
                    } break;
                case UniTypeEncodingNSDate:
                    switch (type) {
                        case SQLITE_FLOAT: ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[property.cls alloc]initWithTimeIntervalSince1970:sqlite3_column_double(stmt, i)]); break;
                        default: break;
                    } break;
                case UniTypeEncodingNSData:
                case UniTypeEncodingNSMutableData:
                    switch (type) {
                        case SQLITE_BLOB:{
                            int length = sqlite3_column_bytes(stmt, i);
                            ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,[[property.cls alloc]initWithBytes:sqlite3_column_blob(stmt, i) length:length]);
                            ;
                        } break;
                        default: break;
                    } break;
                case UniTypeEncodingNSObject:{
                    UniClass *clz = [UniClass classWithClass:property.cls];
                    if (!clz.isConformsToUniMM) { NSCParameterAssert(0); break; }
                    id value =nil;
                    switch (type) {
                        case SQLITE_INTEGER: value=@(sqlite3_column_double(stmt, i)); break;
                        case SQLITE_FLOAT: value=@(sqlite3_column_double(stmt, i)); break;
                        case SQLITE_TEXT: value = [[NSString alloc] initWithCString:(const char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]; break;
                        default: break;
                    }
                    if (!value) break;
                    __block id obj = [clz.mm objectForKey:value];
                    if (!obj) {
                        if (!clz.isConformsToUniDB) { NSCAssert(0,@"class %@ should conforms to UniDB",clz.name); break; }
                        if (!clz.db) { NSCAssert(0,@"db error"); break; }
                        NSError *err;
                        if(![clz.db executeQuery:clz.dbSelectSql stmtBlock:^(sqlite3_stmt *s, int idx) {
                            switch (property.columnType) {
                                case UniColumnTypeInteger: sqlite3_bind_int64(s, idx, [value longLongValue]); break;
                                case UniColumnTypeReal: sqlite3_bind_double(s, idx, [value doubleValue]); break;
                                case UniColumnTypeText: sqlite3_bind_text(s, idx, (const char *)sqlite3_column_text(stmt, i), -1, SQLITE_STATIC); break;
                                default: NSCAssert(0,@"unspported db column type in property %@",property.name); break;
                            }
                        } resultBlock:^(sqlite3_stmt *stmt, bool *stop) {
                            obj = [[clz.cls alloc]init];
                            uni_merge_from_stmt(obj, stmt, clz);
                            [clz.mm setObject:obj forKey:value];
                        } error:&err]) NSCAssert(0,@"db error %@",err);
                    }
                    ((void (*)(id, SEL,id))(void *) objc_msgSend)(target, property.setter,obj);
                } break;
                default: NSCAssert(0,@"unsupported encoding type in property %@",property.name); break;
            }
        }
    }
}

@implementation NSObject (Uni)

+ (instancetype)uni_parseJson:(id)json{
    if (!json) return nil;
    UniClass *cls=[UniClass classWithClass:self];
    __block id model;
    [cls sync:^{
         model=[self _uni_parseJson:json cls:cls];
    }];
    return model;
}

+ (instancetype)_uni_parseJson:(id)json cls:(UniClass*)cls{
    if ([json isKindOfClass:[NSString class]]) return [self _uni_parseJsonString:json cls:cls];
    else if([json isKindOfClass:[NSDictionary class]]) return [self _uni_parseJsonDict:json cls:cls];
    else if([json isKindOfClass:[NSArray class]]) return [self _uni_parseJsonArr:json cls:cls];
    else NSAssert(0,@"unsupported json %@",json);
    return nil;
}

+ (instancetype)_uni_parseJsonString:(NSString*)str cls:(UniClass*)cls{
    id json = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    if(!json) return nil;
    if ([json isKindOfClass:[NSDictionary class]]) return [self _uni_parseJsonDict:json cls:cls];
    else if([json isKindOfClass:[NSArray class]]) return [self _uni_parseJsonArr:json cls:cls];
    else NSAssert(0,@"unsupported json %@",json); return nil;
}

+ (instancetype)_uni_parseJsonDict:(NSDictionary*)dict cls:(UniClass*)cls{
    id model;
    id primary;
    if (cls.isConformsToUniMM) {
        for (NSArray *keyPath in cls.primaryProperty.jsonKeyPathArr){
            primary=uni_get_value_from_dict(dict, keyPath);
            if (primary) break;
        }
        if (cls.primaryProperty.jsonValueTransformer) primary=[cls.primaryProperty.jsonValueTransformer transformedValue:primary];
        if (!primary) return nil;
        switch (cls.primaryProperty.typeEncoding) {
            case UniTypeEncodingBool:
            case UniTypeEncodingInt8:
            case UniTypeEncodingUInt8:
            case UniTypeEncodingInt16:
            case UniTypeEncodingUInt16:
            case UniTypeEncodingInt32:
            case UniTypeEncodingUInt32:
            case UniTypeEncodingInt64:
            case UniTypeEncodingUInt64:
            case UniTypeEncodingFloat:
            case UniTypeEncodingDouble:
            case UniTypeEncodingLongDouble:
            case UniTypeEncodingNSNumber:
                if ([primary isKindOfClass:NSNumber.class]) ;
                else if ([primary isKindOfClass:NSString.class]) primary=[[NSNumberFormatter uni_default]numberFromString:primary];
                else { NSAssert(0,@"primary:%@ in dict is unsupported",primary); return nil; }
                break;
            case UniTypeEncodingNSString:
                if ([primary isKindOfClass:NSString.class]) ;
                else if([primary isKindOfClass:NSNumber.class]) primary=[[NSNumberFormatter uni_default]stringFromNumber:primary];
                else primary=[primary description];
                break;
            case UniTypeEncodingNSURL:
                if ([primary isKindOfClass:NSURL.class]) ;
                else if ([primary isKindOfClass:NSString.class]) primary=[NSURL URLWithString:primary];
                else { NSAssert(0,@"primary:%@ in dict is unsupported",primary); return nil; }
                break;
            default: NSAssert(0,@"primary encoding type is unsupported: %@",cls.primaryProperty); return nil;
        }
        model = [self _uni_queryOne:primary cls:cls];
        int count=(int)cls.dbPropertyArr.count;
        NSError *err;
        if (model) {
            [model _uni_mergeWithJsonDict:dict cls:cls];
            if(![cls.db executeUpdate:cls.dbUpdateSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
                if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
                 else if (idx == count+2) uni_bind_stmt(model, cls.primaryProperty, stmt, idx);
                 else uni_bind_stmt(model, cls.dbPropertyArr[idx-1], stmt, idx);
            } error:&err]) { NSAssert(0,@"db error %@",err); return nil; }
        }else{
            model=[[self alloc]init];
            [model _uni_mergeWithJsonDict:dict cls:cls];
            [cls.mm setObject:model forKey:primary];
            if (![cls.db executeUpdate:cls.dbInsertSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
                if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
                else uni_bind_stmt(model, cls.dbPropertyArr[idx-1], stmt, idx);
            } error:nil]) {
                NSAssert(0,@"unexpected error");
                if(![cls.db executeUpdate:cls.dbUpdateSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
                    if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
                    else if (idx == count+2) uni_bind_stmt(model, cls.primaryProperty, stmt, idx);
                    else uni_bind_stmt(model, cls.dbPropertyArr[idx-1], stmt, idx);
                } error:&err]){ NSAssert(0,@"db error %@",err); return nil; }
            }
        }
    }else{
        if(!cls.isConformsToUniJSON) { NSAssert(0,@"class %@ should conforms to property UniJSON",cls.name); return nil; }
        model=[[self alloc]init];
        [model _uni_mergeWithJsonDict:dict cls:cls];
    }
    return model;
}

+ (id)_uni_parseJsonArr:(NSArray*)arr cls:(UniClass*)cls{
    NSMutableArray *models=[NSMutableArray array];
    for (NSDictionary * dict in arr){
        if (![dict isKindOfClass:[NSDictionary class]]) continue;
        id model = [self _uni_parseJsonDict:dict cls:cls];
        if (model) [models addObject:model];
    }
    return models;
}

- (void)_uni_mergeWithJsonDict:(NSDictionary *)dict cls:(UniClass *)cls {
    for (UniProperty *property in cls.jsonPropertyArr){
        id value;
        for (NSArray *keyPath in property.jsonKeyPathArr){
            value=uni_get_value_from_dict(dict, keyPath);
            if (value) break;
        }
        if (property.jsonValueTransformer) value=[property.jsonValueTransformer transformedValue:value];
        else if ((property.typeEncoding)==UniTypeEncodingNSObject) {
            UniClass *clz=[UniClass classWithClass:property.cls];
            if (clz.isConformsToUniJSON) value=[property.cls _uni_parseJson:value cls:clz];
            else { NSAssert(0,@"property %@ 's class should confroms to UniJSON",property.name); value=nil ;}
        }
        if (value) uni_set_value(self, property, value);
    }
}

+ (id)_uni_queryOne:(id)primary cls:(UniClass*)cls{
    if (!cls.isConformsToUniMM) { NSParameterAssert(false); return nil; }
    __block id model = [cls.mm objectForKey:primary];
    if (model) return model;
    if (!cls.isConformsToUniDB) return nil;
    NSError *err;
    if(![cls.db executeQuery:cls.dbSelectSql stmtBlock:^(sqlite3_stmt *s, int idx) {
        switch (cls.primaryProperty.columnType) {
            case UniColumnTypeInteger: sqlite3_bind_int64(s, idx, [primary longLongValue]); break;
            case UniColumnTypeReal: sqlite3_bind_double(s, idx, [primary doubleValue]); break;
            case UniColumnTypeText: sqlite3_bind_text(s, idx, [primary UTF8String], -1, SQLITE_STATIC); break;
            default: NSAssert(0,@"unsupported db dolumn type of primary property %@",cls.primaryProperty.name); sqlite3_bind_null(s, idx); break;
        }
    } resultBlock:^(sqlite3_stmt *s, bool *stop) {
        model = [[self alloc]init];
        uni_merge_from_stmt(model, s, cls);
        [cls.mm setObject:model forKey:primary];
    } error:&err]) { NSAssert(0,@"db error %@",err); return nil; }
    return model;
}

+ (id)uni_queryOne:(id)primary{
    __block id model=nil;
    UniClass *cls=[UniClass classWithClass:self];
    [cls sync:^{
        model=[self _uni_queryOne:primary cls:cls];
    }];
    return model;
}

+ (NSArray*)uni_query:(NSString*)sqlAfterWhere args:(NSArray*)args{
    UniClass *cls=[UniClass classWithClass:self];
    if (!cls.isConformsToUniDB) { NSAssert(0,@"class %@ should comforms to protocol UniDB",cls.name); return nil; }
    NSString *sql=sqlAfterWhere.length?[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",cls.name,sqlAfterWhere]:[NSString stringWithFormat:@"SELECT * FROM %@",cls.name];
    NSMutableArray *arr=[NSMutableArray array];
    [cls sync:^{
        NSError *err;
        if(![cls.db executeQuery:sql arguments:args resultBlock:^(sqlite3_stmt *s, bool *stop) {
            id m = [[self alloc]init];
            uni_merge_from_stmt(m, s, cls);
            id primary=uni_get_value(m, cls.primaryProperty);
            if (!primary) { NSAssert(0,@"can not find primary value in model %@",m); return; }
            id model=[cls.mm objectForKey:primary];
            if (!model) { model=m; [cls.mm setObject:model forKey:primary]; }
            [arr addObject:model];
        } error:&err]) NSAssert(0,@"db error %@",err);
    }];
    return arr;
}

- (id)_uni_update:(UniClass *)cls{
    if (!cls.isConformsToUniMM) { NSAssert(0,@"class %@ should conforms to protocol UniMM",cls.name); return self; }
    id primary=uni_get_value(self, cls.primaryProperty);
    if (!primary) { NSLog(@"can not find primary value in model %@",self); return self; }
    id model=[cls.mm objectForKey:primary];
    if (model) {
        if (model!=self) for (UniProperty *property in cls.propertyArr){
                uni_merge_from_obj(model,property,uni_get_value(self, property));
            }
    }else{
        model=self;
        [cls.mm setObject:model forKey:primary];
    }
    if (!cls.isConformsToUniDB) return model;
    NSError *err;
    int count=(int)cls.dbPropertyArr.count;
    if (![cls.db executeUpdate:cls.dbInsertSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
        if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
        else uni_bind_stmt(model, cls.dbPropertyArr[idx-1], stmt, idx);
    } error:nil]) {
        if(![cls.db executeUpdate:cls.dbUpdateSql stmtBlock:^(sqlite3_stmt *stmt, int idx) {
            if (idx == count+1) sqlite3_bind_double(stmt, idx, [[NSDate date] timeIntervalSince1970]);
            else if (idx == count+2) uni_bind_stmt(model, cls.primaryProperty, stmt, idx);
            else uni_bind_stmt(model, cls.dbPropertyArr[idx-1], stmt, idx);
        } error:&err]) { NSAssert(0,@"db error %@",err); return self; }
    }
    return model;
}

- (id)uni_update{
    __block id model = self;
    UniClass *cls=[UniClass classWithClass:self.class];
    [cls sync:^{
        model=[self _uni_update:cls];
    }];
    return model;
}

+ (NSArray*)uni_update:(NSArray*)models{
    if (models.count==0) return models;
    NSMutableArray *arr=[NSMutableArray array];
    UniClass *cls=[UniClass classWithClass:self];
    [cls sync:^{
        for (id model in models) [arr addObject:[model _uni_update:cls]];
    }];
    return arr;
}

+ (BOOL)uni_delete:(NSString*)sqlAfterWhere args:(NSArray*)args{
    __block BOOL res;
    UniClass *cls=[UniClass classWithClass:self];
    NSString *sql=sqlAfterWhere.length?[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",cls.name,sqlAfterWhere]:[NSString stringWithFormat:@"DELETE FROM %@",cls.name];
    [cls sync:^{
        NSError *error=nil;
        res=[cls.db executeUpdate:sql arguments:args error:&error];
        if (!res) {
            NSLog(@"%@",error);
        }
    }];
    return res;
}
+ (BOOL)uni_deleteBeforeDate:(NSDate *)date{
    __block BOOL res;
    UniClass *cls=[UniClass classWithClass:self];
    [cls sync:^{
        NSError *error=nil;
        res=[cls.db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE uni_update_at<?",cls.name] arguments:@[@([[NSDate date] timeIntervalSince1970])] error:&error];
        if (!res) {
            NSLog(@"%@",error);
        }
    }];
    return res;
}

- (NSString*)uni_jsonString{
    return [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:[self uni_jsonDictionary] options:0 error:nil] encoding:NSUTF8StringEncoding];
}

- (NSDictionary*)uni_jsonDictionary{
    UniClass *cls=[UniClass classWithClass:self.class];
    if (!cls.isConformsToUniJSON) return nil;
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    for (UniProperty *property in cls.jsonPropertyArr){
        id value=uni_get_value(self, property);
        if (property.jsonValueTransformer) value=[property.jsonValueTransformer reverseTransformedValue:value];
        else if (property.typeEncoding==UniTypeEncodingNSObject) value=[value uni_jsonDictionary];
        if (!value) continue;
        NSArray *keyPath=property.jsonKeyPathArr[0];
        if (keyPath.count==1) dict[keyPath[0]]=value;
        else{
            for (int i=0;i<[keyPath count]-1;i++){
                id k=keyPath[i];
                NSMutableDictionary *d=dict[k];
                if(!d) d=[NSMutableDictionary dictionary];
                dict[k]=d;
                dict=d;
            }
            dict[[keyPath lastObject]]=value;
        }
    }
    return dict;
}

+ (NSArray*)uni_jsonDictionaryFromModels:(NSArray*)models{
    NSMutableArray *dicts=[NSMutableArray array];
    for (id model in models){
        NSDictionary *dict=[model uni_jsonDictionary];
        if(dict) [dicts addObject:dict];
    }
    return dicts;
}

+ (BOOL)uni_open:(NSString*)file error:(NSError* __autoreleasing *)error{
    __block BOOL suc;
    UniClass *cls=[UniClass classWithClass:self];
    [cls sync:^{
        suc=[cls open:file error:error];
    }];
    return suc;
}

@end
