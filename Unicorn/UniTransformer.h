//
//  UniTransformer.h
//  Unicorn
//
//  Created by emsihyo on 2018/9/10.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UniTransformer : NSValueTransformer

+ (instancetype)transformerWithForward:(id(^)(id value))forward backward:(id(^)(id value))backward;

@end
