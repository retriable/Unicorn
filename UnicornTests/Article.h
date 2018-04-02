//
//  Article.h
//  UnicornTests
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Author.h"

@interface Article : NSObject<UniJSON,UniDB>

@property (assign)UInt64 id;
@property (copy)NSString *title;
@property (strong)NSArray *authors;

@end
