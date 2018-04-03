//
//  ViewController.m
//  Example
//
//  Created by emsihyo on 2018/2/26.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import "ViewController.h"
@import Unicorn;
#import "Article.h"
#import <sys/time.h>

#ifndef XXXXXX
#define XXXXXX

#define uni_array(...) [[[@#__VA_ARGS__ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString: @" " withString: @""] componentsSeparatedByString:@","]
#define uni_package(x,...) @#x:uni_array(__VA_ARGS__)
#define uni_dictionary(...) @{__VA_ARGS__}
#endif

@interface ViewController ()

@end

static inline void Benchmark(void (^block)(void), void (^complete)(double ms)) {
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    complete(ms);
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]);
    NSString *json=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Article" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *article=[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    Benchmark(^{
        Article *a=[Article uni_parseJson:article];
        NSLog(@"%@",[a uni_jsonDictionary]);
    }, ^(double ms) {
        NSLog(@"%.2f ms",ms);
    });
 
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
