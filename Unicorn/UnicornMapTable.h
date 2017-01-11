//
//  UnicornMapTable.h
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.

#import <Foundation/Foundation.h>

@interface UnicornMapTable : NSObject

+ (instancetype)mapTableWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions capacity:(NSUInteger)initialCapacity;

//- (void)sync:(void (^)(UnicornMapTable *mt))block;
//- (void)async:(void (^)(UnicornMapTable *mt))block;

- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;
- (void)removeObjectForKey:(id)key;

@end
