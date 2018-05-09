//
//  Benchmark.h
//  Unicorn
//
//  Created by emsihyo on 2018/5/9.
//  Copyright © 2018 emsihyo. All rights reserved.
//

#ifndef Benchmark_h
#define Benchmark_h

#import <QuartzCore/QuartzCore.h>

static void benchmark(void(^block)(void),void(^ms)(int ms)){
    CFTimeInterval begin = CACurrentMediaTime();
    block();
    ms((CACurrentMediaTime()-begin)*1000);
}

#endif /* Benchmark_h */
