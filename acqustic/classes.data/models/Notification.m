//
//  Notification.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Notification.h"

@implementation Notification

@synthesize _id, user_id, type, message, param1, param2, param3, param4, param5, created_at;


-(id) init {
    if (self = [super init]) {
        type = @"";
        message = @"";
        param1 = @"";
        param2 = @"";
        param3 = @"";
        param4 = @"";
        param5 = @""; 
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
    
    if (data[@"user_id"] && data[@"user_id"] != NSNull.null)
        user_id = (NSInteger)[data[@"user_id"] integerValue];
    if (data[@"type"] && data[@"type"] != NSNull.null)
        type = data[@"type"];
    if (data[@"message"] && data[@"message"] != NSNull.null)
        message = data[@"message"];
    if (data[@"param1"] && data[@"param1"] != NSNull.null)
        param1 = data[@"param1"];
    if (data[@"param2"] && data[@"param2"] != NSNull.null)
        param2 = data[@"param2"];
    if (data[@"param3"] && data[@"param3"] != NSNull.null)
        param3 = data[@"param3"];
    if (data[@"param4"] && data[@"param4"] != NSNull.null)
        param4 = data[@"param4"];
    if (data[@"param5"] && data[@"param5"] != NSNull.null)
        param5 = data[@"param5"];
    if (data[@"created_at"] && data[@"created_at"] != NSNull.null)
        created_at = (NSInteger)[data[@"created_at"] integerValue];
}


@end

