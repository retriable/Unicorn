//
//  User.m
//  Unicorn
//
//  Created by retriable on 2018/5/3.
//  Copyright © 2018 retriable. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSDictionary * _Nonnull)uni_keyPaths{
    return @{
             @"id":@"id",
             @"nickname":@[@"nickname",@"name"],
             @"age":@"age"
             };
}

+ (NSString * _Nonnull)uni_primaryKey {
    return @"id";
}

+ (NSArray * _Nonnull)uni_columns{
    return @[@"id",@"nickname",@"age"];
}

@end
