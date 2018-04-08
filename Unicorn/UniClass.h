//
//  UniProperty.h
//  Unicorn
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "UniBlockValueTransformer.h"
#import "UniDB.h"

typedef NS_ENUM(NSInteger,UniTypeEncoding) {
    UniTypeEncodingUnknown              = 0,
    UniTypeEncodingBool                 = 1,
    UniTypeEncodingInt8                 = 2,
    UniTypeEncodingUInt8                = 3,
    UniTypeEncodingInt16                = 4,
    UniTypeEncodingUInt16               = 5,
    UniTypeEncodingInt32                = 6,
    UniTypeEncodingUInt32               = 7,
    UniTypeEncodingInt64                = 8,
    UniTypeEncodingUInt64               = 9,
    UniTypeEncodingFloat                = 10,
    UniTypeEncodingDouble               = 11,
    UniTypeEncodingLongDouble           = 12,
    UniTypeEncodingNSString             = 13,
    UniTypeEncodingNSMutableString      = 14,
    UniTypeEncodingNSURL                = 15,
    UniTypeEncodingNSNumber             = 16,
    UniTypeEncodingNSDate               = 17,
    UniTypeEncodingNSData               = 18,
    UniTypeEncodingNSMutableData        = 19,
    UniTypeEncodingNSObject             = 20
};

typedef NS_ENUM(NSInteger,UniMethodEncoding) {
    UniMethodEncodingUnknown     = 0,
    UniMethodEncodingConst       = 1 << 0,
    UniMethodEncodingIn          = 1 << 1,
    UniMethodEncodingInout       = 1 << 2,
    UniMethodEncodingOut         = 1 << 3,
    UniMethodEncodingBycopy      = 1 << 4,
    UniMethodEncodingByref       = 1 << 5,
    UniMethodEncodingOneway      = 1 << 6
};

typedef NS_ENUM(NSInteger,UniPropertyEncoding) {
    UniPropertyEncodingUnknown      = 0,
    UniPropertyEncodingReadonly     = 1 << 0,
    UniPropertyEncodingCopy         = 1 << 1,
    UniPropertyEncodingRetain       = 1 << 2,
    UniPropertyEncodingNonatomic    = 1 << 3,
    UniPropertyEncodingWeak         = 1 << 4,
    UniPropertyEncodingCustomGetter = 1 << 5,
    UniPropertyEncodingCustomSetter = 1 << 6,
    UniPropertyEncodingDynamic      = 1 << 7
};

typedef NS_ENUM(NSUInteger,UniColumnType){
    UniColumnTypeUnknown,
    UniColumnTypeInteger,
    UniColumnTypeReal,
    UniColumnTypeText,
    UniColumnTypeBlob
};

@class UniProperty;

@interface UniClass : NSObject

@property (readonly) Class        cls;
@property (readonly) NSString     *name;
@property (readonly) NSDictionary *propertyDict;
@property (readonly) NSArray      *propertyArr;
@property (readonly) NSArray      *jsonPropertyArr;
@property (readonly) NSArray      *dbPropertyArr;
@property (readonly) UniProperty  *primaryProperty;
@property (readonly) NSString     *dbSelectSql;
@property (readonly) NSString     *dbUpdateSql;
@property (readonly) NSString     *dbInsertSql;
@property (readonly) BOOL         isConformsToUniJSON;
@property (readonly) BOOL         isConformsToUniMM;
@property (readonly) BOOL         isConformsToUniDB;
@property (readonly) NSMapTable   *mm;
@property (readonly) UniDB        *db;

+ (instancetype)classWithClass:(Class)cls;

- (void)sync:(void(^)(void))block;

- (BOOL)open:(NSString*)file error:(NSError**)error;

@end

@interface UniProperty : NSObject

@property (readonly) NSString                 *name;
@property (readonly) UniTypeEncoding          typeEncoding;
@property (readonly) Class                    cls;
@property (readonly) SEL                      setter;
@property (readonly) SEL                      getter;
@property (readonly) NSArray                  *jsonKeyPathArr;
@property (readonly) UniColumnType            columnType;
@property (readonly) UniBlockValueTransformer *jsonValueTransformer;
@property (readonly) UniBlockValueTransformer *dbValueTransformer;

@end
