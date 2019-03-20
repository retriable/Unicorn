//
//  UniTransformer.m
//  Unicorn
//
//  Created by retriable on 2018/9/10.
//  Copyright © 2018年 retriable. All rights reserved.
//

#import "UniTransformer.h"

@interface UniTransformer ()

@property (nonatomic,copy)id(^forward)(id value);
@property (nonatomic,copy)id(^backward)(id value);

@end

@implementation UniTransformer

+ (instancetype)transformerWithForward:(id(^)(id value))forward backward:(id(^)(id value))backward{
    UniTransformer *v=[[UniTransformer alloc]init];
    v.forward = forward;
    v.backward = backward;
    return v;
}

- (id)transformedValue:(id)value{
    if (self.forward) return self.forward(value);
    return nil;
}

- (id)reverseTransformedValue:(id)value{
    if (self.backward) return self.backward(value);
    return nil;
}

- (BOOL)allowsReverseTransformation{
    return YES;
}

@end
