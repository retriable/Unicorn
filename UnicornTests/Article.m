//
//  Article.m
//  UnicornTests
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import "Article.h"

@implementation Article

+ (NSDictionary *)uni_keyPaths{
    return uni_keyPaths(uni_d(id,id),uni_d(title,title),uni_d(author,author),nil);
}

+ (NSString*)uni_primary{
    return uni_s(id);
}

+ (NSArray*)uni_columns{
    return uni_a(id,title,author);
}

@end
