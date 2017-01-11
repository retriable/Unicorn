//
//  UnicornBlockValueTransformer.h
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.

#import <Foundation/Foundation.h>

@interface UnicornBlockValueTransformer : NSValueTransformer

+ (instancetype)transformerWithForward:(id (^)(id value))forward reverse:(id (^)(id value))reverse;

@end
