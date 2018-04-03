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

typedef NS_OPTIONS(NSUInteger, UniEncodingType) {
    UniEncodingTypeMask                 = 0xFF,
    UniEncodingTypeUnknown              = 0,
    UniEncodingTypeBool                 = 1,
    UniEncodingTypeInt8                 = 2,
    UniEncodingTypeUInt8                = 3,
    UniEncodingTypeInt16                = 4,
    UniEncodingTypeUInt16               = 5,
    UniEncodingTypeInt32                = 6,
    UniEncodingTypeUInt32               = 7,
    UniEncodingTypeInt64                = 8,
    UniEncodingTypeUInt64               = 9,
    UniEncodingTypeFloat                = 10,
    UniEncodingTypeDouble               = 11,
    UniEncodingTypeLongDouble           = 12,
    UniEncodingTypeNSString             = 13,
    UniEncodingTypeNSURL                = 14,
    UniEncodingTypeNSNumber             = 15,
    UniEncodingTypeNSDate               = 16,
    UniEncodingTypeNSData               = 17,
    UniEncodingTypeNSObject             = 18,

    UniEncodingTypeQualifierMask        = 0xFF00,
    UniEncodingTypeQualifierConst       = 1 << 8,
    UniEncodingTypeQualifierIn          = 1 << 9,
    UniEncodingTypeQualifierInout       = 1 << 10,
    UniEncodingTypeQualifierOut         = 1 << 11,
    UniEncodingTypeQualifierBycopy      = 1 << 12,
    UniEncodingTypeQualifierByref       = 1 << 13,
    UniEncodingTypeQualifierOneway      = 1 << 14,

    UniEncodingTypePropertyMask         = 0xFF0000,
    UniEncodingTypePropertyReadonly     = 1 << 16,
    UniEncodingTypePropertyCopy         = 1 << 17,
    UniEncodingTypePropertyRetain       = 1 << 18,
    UniEncodingTypePropertyNonatomic    = 1 << 19,
    UniEncodingTypePropertyWeak         = 1 << 20,
    UniEncodingTypePropertyCustomGetter = 1 << 21,
    UniEncodingTypePropertyCustomSetter = 1 << 22,
    UniEncodingTypePropertyDynamic      = 1 << 23,
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

@property (readonly) NSArray      *propertyArr;
@property (readonly) NSDictionary *propertyDict;
@property (readonly) NSArray      *jsonPropertyArr;

@property (readonly) UniProperty  *primaryProperty;

@property (readonly) NSArray      *dbPropertyArr;
@property (readonly) NSString     *dbSelectSql;
@property (readonly) NSString     *dbUpdateSql;
@property (readonly) NSString     *dbInsertSql;

@property (readonly) NSMapTable   *mm;
@property (readonly) UniDB        *db;

@property (readonly) BOOL         isConformsToUniJSON;
@property (readonly) BOOL         isConformsToUniMM;
@property (readonly) BOOL         isConformsToUniDB;


+ (instancetype)classWithClass:(Class)cls;

- (void)sync:(void(^)(void))block;

- (BOOL)open:(NSString*)file error:(NSError**)error;

@end

@interface UniProperty : NSObject

@property (readonly) NSString                 *name;
@property (readonly) UniEncodingType          encodingType;
@property (readonly) Class                    cls;
@property (readonly) SEL                      setter;
@property (readonly) SEL                      getter;
@property (readonly) NSArray                  *jsonKeyPathArr;
@property (readonly) UniBlockValueTransformer *jsonValueTransformer;
@property (readonly) NSNumberFormatter        *numberFormatter;
@property (readonly) UniColumnType            columnType;
@property (readonly) UniBlockValueTransformer *dbValueTransformer;

@end
