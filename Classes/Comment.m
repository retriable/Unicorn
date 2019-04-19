//
//  Comment.m
//  Unicorn
//
//  Created by retriable on 2018/5/3.
//  Copyright © 2018 retriable. All rights reserved.
//

#import "Comment.h"

@implementation Comment

+ (NSDictionary * _Nonnull)uni_keyPaths{
    return @{
             @"id":@"id",
             @"author":@[@"author",@"user"],
             @"content":@"content",
             @"comments":@"comments",
             @"size":@"size"
             };
}

+ (UniTransformer *_Nullable)uni_jsonTransformer:(NSString* _Nonnull)propertyName{
    if ([propertyName isEqualToString:@"comments"]){
        return [UniTransformer transformerWithForward:^id(id value) {
            return (id)[Comment uni_parseJson:value];
        } backward:^id(id value) {
            NSMutableArray *arr=[NSMutableArray array];
            for (id comment in value){
                id json=[comment uni_jsonObject];
                if (json) [arr addObject:json];
            }
            return (id)(arr.count>0?arr:nil);
        }];
    }
    return nil;
}

+ (NSString * _Nonnull)uni_primary{
    return @"id";
}

+ (NSArray * _Nonnull)uni_columns{
    return @[@"id",@"author",@"content",@"comments"];
}

+ (UniColumnType)uni_columnType:(NSString *)propertyName{
    if ([propertyName isEqualToString:@"comments"]){
        return UniColumnTypeText;
    }
    return 0;
}

+ (UniTransformer *_Nullable)uni_dbTransformer:(NSString* _Nonnull)propertyName{
    if ([propertyName isEqualToString:@"comments"]){
        return [UniTransformer transformerWithForward:^id(id value) {
            NSArray *comps=[value componentsSeparatedByString:@","];
            NSMutableArray *arr=[NSMutableArray array];
            for (NSString * sid in comps){
                Comment *comment=[Comment uni_queryOne:@([sid integerValue])];
                if (comment) [arr addObject:comment];
            }
            return (id)arr;
        } backward:^id(id value) {
            NSMutableArray *arr=[NSMutableArray array];
            [value enumerateObjectsUsingBlock:^(Comment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [arr addObject:[NSString stringWithFormat:@"%llu",obj.id]];
            }];
            return (id)[arr componentsJoinedByString:@","];
        }];
    }
    return nil;
}

+ (NSString *)uni_primaryKey {
    return @"id";
}

+ (NSArray *)uni_synchronizedClasses{
    return @[User.class,Comment.class];
}
//
//+ (NSArray * _Nonnull)uni_indexes{
//    return nil;
//}

@end
