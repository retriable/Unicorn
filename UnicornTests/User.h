//
//  User.h
//  UnicornTests
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Unicorn;

@interface User : NSObject<UniJSON,UniDB>

@property (copy)NSString *id;
@property (copy)NSString *name;
@property (assign)UInt8  age;

@end
