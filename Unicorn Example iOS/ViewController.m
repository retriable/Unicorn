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
    for (int i=0;i<1;i++){
        [ss addObject:[NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil]];
    }
    NSString *s1=@"{1.5,222.3,3.33,.44,  .55 ,0.66  ,7,8,9,10,11,  12  ,223,11,23 ,45 }";
//    NSString *s2=@"[1,2,3,4,5,6,7,8,9,10,11,12]";
//    NSString *s3=@"(1,2,3,4,5,6,7,8,9,10,11,12)";
//    NSString *s4=@"1,2,3,4,5,6,7,8,9,10,11,12";
//    NSString *s5=@"1 2 3 4 5 6 7 8 9 10 11 12";
    
    UNI_CATransform3DFromNSString(s1);
//    NSLog(@"%@",[NSValue valueWithCATransform3D:d]);
//    benchmark(^{
//        NSLog(@"#####:::::%@",[[Article uni_parseJson:ss] uni_jsonObject]);
//    }, ^(int ms) {
//        NSLog(@"%d ms",ms);
//    });
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
