//
//  Agendaitem.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "AgendaItem.h"

@implementation Agendaitem

@synthesize _id, group_id, description, performance_date, type, venue, address, postcode, city, province, country;


-(id) init {
    if (self = [super init]) {
        description = @"";
        performance_date = 0;
        type = @"";
        venue = @"";
        address = @"";
        postcode = @"";
        city = @"";
        province  = @"";
        country = @"es";
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
    if (data[@"group_id"] && data[@"group_id"] != NSNull.null)
        self.group_id = (NSInteger)[data[@"group_id"] integerValue];
    if (data[@"description"] && data[@"description"] != NSNull.null)
        self.description = data[@"description"];
    if (data[@"performance_date"] && data[@"performance_date"] != NSNull.null)
        self.performance_date = (NSInteger)[data[@"performance_date"] integerValue];
    if (data[@"type"] && data[@"type"] != NSNull.null)
        self.type = data[@"type"];
    if (data[@"venue"] && data[@"venue"] != NSNull.null)
        self.venue = data[@"venue"];
    if (data[@"address"] && data[@"address"] != NSNull.null)
        self.address = data[@"address"];
    if (data[@"postcode"] && data[@"postcode"] != NSNull.null)
        self.postcode = data[@"postcode"];
    if (data[@"city"] && data[@"city"] != NSNull.null)
        self.city = data[@"city"];
    if (data[@"province"] && data[@"province"] != NSNull.null)
        self.province = data[@"province"];
    if (data[@"country"] && data[@"country"] != NSNull.null)
        self.country = data[@"country"];
}

-(NSMutableDictionary *) fillInPostParams:(NSMutableDictionary *)dict {
    if (!dict)
        dict = [[NSMutableDictionary alloc] init];
    dict[@"id"] = [NSNumber numberWithInteger:self._id];
    dict[@"group_id"] = [NSNumber numberWithInteger:self.group_id];
    dict[@"description"] = self.description;
    dict[@"performance_date"] = [NSNumber numberWithInteger:self.performance_date];
    dict[@"type"] = self.type;
    dict[@"venue"] = self.venue;
    dict[@"address"] = self.address;
    dict[@"postcode"] = self.postcode;
    dict[@"city"] = self.city;
    dict[@"province"] = self.province;
    dict[@"country"] = self.country;
    return dict;
}


@end

