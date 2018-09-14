//
//  UniProperty.h
//  Unicorn
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "UniTransformer.h"
#import "UniDB.h"

typedef NS_ENUM(NSInteger,UniTypeEncoding){
    UniTypeEncodingUnknown,
    UniTypeEncodingVoid,
    UniTypeEncodingBool,
    UniTypeEncodingInt8,
    UniTypeEncodingUInt8,
    UniTypeEncodingInt16,
    UniTypeEncodingUInt16,
    UniTypeEncodingInt32,
    UniTypeEncodingUInt32,
    UniTypeEncodingInt64,
    UniTypeEncodingUInt64,
    UniTypeEncodingFloat,
    UniTypeEncodingDouble,
    UniTypeEncodingLongDouble,
    UniTypeEncodingClass,
    UniTypeEncodingSEL,
    UniTypeEncodingNSRange,
    UniTypeEncodingCATansform3D,
    UniTypeEncodingPoint,
    UniTypeEncodingSize,
    UniTypeEncodingRect,
    UniTypeEncodingEdgeInsets,
    UniTypeEncodingCGVector,
    UniTypeEncodingCGAffineTransform,
    UniTypeEncodingUIOffset,
    UniTypeEncodingNSDirectionalEdgeInsets,
    UniTypeEncodingBlock,
    UniTypeEncodingNSString,
    UniTypeEncodingNSMutableString,
    UniTypeEncodingNSURL,
    UniTypeEncodingNSNumber,
    UniTypeEncodingNSDecimalNumber,
    UniTypeEncodingNSDate,
    UniTypeEncodingNSData,
    UniTypeEncodingNSMutableData,
    UniTypeEncodingNSArray,
    UniTypeEncodingNSMutableArray,
    UniTypeEncodingNSSet,
    UniTypeEncodingNSMutableSet,
    UniTypeEncodingNSDictionary,
    UniTypeEncodingNSMutableDictionary,
    UniTypeEncodingPointer,
    UniTypeEncodingStruct,
    UniTypeEncodingUnion,
    UniTypeEncodingCString,
    UniTypeEncodingCArray,
    UniTypeEncodingNSObject
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

@class UniProperty;

@interface UniClass : NSObject

@property (nonatomic, assign) BOOL         isConformingToUniDB;
@property (nonatomic, assign) BOOL         isConformingToUniJSON;
@property (nonatomic, assign) BOOL         isConformingToUniMM;
@property (nonatomic, assign) Class        cls;
@property (nonatomic, strong) NSArray      *dbPropertyArr;
@property (nonatomic, strong) NSArray      *jsonPropertyArr;
@property (nonatomic, strong) NSArray      *propertyArr;
@property (nonatomic, strong) NSArray      *synchronizedClasses;
@property (nonatomic, strong) NSDictionary *propertyDic;
@property (nonatomic, strong) NSMapTable   *mm;
@property (nonatomic, strong) NSString     *dbDeleteSql;
@property (nonatomic, strong) NSString     *dbInsertSql;
@property (nonatomic, strong) NSString     *dbSelectSql;
@property (nonatomic, strong) NSString     *dbUpdateSql;
@property (nonatomic, strong) NSString     *name;
@property (nonatomic, strong) UniDB        *db;
@property (nonatomic, strong) UniProperty  *primaryProperty;
@property (nonatomic, strong) NSArray      *automaticallyUpdatedPropertynames;
+ (instancetype)classWithClass:(Class)cls;

- (instancetype)initWithClass:(Class)cls;

- (void)prepare;

- (void)sync:(void(^)(void))block;

- (BOOL)open:(NSString*)file error:(NSError**)error;

@end

@interface UniProperty : NSObject

@property (nonatomic,assign) Class               cls;
@property (nonatomic,assign) SEL                 getter;
@property (nonatomic,assign) SEL                 setter;
@property (nonatomic,assign) UniColumnType       columnType;
@property (nonatomic,assign) UniMethodEncoding   methodEncoding;
@property (nonatomic,assign) UniPropertyEncoding propertyEncoding;
@property (nonatomic,assign) UniTypeEncoding     typeEncoding;
@property (nonatomic,strong) NSArray             *jsonKeyPathArr;
@property (nonatomic,strong) NSString            *ivar;
@property (nonatomic,strong) NSString            *name;
@property (nonatomic,strong) UniTransformer      *dbTransformer;
@property (nonatomic,strong) UniTransformer      *jsonTransformer;

@end
