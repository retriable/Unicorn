//
//  UniTransformer.h
//  Unicorn
//
//  Created by retriable on 2018/9/10.
//  Copyright © 2018年 retriable. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UniTransformer : NSValueTransformer

+ (instancetype)transformerWithForward:(id _Nullable(^)(id _Nullable value))forward backward:(id _Nullable(^)(id _Nullable value))backward;

NS_ASSUME_NONNULL_END
@end
