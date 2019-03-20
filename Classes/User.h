//
//  User.h
//  Unicorn
//
//  Created by retriable on 2018/5/3.
//  Copyright © 2018 retriable. All rights reserved.
//

@import Unicorn;

#import <Foundation/Foundation.h>

@interface User : NSObject<UniJSON,UniMM,UniDB>

@property (nonatomic,assign) UInt64   id;
@property (nonatomic,strong) NSString *nickname;
@property (nonatomic,assign) UInt8    age;

@end
