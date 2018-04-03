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
                          uni_package(uid,id),
                          uni_package(headimgurl,headimgurl),
                          uni_package(intro,intro),
                          uni_package(mail,mail),
                          uni_package(nickname,nickname),
                          uni_package(phone,phone),
                          uni_package(sex,sex)
                          );
}

+ (NSString*)uni_primary{
    return uni_string(uid);
}

+ (NSArray *)uni_columns{
    return uni_array(uid,headimgurl,intro,mail,nickname,phone,sex);
}
@end
