//
//  InterfaceController.m
//  Unicorn Example watchOS Extension
//
//  Created by retriable on 2018/5/9.
//  Copyright © 2018 retriable. All rights reserved.
//

#import "InterfaceController.h"
#import "Article.h"
//#import "Benchmark.h"

@interface InterfaceController ()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSLog(@"****\n\n%@\n\n****",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]);
    NSString *s=[NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"article" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *ss=[NSMutableArray array];
    for (int i=0;i<1000;i++){
        [ss addObject:[NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil]];
    }
//    benchmark(^{
//        [Article uni_parseJson:ss];
//    }, ^(int ms) {
//        NSLog(@"%d ms",ms);
//    });
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



