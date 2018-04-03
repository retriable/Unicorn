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

@property (copy)NSString *headimgurl;
@property (copy)NSString *uid;
@property (copy)NSString  *intro;
@property (copy)NSString  *mail;
@property (copy)NSString  *nickname;
@property (copy)NSString  *phone;
@property (assign)NSInteger  sex;

@end
