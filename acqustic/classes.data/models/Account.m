//
//  Account.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Account.h"

@implementation Account

@synthesize _id, oldPassword, password, password2;

-(id) init {
    if (self = [super init]) {
        oldPassword = @"";
        password = @"";
        password2 = @"";
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
    
    if (data[@"id"] && data[@"id"] != NSNull.null)
        self._id = (NSInteger)[data[@"id"] integerValue];
    if (data[@"oldPassword"] && data[@"oldPassword"] != NSNull.null)
        self.oldPassword = data[@"oldPassword"];
    if (data[@"password"] && data[@"password"] != NSNull.null)
        self.password = data[@"password"];
    if (data[@"password2"] && data[@"password2"] != NSNull.null)
        self.password2 = data[@"password2"];
}


@end

