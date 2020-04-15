//
//  Account.h
//  Acqustic
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@class Profile;
@class PlayerInfo;
@class ProfileInfo;

@interface Account : NSObject {
    NSInteger _id;
    NSString * oldPassword;
    NSString * password;
    NSString * password2;
}

@property NSInteger _id;
@property NSString * oldPassword;
@property NSString * password;
@property NSString * password2;

-(id) init;
-(id) initWithJSONString:(NSString *)json;
-(id) initWithDictionary:(NSDictionary *)data;

@end
