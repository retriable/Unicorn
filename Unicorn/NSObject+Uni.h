//
//  NSObject+Uni.h
//  Unicorn
//
//  Created by emsihyo on 2018/2/24.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UniCompat.h"
#import "UniTransformer.h"

typedef NS_ENUM(NSUInteger,UniColumnType){
    UniColumnTypeAutomatically,
    UniColumnTypeInteger,
    UniColumnTypeReal,
    UniColumnTypeText,
    UniColumnTypeBlob
};

#if TARGET_OS_IOS || TARGET_OS_TV


NSString * _Nonnull UNI_NSStringFromCATransform3D(CATransform3D transform3D);

CATransform3D UNI_CATransform3DFromNSString(NSString * _Nullable string);

#endif

#if TARGET_OS_OSX

NSString* _Nonnull UNI_NSStringFromNSEdgeInsets(NSEdgeInsets edgeInsets);
NSEdgeInsets UNI_NSEdgeInsetsFromNSString(NSString * _Nullable string);

#endif

@protocol UniJSON<NSObject>

+ (NSDictionary<NSString*,NSString*> *_Nonnull)uni_keyPaths;

@optional

+ (UniTransformer *_Nullable)uni_jsonTransformer:(NSString * _Nonnull)propertyName;

@end

@protocol UniMM <NSObject>

+ (NSString * _Nonnull)uni_primaryKey;

@optional

+ (NSArray<NSString*> * _Nonnull)uni_synchronizedClasses;

@end

@protocol UniDB <NSObject>

+ (NSString * _Nonnull)uni_primaryKey;

+ (NSArray<NSString*> * _Nonnull)uni_columns;

@optional

+ (NSArray<Class> * _Nonnull)uni_synchronizedClasses;

+ (UniTransformer *_Nullable)uni_dbTransformer:(NSString * _Nonnull)propertyName;

+ (UniColumnType)uni_columnType:(NSString * _Nonnull)propertyName;

+ (NSArray<NSString*>*_Nonnull)uni_indexes;

- (BOOL) uni_nonPersistent;

+ (NSArray<NSString*>*_Nonnull)uni_automaticalUpdatedPropertynames;

@end


@interface NSObject (Uni)

/**
 reverse model to json object
 */
@property (readonly)NSDictionary * _Nullable uni_jsonObject;

/**
 reverse model to json string
 */
@property (readonly)NSString * _Nullable uni_jsonString;

/**
 reverse models to array of json object
 
 @param models models
 @return array of json object
 */
+ (NSArray* _Nullable)uni_jsonObjectsFromModels:(NSArray* _Nullable)models;

/**
 User *user = [User uni_parseJson:jsonString]
 User *user = [User uni_parseJson:jsonDictionary]
 NSArray<User*> *users = [User uni_parseJson:jsonStringArray]
 NSArray<User*> *users = [User uni_parseJson:jsonDictionaryArray]

 @param json NSString NSDictionary NSArray<NSString*>  NSArray<NSDictionary*>
 @return model or models or nil
 */
+ (id _Nullable)uni_parseJson:(id _Nullable)json;

/**
 query one by primary value
 User user = [User uni_queryOne:@(10086)]
 
 @param primary primary value.
 @return model or nil
 */
+ (id _Nullable)uni_queryOne:(id _Nullable)primary;

/**
 query models
 NSArray<User*> *users = [User uni_query:@"WHERE age<?" args:@[@(28)]];
 
 @param sql sql after "SELECT * FROM 'TABLE' ",if nil,select all.
 @param args args
 @return models
 */
+ (NSArray* _Nullable)uni_query:(NSString* _Nullable)sql args:(NSArray* _Nullable)args;

/**
 update model
 user = [user uni_update]

 @return model updated
 */
- (id _Nullable)uni_update;

/**
 update models
 users = [User uni_update:users]
 
 @param models models to update
 @return models updated
 */
+ (NSArray* _Nullable)uni_update:(NSArray* _Nullable)models;

/**
 delete models in database with sql

 @param sql sql after "DELETE FROM ",if nil,will delete all
 @param args args
 @return success or failure
 */
+ (BOOL)uni_delete:(NSString* _Nullable)sql args:(NSArray* _Nullable)args;

/**
 delete models updated before date

 @return success or failure
 */
+ (BOOL)uni_deleteBeforeDate:(NSDate * _Nullable)date;

/**
 open a custom db file for current model class
 [User uni_open:file1 error:nil]
 [Author uni_open:file2 error:nil]

 @param file file path
 @param error error
 @return success or not 
 */
+ (BOOL)uni_open:(NSString* _Nullable)file error:(NSError* _Nullable * _Nullable )error;

@end

