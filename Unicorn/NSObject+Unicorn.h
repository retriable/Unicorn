//
//  NSObject+Unicorn.h
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.

#import <Foundation/Foundation.h>

@interface NSObject (Unicorn)
@property (assign)bool uni_merged;
/**
 return models of this class whitch unique value is equal to param value

 @param value unique value
 @return model or nil
 */
+ (_Nullable instancetype)uni_modelWithValue:(_Nullable id)value;

/**
 save model
 
 @return a unique instance
 */
- (_Nonnull instancetype)uni_save;

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

#ifdef UNI_DB_AUTO_UPDATE_TIMESTAMP
+ (void)uni_deleteBeforeDate:(NSDate *)date;
#endif

@end
