//
//  UnicornMapTable.m
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.


#import "UnicornMapTable.h"

@interface UnicornMapTable ()

@property (nonatomic, strong) NSMapTable *mapTable;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) void *queueKey;

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
        self.queue = dispatch_queue_create("UnicornMapTable", NULL);
        self.queueKey = &_queueKey;
        dispatch_queue_set_specific(self.queue, self.queueKey, (__bridge void *)self, NULL);
    }
    return self;
}

- (void)sync:(void (^)(UnicornMapTable *mt))block {
    if (dispatch_get_specific(self.queueKey)) {
        block(self);
    } else {
        dispatch_sync(self.queue, ^{
            block(self);
        });
    }
}

- (void)async:(void (^)(UnicornMapTable *mt))block {
    if (dispatch_get_specific(self.queueKey)) {
        block(self);
    } else {
        dispatch_async(self.queue, ^{
            block(self);
        });
    }
}

- (id)objectForKey:(id)key {
    return [self.mapTable objectForKey:key];
}

- (void)setObject:(id)object forKey:(id)key {
    [self.mapTable setObject:object forKey:key];
}

- (void)removeObjectForKey:(id)key {
    [self.mapTable removeObjectForKey:key];
}

@end
