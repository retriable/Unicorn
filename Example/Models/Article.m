//
//  Article.m
//  OOModel
//
//  Created by emsihyo on 2017/1/9.

#import "Article.h"

@implementation Article
UNI_JSON_KEY_PATHS(
    UNI_PAIR(aid, id),
    UNI_PAIR(title, title),
    UNI_PAIR(intro, intro),
    UNI_PAIR(author, author),
    UNI_PAIR(score, score),
    )
UNI_MT_UNIQUE(aid)
UNI_DB_COLUMN_NAMES(aid, title, intro, author, score)

@end
