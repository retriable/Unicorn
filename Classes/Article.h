//
//  Article.h
//  Unicorn
//
//  Created by emsihyo on 2018/5/3.
//  Copyright © 2018 emsihyo. All rights reserved.
//

@import Unicorn;

#import <Foundation/Foundation.h>

#import "Comment.h"
#import "User.h"

@interface Article : NSObject<UniJSON,UniMM,UniDB>

@property (nonatomic,assign) UInt64   id;
@property (nonatomic,strong) User     *author;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSArray <Comment*> *comments;

@end
