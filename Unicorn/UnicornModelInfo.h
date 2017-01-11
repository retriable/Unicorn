//
//  UnicornModelInfo.h
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.


#import <Foundation/Foundation.h>
#import "UnicornMapTable.h"
#import "UnicornDatabase.h"
#import <objc/runtime.h>

#ifndef UNI_DB_MODEL_DB_PATH
#define UNI_DB_MODEL_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Caches/Unicorn.sqlite"]
#endif

#ifndef uni_DB_AUTO_UPDATE_TIMESTAMP
//#define uni_DB_AUTO_UPDATE_TIMESTAMP 
#endif
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

typedef NS_ENUM (NSInteger, UNPropertyEncodingType) {
    UNPropertyEncodingTypeUnsupportedCType = 0,
    UNPropertyEncodingTypeBool = 1 << 1,
    UNPropertyEncodingTypeInt8 = 1 << 2,
    UNPropertyEncodingTypeUInt8 = 1 << 3,
    UNPropertyEncodingTypeInt16 = 1 << 4,
    UNPropertyEncodingTypeUInt16 = 1 << 5,
    UNPropertyEncodingTypeInt32 = 1 << 6,
    UNPropertyEncodingTypeUInt32 = 1 << 7,
    UNPropertyEncodingTypeInt64 = 1 << 8,
    UNPropertyEncodingTypeUInt64 = 1 << 9,
    UNPropertyEncodingTypeFloat = 1 << 10,
    UNPropertyEncodingTypeDouble = 1 << 11,
    UNPropertyEncodingTypeSupportedCType = UNPropertyEncodingTypeBool | UNPropertyEncodingTypeInt8 | UNPropertyEncodingTypeUInt8 | UNPropertyEncodingTypeInt16 | UNPropertyEncodingTypeUInt16 | UNPropertyEncodingTypeInt32 | UNPropertyEncodingTypeUInt32 | UNPropertyEncodingTypeInt64 | UNPropertyEncodingTypeUInt64 | UNPropertyEncodingTypeFloat | UNPropertyEncodingTypeDouble,

    UNPropertyEncodingTypeUnsupportedObject = 1 <<12,
    UNPropertyEncodingTypeNSString = 1 << 13,
    UNPropertyEncodingTypeNSNumber = 1 << 14,
    UNPropertyEncodingTypeNSURL = 1 << 15,
    UNPropertyEncodingTypeNSData = 1 << 16,
    UNPropertyEncodingTypeSupportedObject = UNPropertyEncodingTypeNSString | UNPropertyEncodingTypeNSNumber | UNPropertyEncodingTypeNSURL|UNPropertyEncodingTypeNSData,
    UNPropertyEncodingTypeObject = UNPropertyEncodingTypeSupportedObject|UNPropertyEncodingTypeUnsupportedObject
};

@class UNPropertyInfo;

@interface UnicornClassInfo : NSObject

@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, copy, readonly) NSString *className;
@property (nonatomic, strong, readonly) NSDictionary *propertyInfosByPropertyName;
@property (nonatomic, strong, readonly) NSArray *propertyNames;
@property (nonatomic, strong, readonly) NSArray *propertyInfos;
@property (nonatomic, copy, readonly) NSString *mtUniquePropertyName;
@property (nonatomic, strong, readonly) UNPropertyInfo *mtUniquePropertyInfo;
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

@interface UNPropertyInfo : NSObject

@property (nonatomic, copy, readonly) NSString *propertyName;
@property (nonatomic, copy, readonly) NSString *ivarName;
@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, assign, readonly) Class parentClass;
@property (nonatomic, assign, readonly) UNPropertyEncodingType encodingType;
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
