//
//  WSDataManager.h
//  SegurParking
//
//  Created by Joan on 19/8/15.
//  Copyright (c) 2015 Bab Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppSession.h"
#import "Account.h"
#import "Performer.h"
#import "Group.h"
#import "Performance.h"
#import "PerformanceDist.h"
#import "Invoicereq.h"
#import "Album.h"
#import "Repertoire.h"
#import "Song.h"
#import "AgendaItem.h"

#define WS_SUCCESS                          200

#define WS_ERROR_SERVER                      500
#define WS_ERROR_NOTLOGGEDIN                 400
#define WS_ERROR_NOTACTIVATED                450
#define WS_ERROR_WAITINGREGISTRY             451
#define WS_ERROR_ALREADYREGISTERED           452
#define WS_ERROR_USERNOTFOUND               453

#define WS_ERROR_NONETWORKAVAIABLE           -1000  
#define WS_ERROR_SERVERNOTFOUND              -1001
#define WS_ERROR_PARSE                       -1002
#define WS_ERROR_RESULT_FALSE                -1003
#define WS_ERROR_OTHER                       -1100

@interface WSDataManager : NSObject{
}

+(void) init;

+(id)cleanUpJson:(id)data;
+(id)JSONfromNSString:(NSString *)string;
+(NSString *)stringFromJSON:(id)json;

+(BOOL) isNetworkAvailable;

// API AUTH / LOGIN
+(void)loginWithEmail:(NSString*)email
             andPassword:(NSString*)password
               withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)recoverPassword:(NSString*)email
             withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)logOut:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)register:(UserInfo *)profile withPassword:(NSString *)password withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;

// LINK DEVICE
+(void)linkDevice:(NSString *)deviceId token:(NSString *)token lang:(NSString *)lang withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;

// PROFILE
/*
+(void)getProfile:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)updateProfile:(UserInfo *)profile withPassword:(NSString *)password oldPassword:(NSString *)oldPassword withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
*/

// ----------------------------------------------
// PROFILE
// ----------------------------------------------
+(void)getProfile:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)updateProfilePassword:(Account *)account withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)updatePerformerProfile:(Performer *) performer withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)uploadImage:(NSString *) file withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)uploadFile:(NSString *) file withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)deezerSearchSongs:(NSString *)search withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)deezerGetTrack:(NSString *)trackId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;

// ----------------------------------------------
// GROUPS
// ----------------------------------------------
+(void)getGroup:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)updateGroup:(Group *)group withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)newGroup:(NSString *)name withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)addGroupMemberByMail:(NSInteger) groupId email:(NSString *) email withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)getGroupMember:(NSInteger) groupId memberId:(NSInteger)memberId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)updateGroupMember:(NSInteger) groupId performer:(Performer *)performer withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)createGroupMember:(NSInteger) groupId performer:(Performer *)performer withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)removeGroupMember:(NSInteger) groupId performer:(Performer *)performer withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
// ----------------------------------------------
// AGENDA
// ----------------------------------------------
+(void)getGroupAgenda:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)getAgendaItem:(NSInteger) agendaitemId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)updateAgendaitem:(Agendaitem *)agendaitem withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)removeAgendaitem:(Agendaitem *)agendaitem withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)addAgendaitem:(NSInteger) groupId agendaitem:(Agendaitem *)agendaitem withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
// ----------------------------------------------
// INVOICEREQS
// ----------------------------------------------
+(void)getInvoicereqs:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)getInvoicereq:(NSInteger) itemId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)updateInvoicereq:(Invoicereq *)invoicereq withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)addInvoicereq:(NSInteger) groupId invoicereq: (Invoicereq *)invoicereq withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)removeInvoicereq:(Invoicereq *)invoicereq withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
// ----------------------------------------------
// ALBUMS
// ----------------------------------------------
+(void)getGroupAlbums:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)getGroupAlbum:(NSInteger) groupId albumId:(NSInteger)albumId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)addGroupAlbum:(NSInteger) groupId album:(Album *)album withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;


+(void)updateGroupAlbum:(NSInteger) groupId album:(Album *) album withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)removeGroupAlbum:(NSInteger) groupId album:(Album *) album withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)addGroupAlbumSong:(NSInteger) groupId albumId:(NSInteger)albumId song:(Song *)song withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)attachGroupAlbumSong:(NSInteger) groupId albumId:(NSInteger) albumId songId:(NSInteger) songId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)removeGroupAlbumSong:(NSInteger) groupId albumId:(NSInteger) albumId songId:(NSInteger) songId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)publishGroupAlbum:(NSInteger) groupId albumId:(NSInteger) albumId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
// ----------------------------------------------
// REPERTORIORE
// ----------------------------------------------
+(void)getGroupRepertoires:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)getGroupRepertoire:(NSInteger) groupId repertoireId:(NSInteger) repertoireId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)addGroupRepertoire:(NSInteger) groupId repertoire:(Repertoire *) repertoire withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)updateGroupRepertoire:(NSInteger) groupId repertoire:(Repertoire *) repertoire withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)removeGroupRepertoire:(NSInteger) groupId repertoire:(Repertoire *) repertoire withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)addGroupRepertoireSong:(NSInteger)groupId repertoireId:(NSInteger)repertoireId song:(Song *)song withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)attachGroupRepertoireSong:(NSInteger) groupId repertoireId:(NSInteger)repertoireId songId:(NSInteger)songId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)removeGroupRepertoireSong:(NSInteger) groupId repertoireId:(NSInteger)repertoireId songId:(NSInteger)songId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
// ----------------------------------------------
// SONGS (catálogo completo de canciones del grupo)
// ----------------------------------------------
+(void)getSongs:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)getSong:(NSInteger) groupId itemId:(NSInteger) itemId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)udpateSong:(Song *) item withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)addSong:(NSInteger) groupId song:(Song *)song withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
// ----------------------------------------------
// PERFORMANCES
// ----------------------------------------------
+(void)getPerformances:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)getPerformance:(NSInteger) performanceId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)performanceRegister:(NSInteger) groupId performance:(Performance *)performance withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)performanceRegisterMultiple:(NSString *) groups performance:(Performance  *)performance withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)performanceRegisterMultiple:(NSString *) groups performanceId:(NSInteger)performanceId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)performanceConfirmCandidate:(NSInteger) groupId performance:(Performance  *) performance withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)performanceRejectCandidate:(NSInteger) groupId performance:(Performance  *) performance withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)performanceConfirmSelected:(NSInteger) groupId performance:(Performance  *) performance dist:(PerformanceDist *)dist groupNotes:(NSString *)groupNotes withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)performanceRejectSelected:(NSInteger) groupId performance:(Performance  *) performance withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
// ----------------------------------------------
// PERMISOS
// ----------------------------------------------
+(void)requestSharePermissionPerformerProfile:(NSInteger) performerId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)confirmSharePermissionPerformerProfile:(NSInteger) performerId notificationId:(NSInteger) notificationId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)denySharePermissionPerformerProfile:(NSInteger) performerId notificacionId:(NSInteger) notificationId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)requestSharePermissionGroupProfile:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)confirmSharePermissionGroupProfile:(NSInteger) groupId notificationId:(NSInteger)notificationId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)denySharePermissionGroupProfile:(NSInteger) groupId notificationId:(NSInteger)notificationId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
// ----------------------------------------------
// NOTIFICACIONES
// ----------------------------------------------
+(void)getNotifications:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)getAllNotifications:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)markNotificationAsDone:(NSInteger) notificationId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)getNotificationBadges:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
// ----------------------------------------------
// CHATS
// ----------------------------------------------
+(void)getChats:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)getChat:(NSInteger) chatId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)getChat:(NSInteger) chatId from:(NSInteger)from withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)newChat:(NSString *) title type:(NSString *) type targetType:(NSString *)targetType targetId:(NSInteger)targetId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)markChatViewed:(NSInteger) chatId to:(long)to withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)addChatTextLine:(NSInteger) chatId text:(NSString *) text withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;

// ----------------------------------------------
// APPCONFIG
// ----------------------------------------------
+(void)getAppConfig:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;

// ----------------------------------------------
// SUBSCRIPTIONS
// ----------------------------------------------
+(void)subscribe:(NSString *)productId receipt:(NSString *)receipt withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;
+(void)subscriptionStatus:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler;



@end
