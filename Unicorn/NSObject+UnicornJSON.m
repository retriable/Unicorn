//
//  NSObject+UnicornJSON.m
//  Unicorn
//
//  Created by emsihyo on 2017/1/5.

#import "NSObject+UnicornJSON.h"
#import "NSObject+Unicorn.h"
#import "UnicornFuctions.h"

typedef struct {
    __unsafe_unretained id model;
    __unsafe_unretained id dictionary;
}uni_json_context;

static void json_forward(const void *_value, void *_context){
    uni_json_context *context = _context;
    __unsafe_unretained NSDictionary *dictionary = context->dictionary;
    __unsafe_unretained id model = context->model;
    __unsafe_unretained UnicornPropertyInfo *propertyInfo = (__bridge __unsafe_unretained UnicornPropertyInfo *)_value;
    __unsafe_unretained NSValueTransformer *valueTransformer = propertyInfo.jsonValueTransformer;
    __unsafe_unretained NSArray *jsonKeyPathInArray = propertyInfo.jsonKeyPathInArray;
    __unsafe_unretained NSString *jsonKeyPathInString = propertyInfo.jsonKeyPathInString;
    NSUInteger count=jsonKeyPathInArray.count;
    id value = nil;
    if (count==0){
        value = dictionary;
    }else if (count == 1) {
        value = dictionary[jsonKeyPathInString];
    } else {
        value = [dictionary uni_valueForKeyPaths:jsonKeyPathInArray];
    }
    if (valueTransformer) {
        value = [valueTransformer transformedValue:value];
    } else if (propertyInfo.isConformingToUnicornJSONModel) {
        value = [propertyInfo.cls uni_modelWithJsonDictionary:value];
    }
    uni_model_set_value(model, propertyInfo, value);
}

static void json_reverse(const void *_value, void *_context){
    uni_json_context *context = _context;
    __unsafe_unretained NSMutableDictionary *dictionary = context->dictionary;
    __unsafe_unretained id model = context->model;
    __unsafe_unretained UnicornPropertyInfo *propertyInfo = (__bridge __unsafe_unretained UnicornPropertyInfo *)_value;
    __unsafe_unretained NSValueTransformer *valueTransformer = propertyInfo.jsonValueTransformer;
    id value = uni_model_get_value(model, propertyInfo);
    if (valueTransformer) {
        value = [valueTransformer reverseTransformedValue:value];
    } else {
        if (propertyInfo.isConformingToUnicornJSONModel) {
            value = [value uni_jsonDictionary];
        }
    }
    if (value) {
        __unsafe_unretained NSArray *jsonKeyPathInArray = propertyInfo.jsonKeyPathInArray;
        __unsafe_unretained NSString *jsonKeyPathInString = propertyInfo.jsonKeyPathInString;
        NSMutableDictionary *parent = dictionary;
        NSUInteger count = jsonKeyPathInArray.count;
        if (count==0) {
            [value enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                parent[key]=obj;
            }];
        }else if (count == 1) {
            [parent setObject:value forKey:jsonKeyPathInString];
        } else {
            int i = 0;
            __unsafe_unretained NSString *key = nil;
            for (; i < count - 1; i++) {
                key = jsonKeyPathInArray[i];
                NSMutableDictionary *child = parent[key];
                if (!child) {
                    child = [NSMutableDictionary dictionary];
                    parent[key] = child;
                    parent = child;
                }
            }
            parent[key] = value;
        }
    }
}

@implementation NSObject (UnicornJSON)

+ (NSArray *)uni_modelsWithJsonDictionaries:(NSArray *)jsonDictionaries {
    NSParameterAssert([self conformsToProtocol:@protocol(UnicornJSON)]);
    UnicornClassInfo *classInfo = [self uni_classInfo];
    __block NSArray *models=nil;
    [classInfo sync:^(UnicornMapTable *mt, UnicornDatabase *db) {
        models = [self uni_modelsWithJsonDictionaries:jsonDictionaries classInfo:classInfo mt:mt db:db];
    }];
    return models;
}

+ (instancetype)uni_modelWithJsonDictionary:(NSDictionary *)jsonDictionary {
    NSParameterAssert([self conformsToProtocol:@protocol(UnicornJSON)]);
    __block id model=nil;
    UnicornClassInfo *classInfo = [self uni_classInfo];
    [classInfo sync:^(UnicornMapTable *mt, UnicornDatabase *db) {
        model=[self uni_modelWithJsonDictionary:jsonDictionary classInfo:classInfo mt:mt db:db];
    }];
    return model;
}

+ (NSArray *)uni_modelsWithJsonDictionaries:(NSArray *)jsonDictionaries classInfo:(UnicornClassInfo *)classInfo mt:(UnicornMapTable*)mt db:(UnicornDatabase*)db {
    if (!jsonDictionaries) {
        return [NSMutableArray array];
    }
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:jsonDictionaries.count];
        if (mt) {
            UnicornPropertyInfo *propertyInfo = classInfo.mtUniquePropertyInfo;
            NSValueTransformer *valueTransfomer = propertyInfo.jsonValueTransformer;
            if (db) {
                [db beginTransaction];
                for (NSDictionary *jsonDictionary in jsonDictionaries) {
                    id uniqueValue = nil;
                    if (classInfo.mtUniquePropertyInfo.jsonKeyPathInArray.count == 1) {
                        uniqueValue = jsonDictionary[propertyInfo.jsonKeyPathInString];
                    } else {
                        uniqueValue = [jsonDictionary uni_valueForKeyPaths:propertyInfo.jsonKeyPathInArray];
                    }
                    if (valueTransfomer) {
                        uniqueValue = [valueTransfomer transformedValue:uniqueValue];
                    }
                    id model = uni_mt_unique_model(uniqueValue, mt);
                    if (model) {
                        [model uni_mergeWithJsonDictionary:jsonDictionary classInfo:classInfo];
                        uni_db_update(model, classInfo, db);
                        [model setUni_merged:YES];
                    } else {
                        id model = uni_db_unique_model(uniqueValue, classInfo, db);
                        if (model) {
                            [model uni_mergeWithJsonDictionary:jsonDictionary classInfo:classInfo];
                            uni_db_update(model, classInfo, db);
                            uni_mt_set(model,uniqueValue,mt);
                            [model setUni_merged:YES];
                        } else {
                            model = [[self alloc] init];
                            [model uni_mergeWithJsonDictionary:jsonDictionary classInfo:classInfo];
                            uni_db_insert(model, classInfo, db);
                            uni_mt_set(model,uniqueValue,mt);
                        }
                    }
                    [models addObject:model];
                }
                [db commit];
            } else {
                for (NSDictionary *jsonDictionary in jsonDictionaries) {
                    id uniqueValue = nil;
                    if (classInfo.mtUniquePropertyInfo.jsonKeyPathInArray.count == 1) {
                        uniqueValue = jsonDictionary[propertyInfo.jsonKeyPathInString];
                    } else {
                        uniqueValue = [jsonDictionary uni_valueForKeyPaths:propertyInfo.jsonKeyPathInArray];
                    }
                    if (valueTransfomer) {
                        uniqueValue = [valueTransfomer transformedValue:uniqueValue];
                    }
                    id model = [mt objectForKey:uniqueValue];
                    if (model) {
                        [model uni_mergeWithJsonDictionary:jsonDictionary classInfo:classInfo];
                    } else {
                        model = [[self alloc] init];
                        [model uni_mergeWithJsonDictionary:jsonDictionary classInfo:classInfo];
                        uni_mt_set(model,uniqueValue,mt);
                    }
                    [models addObject:model];
                }
            }
        } else {
            for (NSDictionary *jsonDictionary in jsonDictionaries) {
                id model = [[self alloc] init];
                [model uni_mergeWithJsonDictionary:jsonDictionary classInfo:classInfo];
                [models addObject:model];
            }
        }
    return models;
}

+ (instancetype)uni_modelWithJsonDictionary:(NSDictionary *)jsonDictionary classInfo:(UnicornClassInfo *)classInfo mt:(UnicornMapTable*)mt db:(UnicornDatabase*)db{
    if (!jsonDictionary) {
        return nil;
    }
    id model =nil;
    if (mt) {
        id uniqueValue = nil;
        NSArray *jsonKeyPathInArray = classInfo.mtUniquePropertyInfo.jsonKeyPathInArray;
        if (jsonKeyPathInArray.count == 1) {
            uniqueValue = jsonDictionary[classInfo.mtUniquePropertyInfo.jsonKeyPathInString];
        } else {
            uniqueValue = [jsonDictionary uni_valueForKeyPaths:jsonKeyPathInArray];
        }
        NSValueTransformer *valueTransfomer = classInfo.mtUniquePropertyInfo.jsonValueTransformer;
        if (valueTransfomer) {
            uniqueValue = [valueTransfomer transformedValue:uniqueValue];
        }
        if (db) {
            model = uni_mt_unique_model(uniqueValue, mt);
            if (model) {
                [model uni_mergeWithJsonDictionary:jsonDictionary classInfo:classInfo];
                uni_db_update(model, classInfo, db);
                [model setUni_merged:YES];
            } else {
                model=uni_db_unique_model(uniqueValue, classInfo, db);
                if (model) {
                    [model uni_mergeWithJsonDictionary:jsonDictionary classInfo:classInfo];
                    uni_db_update(model, classInfo, db);
                    uni_mt_set(model,uniqueValue,mt);
                    [model setUni_merged:YES];
                } else {
                    model = [[self alloc] init];
                    [model uni_mergeWithJsonDictionary:jsonDictionary classInfo:classInfo];
                    uni_db_insert(model, classInfo, db);
                    uni_mt_set(model,uniqueValue,mt);
                }
            }
        } else {
            model = [mt objectForKey:uniqueValue];
            if (model) {
                [model uni_mergeWithJsonDictionary:jsonDictionary classInfo:classInfo];
            } else {
                model = [[self alloc] init];
                [model uni_mergeWithJsonDictionary:jsonDictionary classInfo:classInfo];
                uni_mt_set(model,uniqueValue,mt);
            }
        }
    } else {
        model = [[self alloc] init];
        [model uni_mergeWithJsonDictionary:jsonDictionary classInfo:classInfo];
    }
    return model;
}

- (void)uni_mergeWithJsonDictionary:(NSDictionary *)jsonDictionary classInfo:(UnicornClassInfo *)classInfo {
    uni_json_context context = {};
    context.model = self;
    context.dictionary = jsonDictionary;
    CFArrayRef ref = (__bridge CFArrayRef)classInfo.jsonPropertyInfos;
    CFArrayApplyFunction(ref, CFRangeMake(0, CFArrayGetCount(ref)), json_forward, &context);
}

- (NSDictionary *)uni_jsonDictionary {
    UnicornClassInfo *classInfo = [self.class uni_classInfo];
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionaryWithCapacity:classInfo.jsonPropertyInfos.count];
    uni_json_context context = {};
    context.model = self;
    context.dictionary = jsonDictionary;
    CFArrayApplyFunction((__bridge CFArrayRef)classInfo.jsonPropertyInfos, CFRangeMake(0, classInfo.jsonPropertyInfos.count), json_reverse, &context);
    return jsonDictionary;
}

@end
