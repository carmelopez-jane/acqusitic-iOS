//
//  AppSession.m
//  vlex
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "AppSession.h"

@implementation UserInfo

@synthesize loggedIn, authToken, userId, email, pwd;
@synthesize name, surname, province, avatar, group;

-(id) init {
    if (self = [super init]) {
        self.loggedIn = LOGGED_NOTLOGGEDIN;
        // Información básica del usuario (equivalente a Server.registerUserResponse)
        self.authToken = @"";
        self.userId = 0;
        
        // Seed para obtener un random DeviceId
        srand48(arc4random());
        
        return self;
    } else {
        return nil;
    }
}

-(id) initWithJSONString:(NSString *)json {
    
    // Inicialización por defecto
    self = [self init];
    if (self == nil)
        return nil;
    
    NSError *jsonError;
    NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    if (data != nil) {
        [self loadFromDict:data];
    }
    return self;
}

-(id) initWithDictionary:(NSDictionary *)data {
    
    // Inicialización por defecto
    self = [self init];
    if (self == nil)
        return nil;
    if (data != nil) {
        [self loadFromDict:data];
    }
    return self;
}

-(void) loadFromDict:(NSDictionary *)data {
    if (data[@"loggedIn"] && data[@"loggedIn"] != NSNull.null)
        self.loggedIn = (NSInteger)[data[@"loggedIn"] integerValue];
    if (data[@"authToken"] && data[@"authToken"] != NSNull.null)
        self.authToken = data[@"authToken"];
    if (data[@"userId"] && data[@"userId"] != NSNull.null)
        self.userId = [data[@"id"] integerValue];
    if (data[@"email"] && data[@"email"] != NSNull.null)
        self.email = data[@"email"];
    if (data[@"name"] && data[@"name"] != NSNull.null)
        self.name = data[@"name"];
    if (data[@"surname"] && data[@"surname"] != NSNull.null)
        self.surname = data[@"surname"];
    if (data[@"avatar"] && data[@"avatar"] != NSNull.null)
        self.avatar = data[@"avatar"];
    if (data[@"province"] && data[@"province"] != NSNull.null)
        self.province = data[@"province"];
    if (data[@"group"] && data[@"group"] != NSNull.null)
        self.group = data[@"group"];
    if (data[@"wasSubscribed"] && data[@"wasSubscribed"] != NSNull.null)
        self.wasSubscribed = [data[@"wasSubscribed"] integerValue];
    if (data[@"isSubscribed"] && data[@"isSubscribed"] != NSNull.null)
        self.isSubscribed = [data[@"isSubscribed"] integerValue];
    if (data[@"subscriptionExpiration"] && data[@"subscriptionExpiration"] != NSNull.null)
        self.subscriptionExpiration = [data[@"subscriptionExpiration"] integerValue];
}

-(NSString *)saveToJSONString {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    dict[@"loggedIn"] = [NSNumber numberWithInteger:self.loggedIn];
    dict[@"authToken"] = self.authToken;
    dict[@"id"] = [NSNumber numberWithInteger:self.userId];
    dict[@"email"] = self.email;
    dict[@"name"] = self.name;
    dict[@"surname"] = self.surname;
    dict[@"province"] = self.province;
    dict[@"avatar"] = self.avatar;
    dict[@"group"] = self.group;
    dict[@"wasSubscribed"] = [NSNumber numberWithInteger:self.wasSubscribed];
    dict[@"isSubscribed"] = [NSNumber numberWithInteger:self.isSubscribed];
    dict[@"subscriptionExpiration"] = [NSNumber numberWithInteger:self.subscriptionExpiration];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0 /*NSJSONWritingPrettyPrinted*/ // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        return nil;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}

-(void)update:(NSDictionary *)data {
    if (data != nil) {
        [self loadFromDict:data];
    }
}


@end



AppSession * AppSession_instance = nil;

@implementation AppSession;

@synthesize userInfo;
@synthesize performerProfile;
@synthesize currentGroup;
@synthesize deviceId;

+(AppSession *)init {
    AppSession_instance = [[AppSession alloc] init];
    return AppSession_instance;
}

+(void)term {
    if (AppSession_instance != nil) {
        AppSession_instance = nil;
    }
}

-(id) init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString * userInfoData = [defaults objectForKey:@"__userInfo"];
        if (userInfoData) {
            userInfo = [[UserInfo alloc] initWithJSONString:userInfoData];
        } else {
            userInfo = [[UserInfo alloc] init];
        }
        NSString * devId = [defaults objectForKey:@"__deviceId"];
        if (devId == nil) {
            devId = [self getRandomDeviceId];
            [defaults setObject:devId forKey:@"__deviceId"];
            [defaults synchronize];
        }
        deviceId = devId;
        return self;
    } else {
        return nil;
    }
}

-(void) saveUserInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * userInfoData = [userInfo saveToJSONString];
    if (userInfoData) {
        [defaults setObject:userInfoData forKey:@"__userInfo"];
    }
    [defaults synchronize];
}

-(void) loggedIn:(int)mode authToken:(NSString *)authToken userData:(NSDictionary *)userData {
    userInfo = [[UserInfo alloc] init];
    userInfo.loggedIn = mode;
    userInfo.authToken = authToken;
    
    [userInfo update:userData];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * userInfoData = [userInfo saveToJSONString];
    if (userInfoData) {
        [defaults setObject:userInfoData forKey:@"__userInfo"];
    }
    [defaults synchronize];
}

-(void) updateAuthToken:(NSString *)newToken {
    
    userInfo.authToken = newToken;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * userInfoData = [userInfo saveToJSONString];
    if (userInfoData) {
        [defaults setObject:userInfoData forKey:@"__userInfo"];
    }
    [defaults synchronize];

}

-(void) loggedOut
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"__userInfo"];
    [defaults synchronize];
    userInfo = [[UserInfo alloc] init];
}

-(BOOL) isLoggedIn
{
    if (userInfo && userInfo.loggedIn != LOGGED_NOTLOGGEDIN)
        return YES;
    return NO;
}


-(BOOL) isSubscribed {
    if (!userInfo)
        return NO;
    NSInteger now = [[NSDate date] timeIntervalSince1970];
    if (userInfo.isSubscribed && now < userInfo.subscriptionExpiration/1000 )
        return YES;
    else
        return NO;
}

-(BOOL) wasSubscribed {
    if (!userInfo)
        return NO;
    NSInteger now = [[NSDate date] timeIntervalSince1970];
    if (userInfo.isSubscribed && now > userInfo.subscriptionExpiration)
        return YES;
    else if (userInfo.wasSubscribed)
        return YES;
    else
        return NO;
}



-(NSString *)getParam:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * realKey = [NSString stringWithFormat:@"P:%@", key];
    return [defaults objectForKey:realKey];
}

-(void) setParam:(NSString *)key withValue:(NSString *)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * realKey = [NSString stringWithFormat:@"P:%@", key];
    [defaults setObject:value forKey:realKey];
    [defaults synchronize];
}

-(void) clearParam:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * realKey = [NSString stringWithFormat:@"P:%@", key];
    [defaults removeObjectForKey:realKey];
    [defaults synchronize];
}

-(NSString *)getUserParam:(int)userId withKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * realKey = [NSString stringWithFormat:@"UP[%d]:%@", userId, key];
    return [defaults objectForKey:realKey];
}

-(void) setUserParam:(int)userId withKey:(NSString *)key andValue:(NSString *)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * realKey = [NSString stringWithFormat:@"UP[%d]:%@", userId, key];
    [defaults setObject:value forKey:realKey];
    [defaults synchronize];
}

-(void)cleanUpAll
{
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
}

-(NSString *)getRandomDeviceId
{
    NSString * randomId = [self getParam:@"randomDeviceId"];
    if (randomId == nil || [randomId isEqualToString:@""]) {
        long long time = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
        double number = drand48() * 100000;
        randomId = [NSString stringWithFormat:@"UIOS-I%lld-%lf", time, number];
        [self setParam:@"randomDeviceId" withValue:randomId];
    }
    return randomId;
}

@end
