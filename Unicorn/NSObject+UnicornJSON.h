//
//  NSObject+UnicornJSON.h
//  Unicorn
//
//  Created by emsihyo on 2017/1/5.

#import <Foundation/Foundation.h>

@interface NSObject (UnicornJSON)

@property (readonly) NSDictionary * _Nonnull uni_jsonDictionary;

+ (NSArray *_Nonnull)uni_modelsWithJsonDictionaries:(NSArray *_Nullable)jsonDictionaries;

+ (_Nullable instancetype)uni_modelWithJsonDictionary:(NSDictionary *_Nullable)jsonDictionary;

@end
