//
//  NSObject+Unicorn.m
//  Unicorn
//
//  Created by emsihyo on 2016/12/29.

#import "NSObject+Unicorn.h"
#import "UnicornFuctions.h"

NSString *const uni_on_update_timestamp = @"uni_on_update_timestamp";

@interface NSObject (Unicorn_)

@property (assign)bool uni_merged;

@end

static NSString *const UNI_MERGED=@"uni_merged";

@implementation NSObject(Unicorn_)

- (void)setUni_merged:(bool)uni_merged{
    [self willChangeValueForKey:UNI_MERGED];
    objc_setAssociatedObject(self, (__bridge void *)UNI_MERGED, @(uni_merged), OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:UNI_MERGED];
}

- (bool)uni_merged{
    return [objc_getAssociatedObject(self, (__bridge void *)UNI_MERGED) boolValue];
}

@end
@implementation NSObject (Unicorn)

+ (instancetype)uni_modelWithValue:(id)value {
    NSParameterAssert([self conformsToProtocol:@protocol(UnicornMT)]);
    UnicornClassInfo *classInfo = [self uni_classInfo];
    __block id model = nil;
    [classInfo sync:^(UnicornMapTable *mt, UnicornDatabase *db) {
        model = uni_unique_model(value, classInfo, mt, db);
    }];
    return model;
}

- (instancetype)uni_save {
    NSParameterAssert([self.class conformsToProtocol:@protocol(UnicornMT)]);
    __block id model = nil;
    UnicornClassInfo *classInfo = [self.class uni_classInfo];
    [classInfo sync:^(UnicornMapTable *mt, UnicornDatabase *db) {
        model = [self uni_save:classInfo mt:mt db:db];
    }];
    return model;
}

+ (NSArray *)uni_save:(NSArray *)models {
    NSParameterAssert([self conformsToProtocol:@protocol(UnicornMT)]);
    UnicornClassInfo *classInfo = [self.class uni_classInfo];
    __block NSArray *savedModels=nil;
    [classInfo sync:^(UnicornMapTable *mt, UnicornDatabase *db) {
        savedModels=[self uni_save:models classInfo:classInfo mt:mt db:db];
    }];
    return savedModels;
}

+ (NSArray *)uni_modelsWithAfterWhereSql:(NSString *)afterWhereSql arguments:(NSArray *)arguments {
    NSParameterAssert([self conformsToProtocol:@protocol(UnicornDB)]);
    UnicornClassInfo *classInfo = [self uni_classInfo];
    __block NSArray *models = nil;
    [classInfo sync:^(UnicornMapTable *mt, UnicornDatabase *db) {
        models = uni_select(afterWhereSql, arguments, classInfo, mt, db);
    }];
    return models;
}

+ (void)uni_deleteModelsWithAfterWhereSql:(NSString * _Nullable)afterWhereSql arguments:(NSArray *_Nullable)arguments{
    NSParameterAssert([self conformsToProtocol:@protocol(UnicornDB)]);
    UnicornClassInfo *classInfo = [self uni_classInfo];
    [classInfo sync:^(UnicornMapTable *mt, UnicornDatabase *db) {
        uni_delete(afterWhereSql, arguments, classInfo, db);
    }];
}

- (instancetype)uni_save:(UnicornClassInfo*)classInfo mt:(UnicornMapTable*)mt db:(UnicornDatabase*)db{
    id model=nil;
    if (db) {
        id uniqueValue = uni_model_get_unique_value(self, classInfo);
        model = uni_mt_unique_model(uniqueValue, mt);
        if (model) {
            uni_model_merge(model, self, classInfo);
            uni_db_update(model, classInfo, db);
            [model setUni_merged:YES];
        } else {
            model = uni_db_unique_model(uniqueValue, classInfo, db);
            if (model) {
                uni_model_merge(model, self, classInfo);
                uni_db_update(model, classInfo, db);
                uni_mt_set(model, uniqueValue, mt);
                [model setUni_merged:YES];
            } else {
                model = self;
                uni_db_insert(model, classInfo, db);
                uni_mt_set(model, uniqueValue, mt);
            }
        }
    } else {
        id uniqueValue = uni_model_get_unique_value(self, classInfo);
        model = uni_mt_unique_model(uniqueValue, mt);
        if (model) {
            uni_model_merge(model, self, classInfo);
        } else {
            model = self;
            uni_mt_set(model, uniqueValue, mt);
        }
    }
    return model;
}

+ (NSArray *)uni_save:(NSArray *)models classInfo:(UnicornClassInfo*)classInfo mt:(UnicornMapTable*)mt db:(UnicornDatabase*)db{
    NSMutableArray *savedModels = [NSMutableArray arrayWithCapacity:models.count];
    void (^block)()=^{
        for (id m in models) {
            id model=[m uni_save:classInfo mt:mt db:db];
            if (model) {
                [savedModels addObject:model];
            }
        }
    };
    if (db) {
        [db beginTransaction];
        block();
        [db commit];
    } else {
        block();
    }
    return savedModels;
}

+ (void)uni_deleteBeforeDate:(NSDate *)date {
    UnicornClassInfo *classInfo = [self uni_classInfo];
    [classInfo sync:^(UnicornMapTable *mt, UnicornDatabase *db) {
        NSString *afterWhereSql=nil;
        if (date) {
            afterWhereSql=[NSString stringWithFormat:@"%@<?",uni_on_update_timestamp];
        }
        uni_delete(afterWhereSql, @[@([date timeIntervalSince1970])], classInfo, db);
    }];
}

@end
