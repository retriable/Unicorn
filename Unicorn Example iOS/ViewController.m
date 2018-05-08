//
//  ViewController.m
//  Unicorn Example iOS
//
//  Created by emsihyo on 2018/5/8.
//  Copyright © 2018 emsihyo. All rights reserved.
//

#import "Article.h"

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"****\n\n%@\n\n****",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]);
    Article *article=[[Article alloc]init];
    [article uni_update];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
