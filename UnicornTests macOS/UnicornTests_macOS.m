//
//  UnicornTests_macOS.m
//  UnicornTests macOS
//
//  Created by emsihyo on 2018/5/8.
//  Copyright © 2018 emsihyo. All rights reserved.
//

#import <XCTest/XCTest.h>



@interface UnicornTests_macOS : XCTestCase

@end

@implementation UnicornTests_macOS

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSEdgeInsets insets=NSEdgeInsetsMake(1234.5, 1,100,-123);
    NSString *string=UNI_NSStringFromEdgeInsets(insets);
    NSLog(@"%@",string);
    insets=UNI_NSEdgeInsetsFromString(string);
    NSLog(@"%@",UNI_NSStringFromEdgeInsets(insets));
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
