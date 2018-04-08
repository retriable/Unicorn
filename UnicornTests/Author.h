//
//  Author.h
//  UnicornTests
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Author : NSObject<UniJSON,UniDB>

@property (assign)UInt64 id;
@property (copy)NSString *name;
@property (strong)User *user;

@end
