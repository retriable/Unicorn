//
//  UnicornMapTable.m
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.


#import "UnicornMapTable.h"

@interface UnicornMapTable ()

@property (nonatomic, strong) NSMapTable *mapTable;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation UnicornMapTable

+ (instancetype)mapTableWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions capacity:(NSUInteger)initialCapacity {
    UnicornMapTable *mapTable = [[UnicornMapTable alloc] init];
    mapTable.mapTable = [[NSMapTable alloc] initWithKeyOptions:keyOptions valueOptions:valueOptions capacity:initialCapacity];
    return mapTable;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = dispatch_queue_create("UnicornMapTable", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}


- (id)objectForKey:(id)key {
    __block id obj=nil;
    dispatch_sync(self.queue, ^{
        obj=[self.mapTable objectForKey:key];
    });
    return obj;
}

- (void)setObject:(id)object forKey:(id)key {
    dispatch_barrier_sync(self.queue, ^{
        [self.mapTable setObject:object forKey:key];
    });
}

- (void)removeObjectForKey:(id)key {
    dispatch_barrier_sync(self.queue, ^{
        [self.mapTable removeObjectForKey:key];
    });
}
@end
