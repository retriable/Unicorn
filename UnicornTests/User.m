//
//  User.m
//  UnicornTests
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSDictionary*)uni_keyPaths{
    return uni_keyPaths(uni_d(id,id),uni_d(name,name),uni_d(age,age),nil);
}

+ (NSString*)uni_primary{
    return uni_s(id);
}

+ (NSArray*)uni_columns{
    return uni_a(id,name,age);
}

@end
