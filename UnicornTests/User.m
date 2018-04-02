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
    return uni_dictionary(
                          uni_package(id,id),
                          uni_package(name,name,info.name),
                          uni_package(age,age,info.age)
                          );
}

+ (NSString*)uni_primary{
    return uni_string(id);
}

+ (NSArray*)uni_columns{
    return uni_array(id,name,age);
}

@end
