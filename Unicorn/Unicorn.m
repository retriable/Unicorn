//
//  Unicorn.m
//  Unicorn
//
//  Created by emsihyo on 2018/3/28.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import <Foundation/Foundation.h>

NSDictionary * uni_keyPaths(NSDictionary * dict,...){
    if (!dict) {
        NSCParameterAssert(0);
        return nil;
    }
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    [res addEntriesFromDictionary:dict];
    va_list list;
    va_start(list, dict);
    while ((dict = va_arg(list, NSDictionary *))){
        [res addEntriesFromDictionary:dict];
    }
    va_end(list);
    return res;
}
