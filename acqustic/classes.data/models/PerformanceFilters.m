//
//  PerformanceFilters.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "PerformanceFilters.h"

@implementation PerformanceFilters

@synthesize publish_date_from, performance_date_from, typology, location_zone, cacheFrom, memberpreference, exclusive_acqustic, only_pro;


-(id) init {
    if (self = [super init]) {
        publish_date_from = 0;
        performance_date_from = 0;
        typology = @"";
        location_zone = @"";
        cacheFrom = @"";
        memberpreference = @"";
        exclusive_acqustic = NO;
        only_pro = NO;
        return self;
    } else {
        return nil;
    }
}

-(void) reset {
    publish_date_from = 0;
    performance_date_from = 0;
    typology = @"";
    location_zone = @"";
    cacheFrom = @"";
    memberpreference = @"";
    exclusive_acqustic = NO;
    only_pro = NO;
}

@end

