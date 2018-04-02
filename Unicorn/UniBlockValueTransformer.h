//
//  UniBlockValueTransformer.h
//  Unicorn
//
//  Created by emsihyo on 2018/4/2.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UniBlockValueTransformer : NSValueTransformer

+ (instancetype)transformerWithForward:(id(^)(id value))forward reverse:(id(^)(id value))reverse;

@end
