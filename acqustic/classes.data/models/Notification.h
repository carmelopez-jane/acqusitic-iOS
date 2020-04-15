//
//  Notification.h
//  Acqustic
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

// PROFILE (PERFORMER) SHARE PERMISSIONS NOTIFICATIONS
#define NOTI_PROFILE_SHARE_PERMISSIONS_REQUESTED    @"profile_share_permission_requested"
#define NOTI_PROFILE_SHARE_PERMISSIONS_CONFIRMED    @"profile_share_permission_confirmed"
#define NOTI_PROFILE_SHARE_PERMISSIONS_DENIED       @"profile_share_permission_denied"

// GROUP SHARE PERMISSIONS NOTIFICATIONS
#define NOTI_GROUP_SHARE_PERMISSIONS_REQUESTED      @"group_share_permission_requested"
#define NOTI_GROUP_SHARE_PERMISSIONS_CONFIRMED      @"group_share_permission_confirmed"
#define NOTI_GROUP_SHARE_PERMISSIONS_DENIED         @"group_share_permission_denied"


// OFFER NOTIFICATIONS
#define NOTI_PERFORMANCE_REGISTERED                 @"performance_registered"
#define NOTI_PERFORMANCE_CANDIDATE                  @"performance_candidate"
#define NOTI_PERFORMANCE_SELECTED                   @"performance_selected"
#define NOTI_PERFORMANCE_CANCELLED                  @"performance_cancelled"
#define NOTI_PERFORMANCE_WON                        @"performance_won"
#define NOTI_PERFORMANCE_LOST                       @"performance_lost"

// PLAYLISTS NOTIFICATIONS
#define NOTI_PLAYLIST_CANDIDATE                     @"playlist_candidate"
#define NOTI_PLAYLIST_SELECTED                      @"playlist_selected"
#define NOTI_PLAYLIST_CANCELLED                     @"playlist_cancelled"
#define NOTI_PLAYLIST_WON                           @"playlist_won"
#define NOTI_PLAYLIST_LOST                          @"playlist_lost"


@interface Notification : NSObject {
    NSInteger _id;
    NSInteger user_id;
    NSString * type;
    NSString * message;
    NSString * param1;
    NSString * param2;
    NSString * param3;
    NSString * param4;
    NSString * param5;
    NSInteger created_at;
}

@property NSInteger _id;
@property NSInteger user_id;
@property NSString * type;
@property NSString * message;
@property NSString * param1;
@property NSString * param2;
@property NSString * param3;
@property NSString * param4;
@property NSString * param5;
@property NSInteger created_at;

-(id) init;
-(id) initWithJSONString:(NSString *)json;
-(id) initWithDictionary:(NSDictionary *)data;

@end
