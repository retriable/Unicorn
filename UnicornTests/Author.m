//
//  Author.m
//  UnicornTests
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import "Author.h"
@implementation Author

+ (NSDictionary *)uni_keyPaths{
    return uni_dictionary(
                          uni_package(id,id),
                          uni_package(name,name),
                          uni_package(user,user)
                          );
}

+ (NSString*)uni_primary{
    return uni_string(id);
}

+ (NSArray*)uni_columns{
    return uni_array(id,name,user);
}

@end
