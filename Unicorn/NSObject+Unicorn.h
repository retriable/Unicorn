//
//  NSObject+Unicorn.h
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.

#import <Foundation/Foundation.h>
#import "UnicornMapTable.h"
#import "UnicornDatabase.h"

extern NSString * _Nonnull const uni_on_update_timestamp;

@protocol UnicornJSON<NSObject>

+ ( NSDictionary * _Nonnull )uni_jsonKeyPathsByPropertyName;

@optional

+ ( NSValueTransformer  * _Nullable)uni_jsonValueTransformerForPropertyName:(NSString * _Nonnull)propertyName;

@end

@protocol UnicornMT <NSObject>

+ (NSString * _Nonnull)uni_mtUniquePropertyName;

@end

@protocol UnicornDB <UnicornMT>

+ (NSArray * _Nonnull)uni_dbColumnNamesInPropertyName;

@optional

+ (UnicornDatabaseTransformer * _Nullable)uni_dbValueTransformerForPropertyName:(NSString * _Nonnull)propertyName;

+ (NSArray * _Nonnull)uni_dbIndexesInPropertyName;

@end


@interface NSObject (Unicorn)

/**
 if model merged,this value is true
 */
@property (assign)bool uni_merged;
/**
 return models of this class whitch unique value is equal to param value

 @param value unique value
 @return model or nil
 */
+ (instancetype _Nonnull)uni_modelWithValue:(_Nullable id)value;

/**
 save model
 
 @return a unique instance
 */
- (instancetype _Nonnull)uni_save;

/**
 save models
 
 @param models instances of this class
 @return a new array.it contains unique instances
 */
+ ( NSArray *_Nonnull)uni_save:( NSArray * _Nullable )models;

/**
 select models with sql
 
 @param afterWhereSql e.x. uid=?
 @param arguments arguments
 @return unique models
 */

+ (NSArray *_Nonnull)uni_modelsWithAfterWhereSql:(NSString * _Nullable)afterWhereSql arguments:(NSArray *_Nullable)arguments;


/**
 delete models with sql

 @param afterWhereSql afterWhereSql e.x. uid=?,if afterWhereSql nil,delete all
 @param arguments arguments
 */
+ (void)uni_deleteModelsWithAfterWhereSql:(NSString * _Nullable)afterWhereSql arguments:(NSArray *_Nullable)arguments;

/**
 delete models befor date,if date is nil,delete all

 @param date date
 */
+ (void)uni_deleteBeforeDate:(NSDate *_Nullable)date;

/**
 set mt and db for this class

 @param mt new maptable
 @param db new database
 */
+ (void)setMt:(UnicornMapTable * _Nullable)mt db:(UnicornDatabase * _Nullable)db;


@end
