//
//  PerformanceGroup.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "PerformanceGroup.h"

@implementation PerformanceGroup

@synthesize group_id, group_name, status, group_members_data, created_at, updated_at;
@synthesize performance_id, performance_name, performance_status, performance_date, performance_type, performance_pub_mode;


-(id) init {
    if (self = [super init]) {
        group_name = @"";
        status = @"";
        group_members_data = @"";
        created_at = 0;
        updated_at = 0;
        performance_id = 0;
        performance_name = @"";
        performance_status = @"";
        performance_date = 0;
        performance_type = @"";
        performance_pub_mode = @"";
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
    if (data[@"group_id"] && data[@"group_id"] != NSNull.null)
        self.group_id = (NSInteger)[data[@"group_id"] integerValue];
    
    if (data[@"group_name"] && data[@"group_name"] != NSNull.null)
        group_name = data[@"group_name"];
    if (data[@"status"] && data[@"status"] != NSNull.null)
        status = data[@"status"];
    if (data[@"group_members_data"] && data[@"group_members_data"] != NSNull.null)
        group_members_data = data[@"group_members_data"];
    if (data[@"created_at"] && data[@"created_at"] != NSNull.null)
        created_at = (NSInteger)[data[@"created_at"] integerValue];
    if (data[@"updated_at"] && data[@"updated_at"] != NSNull.null)
        updated_at = (NSInteger)[data[@"updated_at"] integerValue];

    if (data[@"performance_id"] && data[@"performance_id"] != NSNull.null)
        performance_id = (NSInteger)[data[@"performance_id"] integerValue];
    if (data[@"performance_name"] && data[@"performance_name"] != NSNull.null)
        performance_name = data[@"performance_name"];
    if (data[@"performance_status"] && data[@"performance_status"] != NSNull.null)
        performance_status = data[@"performance_status"];
    if (data[@"performance_date"] && data[@"performance_date"] != NSNull.null)
        performance_date = (NSInteger)[data[@"performance_date"] integerValue];
    if (data[@"performance_type"] && data[@"performance_type"] != NSNull.null)
        performance_type = data[@"performance_type"];
    if (data[@"performance_pub_mode"] && data[@"performance_pub_mode"] != NSNull.null)
        performance_pub_mode = data[@"performance_pub_mode"];
}

-(NSString *) getTypology {
    NSString * typology = @"concert";
    if (performance_pub_mode != nil) {
        if ([performance_pub_mode isEqualToString:@"PUBLIC"] || [performance_pub_mode isEqualToString:@"PRIVATE"]) {
            typology = @"concert";
        } else if([performance_pub_mode isEqualToString:@"PROMO"]) {
            typology = @"promotion";
        } else if ([performance_pub_mode isEqualToString:@"SOLIDARITY"]) {
            typology = @"solidarity";
        } else {
            // De momento nada. Deber’amos poner tambiŽn las playlists ("editorial")
            typology = @"editorial";
        }
    }
    return typology; // concert, promotion / solidarity / editorial
}



@end

