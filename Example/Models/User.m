//
//  User.m
//  Unicorn
//
//  Created by emsihyo on 2017/3/7.
//  Copyright © 2017年 emsihyo. All rights reserved.
//

#import "User.h"

@implementation User
UNI_JSON_KEY_PATHS(
                   UNI_PAIR(login, login),
                   UNI_PAIR(userID, id),
                   UNI_PAIR(avatarURL, meta.avatar_url),
                   UNI_PAIR(gravatarID, gravatar_id),
                   UNI_PAIR(url, url),
                   UNI_PAIR(htmlURL, html_url),
                   UNI_PAIR(followersURL, followers_url),
                   UNI_PAIR(followingURL, following_url),
                   UNI_PAIR(gistsURL, gists_url),
                   UNI_PAIR(starredURL, starred_url),
                   UNI_PAIR(subscriptionsURL, subscriptions_url),
                   UNI_PAIR(organizationsURL, organizations_url),
                   UNI_PAIR(reposURL, repos_url),
                   UNI_PAIR(eventsURL, events_url),
                   UNI_PAIR(receivedEventsURL, received_events_url),
                   UNI_PAIR(siteAdmin, site_admin),
                   UNI_PAIR(publicRepos, public_repos),
                   UNI_PAIR(publicGists, public_gists),
                   UNI_PAIR(type, type),
                   UNI_PAIR(name, name),
                   UNI_PAIR(company, company),
                   UNI_PAIR(blog, blog),
                   UNI_PAIR(location, location),
                   UNI_PAIR(email, email),
                   UNI_PAIR(hireable, hireable),
                   UNI_PAIR(bio, bio),
                   UNI_PAIR(followers, followers),
                   UNI_PAIR(following, following),
                   UNI_PAIR(createdAt, created_at),
                   UNI_PAIR(updatedAt, updated_at),
                   UNI_PAIR(date, date),
                   )
UNI_MT_UNIQUE(userID)
UNI_DB_COLUMN_NAMES(login, userID, avatarURL, gravatarID, url, htmlURL, followersURL, followingURL, gistsURL, starredURL, subscriptionsURL, organizationsURL, reposURL, eventsURL, receivedEventsURL, siteAdmin, publicRepos, publicGists, createdAt, updatedAt, type, name, company, blog, location, email, hireable, bio, followers, following, createdAt, updatedAt)

+ (NSValueTransformer *)UNI_jsonValueTransformerForPropertyName:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"date"]) {
        return [UnicornBlockValueTransformer transformerWithForward:^id (NSNumber *value) {
            return [NSDate dateWithTimeIntervalSince1970:value.doubleValue];
        } reverse:^id (NSDate *date) {
            return @([date timeIntervalSince1970]);
        }];
    }
    return nil;
}

+ (UnicornDatabaseTransformer *)UNI_dbValueTransformerForPropertyName:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"date"]) {
        [UnicornDatabaseTransformer transformerWithValueTransformer:[UnicornBlockValueTransformer transformerWithForward:^id (NSNumber *value) {
            return [NSDate dateWithTimeIntervalSince1970:value.doubleValue];
        } reverse:^id (NSDate *date) {
            return @([date timeIntervalSince1970]);
        }] columnType:UnicornDatabaseColumnTypeReal];
    }
    return nil;
}
@end
