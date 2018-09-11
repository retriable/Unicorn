//
//  Comment.h
//  Unicorn
//
//  Created by emsihyo on 2018/5/3.
//  Copyright © 2018 emsihyo. All rights reserved.
//

@import Unicorn;

#import <Foundation/Foundation.h>

#import "User.h"

@interface Comment : NSObject<UniJSON,UniMM,UniDB>

@property (nonatomic,assign) UInt64   id;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) User     *author;

@property (nonatomic,strong) NSArray <Comment*> *comments;

@end