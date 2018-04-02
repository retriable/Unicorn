//
//  NSObject+Uni.h
//  Unicorn
//
//  Created by emsihyo on 2018/2/24.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Uni)
/**
 reverse model to json dictionary
 */
@property (readonly)NSDictionary * uni_jsonDictionary;
/**
 reverse models to array of json dictionary

 @param models models
 @return array of json dictionary
 */
+ (NSArray*)uni_jsonDictionaryFromModels:(NSArray*)models;
/**
 reverse model to json string
 */
@property (readonly)NSString * uni_jsonString;
/**
 User *user = [User uni_parseJson:jsonString]
 User *user = [User uni_parseJson:jsonDictionary]
 NSArray<User*> *users = [User uni_parseJson:jsonStringArray]
 NSArray<User*> *users = [User uni_parseJson:jsonDictionaryArray]

 @param json NSString NSDictionary NSArray<NSString*>  NSArray<NSDictionary*>
 @return model or models or nil
 */
+ (id)uni_parseJson:(id)json;
/**
 query one by primary value
 User user = [User uni_queryOne:@(10086)]
 
 @param primary primary value.
 @return model or nil
 */
+ (id)uni_queryOne:(id)primary;
/**
 query models from sql after "where"
 NSArray<User*> *users = [User uni_query:@"age<?" args:@[@(28)]];
 
 @param sql sql after "where"
 @param args args
 @return models
 */
+ (NSArray*)uni_query:(NSString*)sql args:(NSArray*)args;
/**
 update model
 user = [user uni_update]

 @return model did updated
 */
- (id)uni_update;
/**
 update models
 users = [User uni_update:users]
 
 @param models models to update
 @return models updated
 */
+ (NSArray*)uni_update:(NSArray*)models;
/**
 open a custom db file for current model class
 [User uni_open:file1 error:nil]
 [Author uni_open:file2 error:nil]

 @param file file path
 @param error error
 @return success or not 
 */
+ (BOOL)uni_open:(NSString*)file error:(NSError**)error;

@end

