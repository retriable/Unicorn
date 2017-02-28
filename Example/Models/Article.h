//
//  Article.h
//  OOModel
//
//  Created by emsihyo on 2017/1/9.

#import <Foundation/Foundation.h>
#import "User.h"
@interface Article : NSObject<UnicornJSON,UnicornDB>
@property(assign) UInt64 aid;//unique id
@property(strong) User *author;
@property(copy) NSString *title;
@property(copy) NSString *intro;
@property(assign) UInt8 score;//1-10
@end
