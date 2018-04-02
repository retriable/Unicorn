//
//  UniBlockValueTransformer.m
//  Unicorn
//
//  Created by emsihyo on 2018/4/2.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import "UniBlockValueTransformer.h"
@interface UniBlockValueTransformer()

@property (nonatomic,strong)NSArray *anonymousClassNames;
@property (nonatomic,copy) id (^forward)(id value);
@property (nonatomic,copy) id (^reverse)(id value);

@end

@implementation UniBlockValueTransformer

+ (instancetype)transformerWithAnonymousClassNames:(NSArray*)anonymousClassNames forward:(id(^)(id value))forward reverse:(id(^)(id value))reverse{
    UniBlockValueTransformer *valueTransformer=[[UniBlockValueTransformer alloc]init];
    valueTransformer.forward = forward;
    valueTransformer.reverse = reverse;
    return valueTransformer;
}

+ (BOOL)allowsReverseTransformation{
    return YES;
}

- (id)transformedValue:(id)value{
    return self.forward(value);
}

- (id)reverseTransformedValue:(id)value{
    return self.reverse(value);
}


@end
