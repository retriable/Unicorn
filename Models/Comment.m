//
//  Comment.m
//  Unicorn
//
//  Created by emsihyo on 2018/5/3.
//  Copyright © 2018 emsihyo. All rights reserved.
//

#import "Comment.h"

@implementation Comment

+ (NSDictionary * _Nonnull)uni_keyPaths{
    return @{
             @"id":@"id",
             @"author":@[@"author",@"user"],
             @"content":@"content",
             @"comments":@"comments"
             };
}

+ (UniTransformer _Nullable)uni_jsonTransformer:(NSString* _Nonnull)propertyName{
    if ([propertyName isEqualToString:@"comments"]){
        return ^(id value,BOOL reversed){
            if (reversed){
                NSMutableArray *arr=[NSMutableArray array];
                for (id comment in value){
                    id json=[comment uni_jsonDictionary];
                    if (json) [arr addObject:json];
                }
                return (id)arr;
            }else{
                return (id)[Comment uni_parseJson:value];
            }
        };
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

+ (UniTransformer _Nullable)uni_dbTransformer:(NSString* _Nonnull)propertyName{
    if ([propertyName isEqualToString:@"comments"]){
        return ^(id value,BOOL reversed){
            if (!value) return (id)nil;
            if (reversed){
                NSMutableArray *arr=[NSMutableArray array];
                [value enumerateObjectsUsingBlock:^(Comment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [arr addObject:[NSString stringWithFormat:@"%llu",obj.id]];
                }];
                return (id)[arr componentsJoinedByString:@","];
            }else{
                NSArray *comps=[value componentsSeparatedByString:@","];
                NSMutableArray *arr=[NSMutableArray array];
                for (NSString * sid in comps){
                    Comment *comment=[Comment uni_queryOne:@([sid integerValue])];
                    if (comment) [arr addObject:comment];
                }
                return (id)arr;
            }
        };
    }
    return nil;
}

+ (NSString * _Nonnull)uni_primaryKey {
    return @"id";
}

+ (NSArray * _Nonnull)uni_delitescentClasses{
    return @[User.class,Comment.class];
}
//
//+ (NSArray * _Nonnull)uni_indexes{
//    return nil;
//}

@end
