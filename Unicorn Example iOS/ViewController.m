//
//  ViewController.m
//  Unicorn Example iOS
//
//  Created by emsihyo on 2018/5/8.
//  Copyright © 2018 emsihyo. All rights reserved.
//


#import "Article.h"
#import "Benchmark.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"****\n\n%@\n\n****",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]);
    NSString *s=[NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"article" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *ss=[NSMutableArray array];
    for (int i=0;i<20;i++){
        [ss addObject:[NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil]];
    }
    benchmark(^{
        [Article uni_parseJson:ss];
    }, ^(int ms) {
        NSLog(@"%d ms",ms);
    });
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end