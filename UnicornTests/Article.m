//
//  Article.m
//  UnicornTests
//
//  Created by emsihyo on 2018/2/1.
//  Copyright © 2018年 emsihyo. All rights reserved.
//

#import "Article.h"

@implementation Article

+ (NSDictionary *)uni_keyPaths{
    return uni_dictionary(
                          uni_package(id,id),
                          uni_package(title,title),
                          uni_package(authors,authors)
                          );
}

+ (UniBlockValueTransformer*)uni_jsonValueTransformer:(NSString *)propertyName{
    if ([propertyName isEqual:uni_string(authors)]) {
        return [UniBlockValueTransformer transformerWithAnonymousClassNames:uni_array(Author) forward:^id(id value) {
            return [Author uni_parseJson:value];
        } reverse:^id(id value) {
            return [Author uni_jsonDictionaryFromModels:value];
        }];
    }
    return nil;
}

+ (NSString*)uni_primary{
    return uni_string(id);
}

+ (NSArray*)uni_columns{
    return uni_array(id,title,authors);
}

+ (UniBlockValueTransformer*)uni_dbValueTransformer:(NSString *)propertyName{
    if ([propertyName isEqual:uni_string(authors)]) {
        return [UniBlockValueTransformer transformerWithAnonymousClassNames:uni_array(Author) forward:^id(id value) {
            NSArray * comps=[value componentsSeparatedByString:@","];
            NSMutableArray *authors=[NSMutableArray array];
            for (NSString *s in comps){
                Author *author=[Author uni_queryOne:@([s longLongValue])];
                if (author) {
                    [authors addObject:author];
                }
            }
            return authors;
        } reverse:^id(id value) {
            NSMutableString *s=[NSMutableString string];
            for (Author *author in value){
                [s appendFormat:@"%llu,",author.id];
            }
            [s deleteCharactersInRange:NSMakeRange(s.length-1, 1)];
            return s;
        }];
    }
    return nil;
}

+ (UniColumnType)uni_columnType:(NSString *)propertyName{
    if ([propertyName isEqualToString:uni_string(authors)]) {
        return UniColumnTypeText;
    }
    return UniColumnTypeUnknown;
}


@end
