//
//  UnicornTests_iOS.m
//  UnicornTests iOS
//
//  Created by emsihyo on 2018/5/8.
//  Copyright © 2018 emsihyo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Article.h"

@interface UnicornTests_iOS : XCTestCase

@end

@implementation UnicornTests_iOS

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSLog(@"****\n\n%@\n\n****",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]);
    Article *article=[[Article alloc]init];
    [article uni_update];
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
