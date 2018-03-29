//
//  UniProtocol.h
//  Unicorn
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UniClass.h"

@protocol UniJSON<NSObject>

+ (NSDictionary<NSString*,NSArray*> *_Nonnull)uni_keyPaths;

@optional

+ (NSValueTransformer * _Nullable)uni_jsonValueTransformer:(NSString * _Nonnull)propertyName;

@end

@protocol UniMM <NSObject>

+ (NSString * _Nonnull)uni_primary;

@end

@protocol UniDB <UniMM>

+ (NSArray<NSString*> * _Nonnull)uni_columns;

@optional

+ (NSValueTransformer * _Nullable)uni_dbValueTransformer:(NSString * _Nonnull)propertyName;

+ (UniColumnType)uni_columnType:(NSString * _Nonnull)propertyName;

+ (NSArray<NSString*> * _Nonnull)uni_indexes;

@end
