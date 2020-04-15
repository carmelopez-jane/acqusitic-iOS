//
//  AppSession.h
//  vLex
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@class Profile;
@class PlayerInfo;
@class ProfileInfo;
@class Performer;
@class Group;

// Versión
#define APPSESSION_VERSION = 	"1.0";

// Modos de logged que puede haber
#define LOGGED_NOTLOGGEDIN          0
#define LOGGED_EMAIL                1
#define LOGGED_USERNAME             2
#define LOGGED_FACEBOOK             3
#define LOGGED_TWITTER              4
#define LOGGED_GOOGLE               5
#define LOGGED_LINKEDIN             6
#define LOGGED_VIVOPHONE            7

// DATOS DEL USUARIO (PROPIETARO DE LA CUENTA)
@interface UserInfo : NSObject {
    NSInteger loggedIn;
    
    // Información básica del usuario (equivalente a Server.registerUserResponse)
    NSString * authToken;
    NSInteger userId;
    NSString * email;
    NSString * pwd;
    // Datos del profile
    NSString * name;
    NSString * surname;
    NSString * avatar;
    NSString * province;
    NSString * group;
    
    // Información de suscripción
    NSInteger wasSubscribed;
    NSInteger isSubscribed;
    NSInteger subscriptionExpiration;
}

@property NSInteger loggedIn;
@property NSString * authToken;
@property NSInteger userId;
@property NSString * email;
@property NSString * pwd;
@property NSString * name;
@property NSString * surname;
@property NSString * avatar;
@property NSString * province;
@property NSString * group;
// Información de suscripción
@property NSInteger wasSubscribed;
@property NSInteger isSubscribed;
@property NSInteger subscriptionExpiration;

-(id) init;
-(id) initWithJSONString:(NSString *)json;
-(id) initWithDictionary:(NSDictionary *)data;
-(NSString *)saveToJSONString;
-(void)update:(NSDictionary *)data;

@end

@interface AppSession : NSObject {
    UserInfo * userInfo;
    Performer * performerProfile;
    Group * currentGroup;
}
// Info permanente
@property UserInfo * userInfo;
@property NSString * deviceId;
@property Performer * performerProfile;
@property Group * currentGroup;


+(AppSession *)init;
+(void)term;

-(id) init;
-(void) saveUserInfo;
-(void) loggedIn:(int)mode authToken:(NSString *)authToken userData:(NSDictionary *)userData;
-(void) updateAuthToken:(NSString *)newToken;
-(void) loggedOut;
-(BOOL) isLoggedIn;

-(BOOL) isSubscribed;
-(BOOL) wasSubscribed;

-(NSString *)getParam:(NSString *)key;
-(void) setParam:(NSString *)key withValue:(NSString *)value;
-(void) clearParam:(NSString *)key;

-(NSString *)getUserParam:(int)userId withKey:(NSString *)key;
-(void) setUserParam:(int)userId withKey:(NSString *)key andValue:(NSString *)value;
-(void)cleanUpAll;
-(NSString *)getRandomDeviceId;

@end

// SINGLETON DE LA SESION
extern AppSession * AppSession_instance;

