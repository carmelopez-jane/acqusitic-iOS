//
//  WSDataManager.m
//  SegurParking
//
//  Created by Joan on 19/8/15.
//  Copyright (c) 2015 Bab Software. All rights reserved.
//

#import "Acqustic.h"
#import "WSDataManager.h"
#import <AFNetworking.h>
#import "AppDelegate.h"
#import "AppSession.h"
#import "Preferences.h"
#import "Reachability.h"
#import "NSData+Base64.h"

@implementation WSDataManager

+(void) init {
    
}

+(BOOL) isNetworkAvailable
{
    // Comprobamos si tenemos acceso a Internet
    Reachability * reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus st = [reach currentReachabilityStatus];
    if (st == NotReachable)
        return NO;
    else
        return YES;
}

+(id)cleanUpJson:(id)data
{
    if ([data isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary * res = [[NSMutableDictionary alloc] init];
        NSDictionary * dictData = (NSDictionary *)data;
        for (int i=0;i<dictData.allKeys.count;i++) {
            NSString * key = dictData.allKeys[i];
            if ([dictData[key] isKindOfClass:NSDictionary.class] || [dictData[key] isKindOfClass:NSArray.class]) {
                res[key] = [WSDataManager cleanUpJson:dictData[key]];
            } else if (![dictData[key] isEqual:[NSNull null]]) {
                res[key] = data[key];
            }
        }
        return res;
    } else if ([data isKindOfClass:NSArray.class]) {
        NSMutableArray * res = [[NSMutableArray alloc] init];
        NSArray * arrData = (NSArray *)data;
        for (int i=0;i<arrData.count;i++) {
            if ([arrData[i] isKindOfClass:NSDictionary.class] || [arrData[i] isKindOfClass:NSArray.class]) {
                [res addObject:[WSDataManager cleanUpJson:arrData[i]]];
            } else if (![arrData[i] isEqual:[NSNull null]]) {
                [res addObject:arrData[i]];
            }
            
        }
        return res;
    } else {
        return data;
    }
}
+(id)JSONfromString:(NSString *)string {
    NSData * tempData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:tempData options:0 error:&error];
    if (error != nil) {
        NSLog(@"JSON DECODING ERROR: %@", error);
        return nil;
    }
    return [WSDataManager cleanUpJson:jsonData];
}

+(NSString *)stringFromJSON:(id)json {
    NSError * error = nil;
    NSData * res = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
    if (error != nil) {
        NSLog(@"JSON ENCODING ERROR: %@", error);
        return nil;
    }
    return [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
}



// API AUTH / LOGIN
+(void)loginWithEmail:(NSString*)email
             andPassword:(NSString*)password
               withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler{
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            password, @"password",
                            @"ios", @"app_os",
                            [AppDelegate getAppVersion], @"app_version",
                            nil];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString * requestString = [NSString stringWithFormat:@"%@/auth/login", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
      parameters:params
        progress:nil
         success:^(NSURLSessionDataTask *operation, id responseObject) {
             NSDictionary * res = (NSDictionary *) responseObject;
             NSLog(@"LOGIN RES: %@", res);
             NSString * status = res[@"status"];
             if ([status isEqualToString:@"ok"]) {
                 NSString * token = res[@"data"][@"token"];
                 NSDictionary * userData = res[@"data"][@"user"];
                 NSLog(@"Logged succesfully");
                 NSLog(@"%@", responseObject);
                 /*
                 NSNumber * activated = userData[@"is_activated"];
                 if (![activated boolValue]) {
                     completionHandler(WS_ERROR_NOTACTIVATED, (NSDictionary *) responseObject, nil);
                     return;
                 }*/
                 // Todo OK. Podemos continuar
                 [theApp.appSession loggedIn:LOGGED_EMAIL authToken:token userData:userData];
                 [theApp.appSession saveUserInfo];
                 completionHandler(WS_SUCCESS, (NSDictionary *) responseObject, nil);

             } else {
                 completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
             }
         } failure:^(NSURLSessionDataTask *operation, NSError *error) {
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
             NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
             completionHandler((int)[httpResponse statusCode] ,nil, nil);
         }];
    
}

+(void)recoverPassword:(NSString*)email
             withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            nil];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString * requestString = [NSString stringWithFormat:@"%@/auth/recover", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  completionHandler(WS_SUCCESS, (NSDictionary *) responseObject, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];
    
}


+(void)refreshAuthToken:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            theApp.appSession.userInfo.authToken, @"token",
                            nil];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString * requestString = [NSString stringWithFormat:@"%@/auth/refresh", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSString * token = res[@"data"][@"token"];
                  NSDictionary * userData = res[@"data"][@"user"];
                  NSLog(@"Logged succesfully");
                  NSLog(@"%@", responseObject);
                  [theApp.appSession loggedIn:LOGGED_EMAIL authToken:token userData:userData];
                  [theApp.appSession saveUserInfo];
                  completionHandler(WS_SUCCESS, (NSDictionary *) responseObject, nil);
                  
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];
}

+(void)logOut:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    [WSDataManager linkDevice:@"" token:@"" lang:NSLocalizedString(@"lang", nil) withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
        [theApp.appSession loggedOut];
        completionHandler(WS_SUCCESS, nil, nil);
    }];
}


+(void)register:(UserInfo *)profile withPassword:(NSString *)password withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSDictionary *params = @{
                             @"email": profile.email,
                             @"password": password,
                             @"password_confirmation": password,
                             @"name": profile.name,
                             @"surname": profile.surname,
                             @"province": profile.province,
                             @"group": profile.group,
                             };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString * requestString = [NSString stringWithFormat:@"%@/auth/signup", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSString * token = res[@"data"][@"token"];
                  NSDictionary * userData = res[@"data"][@"user"];
                  NSLog(@"Logged succesfully");
                  NSLog(@"%@", responseObject);
                  /*
                  NSNumber * activated = userData[@"is_activated"];
                  if (![activated boolValue]) {
                      completionHandler(WS_ERROR_NOTACTIVATED, (NSDictionary *) responseObject, nil);
                      return;
                  }*/
                  // Todo OK. Podemos continuar
                  [theApp.appSession loggedIn:LOGGED_EMAIL authToken:token userData:userData];
                  [theApp.appSession saveUserInfo];
                  completionHandler(WS_SUCCESS, (NSDictionary *) responseObject, nil);
                  
              } else {
                  if (res[@"error"] && [res[@"error"] isEqualToString:@"already_registered"]) {
                      completionHandler(WS_ERROR_ALREADYREGISTERED, (NSDictionary *) responseObject, nil);
                  } else {
                      completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
                  }
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];
}

+(void)linkDevice:(NSString *)deviceId token:(NSString *)token lang:(NSString *)lang withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"device_type"] = @"ios";
    params[@"device_id"] = deviceId;
    params[@"device_token"] = token;
    params[@"device_lang"] = lang;
    params[@"app_os"] = @"ios";
    params[@"app_version"] = [AppDelegate getAppVersion];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/linkDevice", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  completionHandler(WS_SUCCESS, res, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

/*
+(void)updateProfile:(UserInfo *)profile withPassword:(NSString *)password oldPassword:(NSString *)oldPassword withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"email"] = profile.email;
    params[@"name"] = profile.name;
    params[@"surname"] = profile.surname;
    params[@"telephone"] = profile.telephone;
    params[@"city"] = profile.city;
    if (password && ![password isEqualToString:@""]) {
        params[@"oldpassword"] = oldPassword;
        params[@"password"] = password;
        params[@"password_confirmation"] = password;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/nestor/profile", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * userData = res[@"data"];
                  [theApp.appSession.userInfo update:userData];
                  [theApp.appSession saveUserInfo];
                  completionHandler(WS_SUCCESS, (NSDictionary *) userData, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];
}
*/


// ----------------------------------------------
// PROFILE
// ----------------------------------------------
+(void)getProfile:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/profile", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
             NSDictionary * res = (NSDictionary *) responseObject;
             NSLog(@"LOGIN RES: %@", res);
             NSString * status = res[@"status"];
             if ([status isEqualToString:@"ok"]) {
                 NSDictionary * userData = res[@"data"];
                 [theApp.appSession.userInfo update:userData];
                 [theApp.appSession saveUserInfo];
                 completionHandler(WS_SUCCESS, (NSDictionary *) userData, res[@"badges"]);
             } else {
                 completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
             }
         } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
             NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
             completionHandler((int)[httpResponse statusCode] ,nil, nil);
         }];
}

+(void)updateProfilePassword:(Account *)account withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    if (account.password && ![account.password isEqualToString:@""]) {
        params[@"oldpassword"] = account.oldPassword;
        params[@"password"] = account.password;
        params[@"password_confirmation"] = account.password;
    }

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/profile/password", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];
}

+(void)updatePerformerProfile:(Performer *) performer withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [performer fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/profile/performer", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];
}

+(void)uploadImage:(NSString *) file withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    NSDictionary * fileData = nil;
    if (![file isEqualToString:@""] && ![file hasPrefix:@"http"]) {
        NSData* fd = [NSData dataWithContentsOfFile:file];
        NSString * fdd = [fd base64EncodedString];
        fileData = @{
            @"name": file,
            @"data": fdd
        };
    }
    if (!fileData) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_OTHER, nil, nil);
        });
        return;
    }
    params[@"file"] = [WSDataManager stringFromJSON:fileData];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/images/upload", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];
}

+(void)uploadFile:(NSString *) file withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    NSDictionary * fileData = nil;
    if (![file isEqualToString:@""] && ![file hasPrefix:@"http"]) {
        NSData* fd = [NSData dataWithContentsOfFile:file];
        NSString * fdd = [fd base64EncodedString];
        fileData = @{
            @"name": file,
            @"data": fdd
        };
    }
    if (!fileData) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_OTHER, nil, nil);
        });
        return;
    }
    params[@"file"] = [WSDataManager stringFromJSON:fileData];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/files/upload", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];
}

+(void)deezerSearchSongs:(NSString *)search withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:RAPIDAPI_DEEZER_HOST forHTTPHeaderField:@"x-rapidapi-host"];
    [manager.requestSerializer setValue:RAPIDAPI_KEY forHTTPHeaderField:@"x-rapidapi-key"];
    
    NSString * requestString = [NSString stringWithFormat:@"https://%@/search?q=%@", RAPIDAPI_DEEZER_HOST,search];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            completionHandler(WS_SUCCESS, (NSDictionary *) res, nil);
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];
}

+(void)deezerGetTrack:(NSString *)trackId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:RAPIDAPI_DEEZER_HOST forHTTPHeaderField:@"x-rapidapi-host"];
    [manager.requestSerializer setValue:RAPIDAPI_KEY forHTTPHeaderField:@"x-rapidapi-key"];
    NSString * requestString = [NSString stringWithFormat:@"https://%@/track/%@", RAPIDAPI_DEEZER_HOST, trackId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            completionHandler(WS_SUCCESS, (NSDictionary *) res, nil);
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];
}

// ----------------------------------------------
// GROUPS
// ----------------------------------------------
+(void)getGroup:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld", APP_WS_URL, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];
}

+(void)updateGroup:(Group *)group withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [group fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/update", APP_WS_URL, group._id];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)newGroup:(NSString *)name withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    params[@"name"] = name;
    params[@"type"] = @"performer";
    params[@"location"] = theApp.appSession.performerProfile.city;
    params[@"province"] = theApp.appSession.performerProfile.province;
    params[@"performers"] = [NSString stringWithFormat:@"%ld", theApp.appSession.performerProfile._id];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/add", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)addGroupMemberByMail:(NSInteger) groupId email:(NSString *) email withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    params[@"email"] = email;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/members/add", APP_WS_URL, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  NSString * error = res[@"error"];
                  if (error && [error isEqualToString:@"user_not_found"]) {
                      completionHandler(WS_ERROR_USERNOTFOUND, (NSDictionary *) responseObject, nil);
                  } else {
                      completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
                  }
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)getGroupMember:(NSInteger) groupId memberId:(NSInteger)memberId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/members/%ld", APP_WS_URL, groupId, memberId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)updateGroupMember:(NSInteger) groupId performer:(Performer *)performer withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [performer fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/members/%ld/update", APP_WS_URL, groupId, performer._id];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)createGroupMember:(NSInteger) groupId performer:(Performer *)performer withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [performer fillInPostParams:params];
    params[@"groupId"] = [NSString stringWithFormat:@"%ld", groupId];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/members/create", APP_WS_URL, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)removeGroupMember:(NSInteger) groupId performer:(Performer *)performer withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    params[@"groupId"] = [NSString stringWithFormat:@"%ld", groupId];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/members/%ld/remove", APP_WS_URL, groupId, performer._id];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

// ----------------------------------------------
// AGENDA
// ----------------------------------------------
+(void)getGroupAgenda:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/agenda/group/%ld", APP_WS_URL, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];
}

+(void)getAgendaItem:(NSInteger) agendaitemId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/agenda/%ld", APP_WS_URL, agendaitemId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];
}

+(void)updateAgendaitem:(Agendaitem *)agendaitem withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [agendaitem fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/agenda/%ld/update", APP_WS_URL, agendaitem._id];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)removeAgendaitem:(Agendaitem *)agendaitem withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [agendaitem fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/agenda/%ld/remove", APP_WS_URL,agendaitem._id];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)addAgendaitem:(NSInteger) groupId agendaitem:(Agendaitem *)agendaitem withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    agendaitem.group_id = groupId;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [agendaitem fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/agenda/add", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

// ----------------------------------------------
// INVOICEREQS
// ----------------------------------------------
+(void)getInvoicereqs:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/invoicereqs/group/%ld", APP_WS_URL, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];
}

+(void)getInvoicereq:(NSInteger) itemId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/invoicereqs/%ld", APP_WS_URL, itemId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];
}

+(void)updateInvoicereq:(Invoicereq *)invoicereq withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [invoicereq fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/invoicereqs/%ld/update", APP_WS_URL, invoicereq._id];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)addInvoicereq:(NSInteger) groupId invoicereq: (Invoicereq *)invoicereq withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [invoicereq fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/invoicereqs/add", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)removeInvoicereq:(Invoicereq *)invoicereq withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/invoicereqs/%ld/remove", APP_WS_URL, invoicereq._id];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

// ----------------------------------------------
// ALBUMS
// ----------------------------------------------
+(void)getGroupAlbums:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/albums", APP_WS_URL, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)getGroupAlbum:(NSInteger) groupId albumId:(NSInteger)albumId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/albums/%ld", APP_WS_URL, groupId, albumId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)addGroupAlbum:(NSInteger) groupId album:(Album *)album withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [album fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/albums/add", APP_WS_URL, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}


+(void)updateGroupAlbum:(NSInteger) groupId album:(Album *) album withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [album fillInPostParams:params];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/albums/%ld/update", APP_WS_URL, groupId, album._id];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)removeGroupAlbum:(NSInteger) groupId album:(Album *) album withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/albums/%ld/remove", APP_WS_URL, groupId, album._id];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)addGroupAlbumSong:(NSInteger) groupId albumId:(NSInteger)albumId song:(Song *)song withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [song fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/albums/%ld/songs/add", APP_WS_URL, groupId, albumId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)attachGroupAlbumSong:(NSInteger) groupId albumId:(NSInteger) albumId songId:(NSInteger) songId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/albums/%ld/songs/attach/%ld", APP_WS_URL, groupId, albumId, songId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)removeGroupAlbumSong:(NSInteger) groupId albumId:(NSInteger) albumId songId:(NSInteger) songId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/albums/%ld/songs/remove/%ld", APP_WS_URL, groupId, albumId, songId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)publishGroupAlbum:(NSInteger) groupId albumId:(NSInteger) albumId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/albums/%ld/publish", APP_WS_URL, groupId, albumId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];
}

//--------------------------------------
// REPERTORIORE
//--------------------------------------
+(void)getGroupRepertoires:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/repertoires", APP_WS_URL, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];
}

+(void)getGroupRepertoire:(NSInteger) groupId repertoireId:(NSInteger) repertoireId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/repertoires/%ld", APP_WS_URL, groupId, repertoireId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)addGroupRepertoire:(NSInteger) groupId repertoire:(Repertoire *) repertoire withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [repertoire fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/repertoires/add", APP_WS_URL, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)updateGroupRepertoire:(NSInteger) groupId repertoire:(Repertoire *) repertoire withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [repertoire fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/repertoires/%ld/update", APP_WS_URL, groupId, repertoire._id];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)removeGroupRepertoire:(NSInteger) groupId repertoire:(Repertoire *) repertoire withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/repertoires/%ld/remove", APP_WS_URL, groupId, repertoire._id];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)addGroupRepertoireSong:(NSInteger)groupId repertoireId:(NSInteger)repertoireId song:(Song *)song withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [song fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/repertoires/%ld/songs/add", APP_WS_URL, groupId,repertoireId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)attachGroupRepertoireSong:(NSInteger) groupId repertoireId:(NSInteger)repertoireId songId:(NSInteger)songId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/repertoires/%ld/songs/attach/%ld", APP_WS_URL, groupId, repertoireId, songId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)removeGroupRepertoireSong:(NSInteger) groupId repertoireId:(NSInteger)repertoireId songId:(NSInteger)songId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/repertoires/%ld/songs/remove/%ld", APP_WS_URL, groupId, repertoireId, songId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

// ----------------------------------------------
// SONGS (catálogo completo de canciones del grupo)
// ----------------------------------------------
+(void)getSongs:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/songs", APP_WS_URL, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)getSong:(NSInteger) groupId itemId:(NSInteger) itemId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/songs/%ld", APP_WS_URL,groupId,itemId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)udpateSong:(Song *) item withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [item fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/songs/%ld/update", APP_WS_URL, item.group_id, item._id];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)addSong:(NSInteger) groupId song:(Song *)song withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    [song fillInPostParams:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/songs/add", APP_WS_URL, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

// ----------------------------------------------
// PERFORMANCES
// ----------------------------------------------
+(void)getPerformances:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/performances", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)getPerformance:(NSInteger) performanceId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/performances/%ld", APP_WS_URL, performanceId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)performanceRegister:(NSInteger) groupId performance:(Performance *)performance withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/performances/%ld/register/%ld", APP_WS_URL, performance._id, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)performanceRegisterMultiple:(NSString *) groups performance:(Performance  *)performance withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/performances/%ld/registermany/%@", APP_WS_URL, performance._id, groups];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)performanceRegisterMultiple:(NSString *) groups performanceId:(NSInteger)performanceId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/performances/%ld/registermany/%@", APP_WS_URL, performanceId, groups];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}


+(void)performanceConfirmCandidate:(NSInteger) groupId performance:(Performance  *) performance withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/performances/%ld/candidate/confirm/%ld", APP_WS_URL, performance._id, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)performanceRejectCandidate:(NSInteger) groupId performance:(Performance  *) performance withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/performances/%ld/candidate/reject/%ld", APP_WS_URL, performance._id, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)performanceConfirmSelected:(NSInteger) groupId performance:(Performance  *) performance dist:(PerformanceDist *)dist groupNotes:(NSString *)groupNotes withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    params[@"distribution"] = [dist getDistribution];
    params[@"group_notes"] = groupNotes;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/performances/%ld/selected/confirm/%ld", APP_WS_URL, performance._id, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)performanceRejectSelected:(NSInteger) groupId performance:(Performance  *) performance withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/performances/%ld/selected/reject/%ld", APP_WS_URL, performance._id, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}
// ----------------------------------------------
// PERMISOS
// ----------------------------------------------
+(void)requestSharePermissionPerformerProfile:(NSInteger) performerId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/profile/performer/%ld/permissions/share/request", APP_WS_URL, performerId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, (NSDictionary *)res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)confirmSharePermissionPerformerProfile:(NSInteger) performerId notificationId:(NSInteger) notificationId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/profile/performer/%ld/permissions/share/confirm/%ld", APP_WS_URL, performerId, notificationId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, (NSDictionary *)res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)denySharePermissionPerformerProfile:(NSInteger) performerId notificacionId:(NSInteger) notificationId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/profile/performer/%ld/permissions/share/deny/%ld", APP_WS_URL, performerId, notificationId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, (NSDictionary *)res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)requestSharePermissionGroupProfile:(NSInteger) groupId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/permissions/share/request", APP_WS_URL, groupId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, (NSDictionary *)res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, (NSDictionary *)res[@"badges"]);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)confirmSharePermissionGroupProfile:(NSInteger) groupId notificationId:(NSInteger)notificationId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/permissions/share/confirm/%ld", APP_WS_URL, groupId, notificationId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, (NSDictionary *)res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)denySharePermissionGroupProfile:(NSInteger) groupId notificationId:(NSInteger)notificationId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/group/%ld/permissions/share/deny/%ld", APP_WS_URL, groupId, notificationId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, (NSDictionary *)res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

// ----------------------------------------------
// NOTIFICACIONES
// ----------------------------------------------
+(void)getNotifications:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/notifications/notifications", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)getAllNotifications:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/notifications/notifications/all", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}

+(void)markNotificationAsDone:(NSInteger) notificationId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/notifications/%ld/maskAsDone", APP_WS_URL, notificationId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, res[@"badges"]);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)getNotificationBadges:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/notifications/badges", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                completionHandler(WS_SUCCESS, nil, res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];

}


// ----------------------------------------------
// CHATS
// ----------------------------------------------
+(void)getChats:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/chats", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];
}

+(void)getChat:(NSInteger) chatId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/chat/client/%ld", APP_WS_URL, chatId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];
}

+(void)getChat:(NSInteger) chatId from:(NSInteger)from withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/chat/client/%ld/from/%ld", APP_WS_URL, chatId, from];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, res[@"badges"]);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((int)[httpResponse statusCode] ,nil, nil);
        }];
}

+(void)newChat:(NSString *) title type:(NSString *) type targetType:(NSString *)targetType targetId:(NSInteger)targetId withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    params[@"title"] =  title;
    params[@"type"] = type;
    params[@"target_type"] = targetType;
    params[@"target_id"] = [NSString stringWithFormat:@"%ld", targetId];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/chat/client/add", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, res[@"badges"]);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)markChatViewed:(NSInteger) chatId to:(long)to withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/chat/client/task/%ld/viewed/%ld", APP_WS_URL, chatId, to];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

+(void)addChatTextLine:(NSInteger) chatId text:(NSString *) text withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    params[@"mode"] = @"text";
    params[@"text"] = text;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/chat/client/%ld/add", APP_WS_URL, chatId];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * data = res[@"data"];
                  completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];

}

// ----------------------------------------------
// APPCONFIG
// ----------------------------------------------
+(void)getAppConfig:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/config", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSLog(@"TOKEN: %@", theApp.appSession.userInfo.authToken);
    [manager GET:encodedUrl
        parameters:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nullable responseObject) {
            NSDictionary * res = (NSDictionary *) responseObject;
            NSString * status = res[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary * data = res[@"data"];
                completionHandler(WS_SUCCESS, (NSDictionary *) data, nil);
            } else {
                completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable operation, NSError * _Nonnull error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
            NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
            completionHandler((NSInteger)[httpResponse statusCode] ,nil, nil);
        }];
}



// ----------------------------------------------
// SUBSCRIPTIONS
// ----------------------------------------------
+(void)subscribe:(NSString *)productId receipt:(NSString *)receipt withBlock:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    if (![WSDataManager isNetworkAvailable]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            completionHandler(WS_ERROR_NONETWORKAVAIABLE, nil, nil);
        });
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // PONEMOS LOS PARAMETROS
    params[@"productId"] =  productId;
    params[@"receipt"] = receipt;
    params[@"app_os"] = @"ios";

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", theApp.appSession.userInfo.authToken] forHTTPHeaderField:@"Authorization"];
    NSString * requestString = [NSString stringWithFormat:@"%@/subscriptions/subscribe", APP_WS_URL];
    NSString* encodedUrl = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:encodedUrl
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary * res = (NSDictionary *) responseObject;
              NSLog(@"LOGIN RES: %@", res);
              NSString * status = res[@"status"];
              if ([status isEqualToString:@"ok"]) {
                  NSDictionary * userData = res[@"data"];
                  [theApp.appSession.userInfo update:userData];
                  [theApp.appSession saveUserInfo];
                  completionHandler(WS_SUCCESS, (NSDictionary *) userData, res[@"badges"]);
              } else {
                  completionHandler(WS_ERROR_OTHER, (NSDictionary *) responseObject, nil);
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
              NSLog(@"%@",[[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]);
              completionHandler((int)[httpResponse statusCode] ,nil, nil);
          }];


}

+(void)subscriptionStatus:(void(^)(int code, NSDictionary* result, NSDictionary * badges))completionHandler {
    [WSDataManager getProfile:completionHandler];
}








@end
