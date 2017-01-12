//
//  UnicornModelInfo.h
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.


#import <Foundation/Foundation.h>
#import "UnicornMapTable.h"
#import "UnicornDatabase.h"
#import <objc/runtime.h>


extern NSString *const uni_on_update_timestamp;

@protocol UnicornJSON<NSObject>

+ (NSDictionary *)uni_jsonKeyPathsByPropertyName;

@optional

+ (NSValueTransformer *)uni_jsonValueTransformerForPropertyName:(NSString *)propertyName;

@end
@protocol UnicornMT <NSObject>

+ (NSString *)uni_mtUniquePropertyName;

@end

@protocol UnicornDB <UnicornMT>

+ (NSArray *)uni_dbColumnNamesInPropertyName;

@optional

+ (UnicornDatabaseTransformer *)uni_dbValueTransformerForPropertyName:(NSString *)propertyName;

+ (NSArray *)uni_dbIndexesInPropertyName;

@end

typedef NS_ENUM (NSInteger, UnicornPropertyEncodingType) {
    UnicornPropertyEncodingTypeUnsupportedCType = 0,
    UnicornPropertyEncodingTypeBool = 1 << 1,
    UnicornPropertyEncodingTypeInt8 = 1 << 2,
    UnicornPropertyEncodingTypeUInt8 = 1 << 3,
    UnicornPropertyEncodingTypeInt16 = 1 << 4,
    UnicornPropertyEncodingTypeUInt16 = 1 << 5,
    UnicornPropertyEncodingTypeInt32 = 1 << 6,
    UnicornPropertyEncodingTypeUInt32 = 1 << 7,
    UnicornPropertyEncodingTypeInt64 = 1 << 8,
    UnicornPropertyEncodingTypeUInt64 = 1 << 9,
    UnicornPropertyEncodingTypeFloat = 1 << 10,
    UnicornPropertyEncodingTypeDouble = 1 << 11,
    UnicornPropertyEncodingTypeSupportedCType = UnicornPropertyEncodingTypeBool | UnicornPropertyEncodingTypeInt8 | UnicornPropertyEncodingTypeUInt8 | UnicornPropertyEncodingTypeInt16 | UnicornPropertyEncodingTypeUInt16 | UnicornPropertyEncodingTypeInt32 | UnicornPropertyEncodingTypeUInt32 | UnicornPropertyEncodingTypeInt64 | UnicornPropertyEncodingTypeUInt64 | UnicornPropertyEncodingTypeFloat | UnicornPropertyEncodingTypeDouble,

    UnicornPropertyEncodingTypeUnsupportedObject = 1 <<12,
    UnicornPropertyEncodingTypeNSString = 1 << 13,
    UnicornPropertyEncodingTypeNSNumber = 1 << 14,
    UnicornPropertyEncodingTypeNSURL = 1 << 15,
    UnicornPropertyEncodingTypeNSData = 1 << 16,
    UnicornPropertyEncodingTypeSupportedObject = UnicornPropertyEncodingTypeNSString | UnicornPropertyEncodingTypeNSNumber | UnicornPropertyEncodingTypeNSURL|UnicornPropertyEncodingTypeNSData,
    UnicornPropertyEncodingTypeObject = UnicornPropertyEncodingTypeSupportedObject|UnicornPropertyEncodingTypeUnsupportedObject
};

@class UnicornPropertyInfo;

@interface UnicornClassInfo : NSObject

@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, copy, readonly) NSString *className;
@property (nonatomic, strong, readonly) NSDictionary *propertyInfosByPropertyName;
@property (nonatomic, strong, readonly) NSArray *propertyNames;
@property (nonatomic, strong, readonly) NSArray *propertyInfos;
@property (nonatomic, copy, readonly) NSString *mtUniquePropertyName;
@property (nonatomic, strong, readonly) UnicornPropertyInfo *mtUniquePropertyInfo;
@property (nonatomic, strong, readonly) NSArray *dbPropertyInfos;
@property (nonatomic, strong, readonly) NSArray *dbIndexes;
@property (nonatomic, copy, readonly) NSString *dbSelectSql;
@property (nonatomic, copy, readonly) NSString *dbUpdateSql;
@property (nonatomic, copy, readonly) NSString *dbInsertSql;
@property (nonatomic, strong, readonly) NSArray *jsonPropertyInfos;

- (instancetype)initWithClass:(Class)cls;
- (void)setMt:(UnicornMapTable *)mt db:(UnicornDatabase *)db;
- (void)sync:(void (^)(UnicornMapTable *mt, UnicornDatabase *db))block;

@end

@interface UnicornPropertyInfo : NSObject

@property (nonatomic, copy, readonly) NSString *propertyName;
@property (nonatomic, copy, readonly) NSString *ivarName;
@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, assign, readonly) Class parentClass;
@property (nonatomic, assign, readonly) UnicornPropertyEncodingType encodingType;
@property (nonatomic, assign, readonly) SEL setter;
@property (nonatomic, assign, readonly) SEL getter;
@property (nonatomic, assign, readonly) bool isConformingToUnicornJSONModel;
@property (nonatomic, assign, readonly) bool isConformingToUnicornMT;
@property (nonatomic, assign, readonly) bool isConformingToUnicornDB;
@property (nonatomic, strong, readonly) NSNumberFormatter *numberFormatter;

@property (nonatomic, assign, readonly) UnicornDatabaseColumnType dbColumnType;
@property (nonatomic, assign, readonly) UnicornBlockValueTransformer *dbValueTransformer;

@property (nonatomic, strong, readonly) NSString *jsonKeyPathInString;
@property (nonatomic, strong, readonly) NSArray *jsonKeyPathInArray;
@property (nonatomic, strong, readonly) NSValueTransformer *jsonValueTransformer;

- (instancetype)initWithProperty:(objc_property_t)property parentClass:(Class)parentClass;

@end

@interface NSObject (UnicornInfo)

+ (UnicornClassInfo *)uni_classInfo;

@end

@interface NSDictionary (Unicorn)

- (id)uni_valueForKeyPaths:(NSArray *)keyPaths;

@end
