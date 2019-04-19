//
//  Article.m
//  Unicorn
//
//  Created by retriable on 2018/5/3.
//  Copyright © 2018 retriable. All rights reserved.
//

#import "Article.h"

@implementation Article

+ (NSDictionary * )uni_keyPaths{
    return @{
             @"id":@"id",
             @"author":@[@"author",@"extra.author"],
             @"content":@"content",
             @"title":@"title",
             @"comments":@"comments",
             };
}

+ (UniTransformer *)uni_jsonTransformer:(NSString* )propertyName{
    if ([propertyName isEqualToString:@"comments"]){
        return [UniTransformer transformerWithForward:^id(id value) {
            return [Comment uni_parseJson:value];
        } backward:^id(id value) {
            NSMutableArray *arr=[NSMutableArray array];
            for (id comment in value){
                id json=[comment uni_jsonObject];
                if (json) [arr addObject:json];
            }
            return arr.count>0?arr:nil;
        }];
    }
    return nil;
}

+ (NSString * )uni_primaryKey{
    return @"id";
}

+ (NSArray *)uni_synchronizedClasses{
    return @[Comment.class];
}

+ (NSArray * )uni_columns{
    return @[@"id",@"author",@"content",@"title",@"comments"];
}

+ (UniColumnType)uni_columnType:(NSString *)propertyName{
    if ([propertyName isEqualToString:@"comments"]){
        return UniColumnTypeText;
    }
    return 0;
}

+ (UniTransformer *)uni_dbTransformer:(NSString* )propertyName{
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
            [value enumerateObjectsUsingBlock:^(Comment *  obj, NSUInteger idx, BOOL *  stop) {
                [arr addObject:[NSString stringWithFormat:@"%llu",obj.id]];
            }];
            return (id)[arr componentsJoinedByString:@","];
        }];
    }
    return nil;
}

//+ (NSArray * )uni_indexes{
//    return @[@"title"];
//}

@end
