//
//  Unicorn.h
//  Unicorn
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSObject+Uni.h"
#import "UniBlockValueTransformer.h"
#import "UniProtocol.h"

#ifndef uni
#define uni_string(x) @#x
#define uni_array(...) [[[@#__VA_ARGS__ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString: @" " withString: @""] componentsSeparatedByString:@","]
#define uni_package(x,...) @#x:uni_array(__VA_ARGS__)
#define uni_dictionary(...) @{__VA_ARGS__}

#endif


//! Project version number for Unicorn.
FOUNDATION_EXPORT double UnicornVersionNumber;

//! Project version string for Unicorn.
FOUNDATION_EXPORT const unsigned char UnicornVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Unicorn/PublicHeader.h>


