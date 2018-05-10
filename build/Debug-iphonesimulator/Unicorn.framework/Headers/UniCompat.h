//
//  UniCompat.h
//  Unicorn
//
//  Created by emsihyo on 2018/4/22.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#ifndef UniCompat_h
#define UniCompat_h

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH

#import <UIKit/UIKit.h>

typedef CGPoint NSPoint;
typedef CGSize NSSize;
typedef CGRect NSRect;
typedef UIEdgeInsets NSEdgeInsets;

#endif

#endif /* UniCompat_h */
