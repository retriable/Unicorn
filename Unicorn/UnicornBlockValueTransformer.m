//
//  UnicornBlockValueTransformer.m
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.


#import "UnicornBlockValueTransformer.h"

@interface UnicornBlockValueTransformer ()

@property (nonatomic, copy) id (^forward)(id);
@property (nonatomic, copy) id (^reverse)(id);

@end

@implementation UnicornBlockValueTransformer

+ (instancetype)transformerWithForward:(id (^)(id))forward reverse:(id (^)(id))reverse {
    UnicornBlockValueTransformer *valueTransformer = [[UnicornBlockValueTransformer alloc] init];
    valueTransformer.forward = forward;
    valueTransformer.reverse = reverse;
    return valueTransformer;
}

#pragma mark--
#pragma mark-- override

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    return self.forward ? self.forward(value) : value;
}

- (id)reverseTransformedValue:(id)value {
    return self.reverse ? self.reverse(value) : value;
}

@end
