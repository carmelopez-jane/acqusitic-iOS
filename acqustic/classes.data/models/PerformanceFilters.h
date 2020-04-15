//
//  PerformanceFilters.h
//  Acqustic
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface PerformanceFilters : NSObject {
    NSInteger publish_date_from;
    NSInteger performance_date_from;
    NSString * typology;
    NSString * location_zone;
    NSString * cacheFrom;
    NSString * memberpreference;
    BOOL exclusive_acqustic;
    BOOL only_pro;
}

@property NSInteger publish_date_from;
@property NSInteger performance_date_from;
@property NSString * typology;
@property NSString * location_zone;
@property NSString * cacheFrom;
@property NSString * memberpreference;
@property BOOL exclusive_acqustic;
@property BOOL only_pro;

-(id) init;
-(void) reset;

@end
