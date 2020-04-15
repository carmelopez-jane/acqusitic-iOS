//
//  Performance.h
//  Acqustic
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@class PerformanceFilters;

@interface Performance : NSObject {
    NSInteger _id;
    NSInteger offer_id;
    NSString * name;
    NSString * description;
    NSString * access_status;
    NSString * offer_name;
    NSString * offer_promo_segment;
    NSString * offer_promo_subsegment;
    NSString * channel;
    NSString * promoter_name;
    NSString * management_mode;
    NSString * pub_mode;
    NSString * status;
    BOOL exclusive_acqustic;
    int already_registered;
    NSInteger performance_date;
    NSInteger performance_time;
    NSInteger performance_enddate;
    NSInteger publish_date;
    NSInteger overdue_date;
    NSInteger reg_limit;
    NSInteger cand_limit;
    NSInteger sel_limit;
    NSString * membercount;
    NSString * memberpreference; /* LLEGA COMO ARRAY */
    double cache_single;
    double cache_duo;
    double cache_trio;
    double cache_band;
    double cache_dj;

    NSString * location_zone;
    NSString * provisional_location;
    NSInteger location_id;
    NSString * location_name;
    NSString * location_address;
    NSString * location_postcode;
    NSString * location_city;
    NSString * location_latitude;
    NSString * location_longitude;

    NSString * group_equipment;
    NSString * group_info;
    NSString * roadmap_document;

    NSMutableArray * regs; // PerformanceGroup
    NSMutableArray * cands; // PerformanceGroup
    NSMutableArray * sels; // PerformanceGroup


    // Información privada
    int flavour;
    BOOL isBackVisible;
    int cardWidth;
    int cardHeight;
}

@property NSInteger _id;
@property NSInteger offer_id;
@property NSString * name;
@property NSString * description;
@property NSString * access_status;
@property NSString * offer_name;
@property NSString * offer_promo_segment;
@property NSString * offer_promo_subsegment;
@property NSString * channel;
@property NSString * promoter_name;
@property NSString * management_mode;
@property NSString * pub_mode;
@property NSString * status;
@property BOOL exclusive_acqustic;
@property int already_registered;
@property NSInteger performance_date;
@property NSInteger performance_time;
@property NSInteger performance_enddate;
@property NSInteger publish_date;
@property NSInteger overdue_date;
@property NSInteger reg_limit;
@property NSInteger cand_limit;
@property NSInteger sel_limit;
@property NSString * membercount;
@property NSString * memberpreference; /* LLEGA COMO ARRAY */
@property double cache_single;
@property double cache_duo;
@property double cache_trio;
@property double cache_band;
@property double cache_dj;

@property NSString * location_zone;
@property NSString * provisional_location;
@property NSInteger location_id;
@property NSString * location_name;
@property NSString * location_address;
@property NSString * location_postcode;
@property NSString * location_city;
@property NSString * location_latitude;
@property NSString * location_longitude;

@property NSString * group_equipment;
@property NSString * group_info;
@property NSString * roadmap_document;

@property NSMutableArray * regs; // PerformanceGroup
@property NSMutableArray * cands; // PerformanceGroup
@property NSMutableArray * sels; // PerformanceGroup

@property int flavour;
@property BOOL isBackVisible;
@property int cardWidth;
@property int cardHeight;

-(id) init;
-(id) initWithJSONString:(NSString *)json;
-(id) initWithDictionary:(NSDictionary *)data;
-(BOOL) hasGroup:(NSInteger) groupId;
-(BOOL) isRegistered:(NSInteger) groupId;
-(BOOL) isCandidate:(NSInteger) groupId;
-(BOOL) isSelected:(NSInteger) groupId;
-(BOOL) isRegistered;
-(BOOL) isCandidate;
-(BOOL) isSelected;
-(BOOL) isWinner:(NSInteger)groupId;
-(BOOL) isWinner;

-(BOOL) isFreemium;

-(NSString *) getRegisteredStatus:(NSInteger) groupId;
-(NSString *) getCandidateStatus:(NSInteger) groupId;
-(NSString *) getSelectedStatus:(NSInteger) groupId;
-(void) setRandomFlavour;
-(BOOL) matchesSearch:(NSString *) text;
-(NSString *) getMemberCountFormatted;
-(NSString *) getCacheFormatted;
-(NSArray *) getCacheRange;
-(BOOL) cacheInRange:(double) from;
-(NSString *) getTypology;
-(NSString *) getTypologyAsText;
-(NSString *) getVenue;
-(BOOL) checkFilter:(PerformanceFilters *)filters;

@end
