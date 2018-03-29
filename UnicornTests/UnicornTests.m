//
//  UnicornTests.m
//  UnicornTests
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Article.h"
@import Unicorn;

@interface UnicornTests : XCTestCase

@end

@implementation UnicornTests

- (void)setUp {
    [super setUp];
    UniClass *cls =  [UniClass classWithClass:Article.class];
    NSLog(@"****\n\n%@\n\n****",NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject);

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
 
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    NSMutableArray *arr=[NSMutableArray array];
    for (int i=0;i<20;i++){
        Article *a=[[Article alloc]init];
        a.id=i;
        a.title=[NSString stringWithFormat:@"article:%@",@(i)];
        Author *au=[[Author alloc]init];
        au.id=i;
        au.name=[NSString stringWithFormat:@"author:%@",@(i)];
        User *u =[[User alloc]init];
        u.id=i;
        u.nickname=[NSString stringWithFormat:@"user:%@",@(i)];
        au.user=u;
        a.author=au;
        [arr addObject:a];
    }
    [self measureBlock:^{
        [Article uni_update:arr];
        // Put the code you want to measure the time of here.
    }];
}

@end
