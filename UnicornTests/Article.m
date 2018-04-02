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
                          uni_package(title,title,info.title),
                          uni_package(authors,authors)
                          );
}

+ (NSValueTransformer*)uni_jsonValueTransformer:(NSString *)propertyName{
    if ([propertyName isEqual:uni_string(authors)]) {
        return [UniBlockValueTransformer transformerWithForward:^id(id value) {
            return [Author uni_parseJson:value];
        } reverse:^id(id value) {
            return [Author uni_jsonDictionaryFromModels:value];
        }];
    }
    return nil;
}

+ (NSArray*)uni_anonymousClassNames{
    return uni_array(Author);
}

+ (NSString*)uni_primary{
    return uni_string(id);
}

+ (NSArray*)uni_columns{
    return uni_array(id,title);
}

@end
