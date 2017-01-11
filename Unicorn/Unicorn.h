//
//  Unicorn.h
//  Unicorn
//
//  Created by emsihyo on 2017/1/10.

#import <Foundation/Foundation.h>
#import "NSObject+Unicorn.h"
#import "NSObject+UnicornJSON.h"
#import "UnicornBlockValueTransformer.h"
#import "UnicornModelInfo.h"
#import "UnicornMapTable.h"
#import "UnicornDatabase.h"
#import "UnicornFuctions.h"
#ifndef UNI_DB_MODEL_DB_PATH
#define UNI_DB_MODEL_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Caches/UNI_models.sqlite"]
#endif

#ifndef UNI_SAVE_MODEL
#define UNI_SAVE_MODEL(x) x = [x UNI_save]
#endif

#ifndef UNI_SAVE_MODELS
#define UNI_SAVE_MODELS(c, x) x = [c UNI_save:x]
#endif

#ifndef UNI_NON_WHITESPACE_NEWLINE
#define UNI_NON_WHITESPACE_NEWLINE(x) [[x stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString: @" " withString: @""]
#endif

#ifndef UNI_MT_UNIQUE
#define UNI_MT_UNIQUE(x)    \
+(NSString *)uni_mtUniquePropertyName { \
return @#x;                        \
}
#endif

#ifndef UNI_DB_COLUMN_NAMES
#define UNI_DB_COLUMN_NAMES(...)                                               \
+(NSArray *)uni_dbColumnNamesInPropertyName {                                            \
return [UNI_NON_WHITESPACE_NEWLINE(@#__VA_ARGS__) componentsSeparatedByString:@","]; \
}
#endif

#ifndef UNI_PAIR
#define UNI_PAIR(x, y) @#x: @#y
#endif

#ifndef UNI_JSON_KEY_PATHS
#define UNI_JSON_KEY_PATHS(...)          \
+(NSDictionary *)uni_jsonKeyPathsByPropertyName { \
return @{__VA_ARGS__};                       \
}
#endif

