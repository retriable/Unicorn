//
//  User.h
//  Unicorn
//
//  Created by emsihyo on 2017/3/7.
//  Copyright © 2017年 emsihyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Unicorn.h"
typedef NS_ENUM (UInt8, UserGender) {
    UserGenderUnknow,
    UserGenderMan,
    UserGenderWoman
};
@interface User : NSObject<UnicornJSON,UnicornDB>

@property (strong) NSString *login;
@property (assign) UInt64 userID;
@property (strong) NSString *avatarURL;
@property (strong) NSString *gravatarID;
@property (strong) NSString *url;
@property (strong) NSString *htmlURL;
@property (strong) NSString *followersURL;
@property (strong) NSString *followingURL;
@property (strong) NSString *gistsURL;
@property (strong) NSString *starredURL;
@property (strong) NSString *subscriptionsURL;
@property (strong) NSString *organizationsURL;
@property (strong) NSString *reposURL;
@property (strong) NSString *eventsURL;
@property (strong) NSString *receivedEventsURL;
@property (strong) NSString *type;
@property (assign) BOOL siteAdmin;
@property (strong) NSString *name;
@property (strong) NSString *company;
@property (strong) NSString *blog;
@property (strong) NSString *location;
@property (strong) NSString *email;
@property (strong) NSString *hireable;
@property (strong) NSString *bio;
@property (assign) UInt32 publicRepos;
@property (assign) UInt32 publicGists;
@property (assign) UInt32 followers;
@property (assign) UInt32 following;
@property (assign) double createdAt;
@property (assign) double updatedAt;
@property (strong) NSDate *date;
@end
