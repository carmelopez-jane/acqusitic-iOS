//
//  Performance.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Acqustic.h"
#import "AppSession.h"
#import "AppDelegate.h"
#import "Performance.h"
#import "PerformanceGroup.h"
#import "PerformanceFilters.h"
#import "Performer.h"
#import "Group.h"

static int lastFlavIndex = -1;


@implementation Performance

@synthesize _id, offer_id, name, description, access_status, offer_name, offer_promo_segment, offer_promo_subsegment, channel, promoter_name, management_mode, pub_mode, status, exclusive_acqustic, already_registered, performance_date, performance_time, performance_enddate, publish_date, overdue_date, reg_limit, cand_limit, sel_limit, membercount, memberpreference, cache_single, cache_duo, cache_trio, cache_band, cache_dj;

@synthesize location_zone, provisional_location, location_id, location_name, location_address, location_postcode, location_city, location_latitude, location_longitude, group_equipment, group_info, roadmap_document;

@synthesize regs, cands, sels; // PerformanceGroup

@synthesize flavour;
@synthesize isBackVisible;
@synthesize cardWidth, cardHeight;


-(id) init {
    if (self = [super init]) {
        regs = [[NSMutableArray alloc] init];
        cands = [[NSMutableArray alloc] init];
        sels = [[NSMutableArray alloc] init];
        name = @"";
        description = @"";
        access_status = @"";
        offer_name = @"";
        offer_promo_segment = @"";
        offer_promo_subsegment = @"";
        channel = @"";
        promoter_name = @"";
        management_mode = @"";
        pub_mode = @"";
        status = @"";
        exclusive_acqustic = NO;
        performance_date = 0;
        performance_time = 0;
        performance_enddate = 0;
        publish_date = 0;
        overdue_date = 0;
        reg_limit = 0;
        cand_limit = 0;
        sel_limit = 0;
        membercount = 0;
        memberpreference = @"";
        cache_single = 0;
        cache_duo = 0;
        cache_trio = 0;
        cache_band = 0;
        cache_dj = 0;
        already_registered = 0;
        location_zone = @"";
        provisional_location = @"";
        location_id = 0;
        location_name = @"";
        location_address = @"";
        location_postcode = @"";
        location_city = @"";
        location_latitude = @"";
        location_longitude = @"";
        group_equipment = @"";
        group_info = @"";;
        roadmap_document = @"";
        
        return self;
    } else {
        return nil;
    }
}

-(id) initWithJSONString:(NSString *)json {
    
    // Inicializaci—n por defecto
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
    
    // Inicializaci—n por defecto
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
    if (data[@"offer_id"] && data[@"offer_id"] != NSNull.null)
        offer_id =  (NSInteger)[data[@"offer_id"] integerValue];
    if (data[@"name"] && data[@"name"] != NSNull.null)
        name = data[@"name"];
    if (data[@"description"] && data[@"description"] != NSNull.null)
        description = data[@"description"];
    if (data[@"access_status"] && data[@"access_status"] != NSNull.null)
        access_status = data[@"access_status"];
    if (data[@"offer_name"] && data[@"offer_name"] != NSNull.null)
        offer_name = data[@"offer_name"];
    if (data[@"offer_promo_segment"] && data[@"offer_promo_segment"] != NSNull.null)
        offer_promo_segment = data[@"offer_promo_segment"];
    if (data[@"offer_promo_subsegment"] && data[@"offer_promo_subsegment"] != NSNull.null)
        offer_promo_subsegment = data[@"offer_promo_subsegment"];
    if (data[@"channel"] && data[@"channel"] != NSNull.null)
        channel = data[@"channel"];
    if (data[@"promoter_name"] && data[@"promoter_name"] != NSNull.null)
        promoter_name = data[@"promoter_name"];
    if (data[@"management_mode"] && data[@"management_mode"] != NSNull.null)
        management_mode = data[@"management_mode"];
    if (data[@"pub_mode"] && data[@"pub_mode"] != NSNull.null)
        pub_mode = data[@"pub_mode"];
    if (data[@"status"] && data[@"status"] != NSNull.null)
        status = data[@"status"];
    if (data[@"exclusive_acqustic"] && data[@"exclusive_acqustic"] != NSNull.null)
        exclusive_acqustic = (NSInteger)[data[@"exclusive_acqustic"] integerValue];
    if (data[@"performance_date"] && data[@"performance_date"] != NSNull.null)
        performance_date = (NSInteger)[data[@"performance_date"] integerValue];
    if (data[@"performance_time"] && data[@"performance_time"] != NSNull.null)
        performance_time = (NSInteger)[data[@"performance_time"] integerValue];
    if (data[@"performance_enddate"] && data[@"performance_enddate"] != NSNull.null)
        performance_enddate = (NSInteger)[data[@"performance_enddate"] integerValue];
    if (data[@"publish_date"] && data[@"publish_date"] != NSNull.null)
        publish_date = (NSInteger)[data[@"publish_date"] integerValue];
    if (data[@"overdue_date"] && data[@"overdue_date"] != NSNull.null)
        overdue_date = (NSInteger)[data[@"overdue_date"] integerValue];
    if (data[@"reg_limit"] && data[@"reg_limit"] != NSNull.null)
        reg_limit = (NSInteger)[data[@"reg_limit"] integerValue];
    if (data[@"cand_limit"] && data[@"cand_limit"] != NSNull.null)
        cand_limit = (NSInteger)[data[@"cand_limit"] integerValue];
    if (data[@"sel_limit"] && data[@"sel_limit"] != NSNull.null)
        sel_limit = (NSInteger)[data[@"sel_limit"] integerValue];
    if (data[@"membercount"] && data[@"membercount"] != NSNull.null)
        membercount = [NSString stringWithFormat:@"%@",data[@"membercount"]]; // Puede llegar como NSNumber...
    if (data[@"cache_single"] && data[@"cache_single"] != NSNull.null)
        cache_single = (double)[data[@"cache_single"] doubleValue];
    if (data[@"cache_duo"] && data[@"cache_duo"] != NSNull.null)
        cache_duo = (double)[data[@"cache_duo"] doubleValue];
    if (data[@"cache_trio"] && data[@"cache_trio"] != NSNull.null)
        cache_trio = (double)[data[@"cache_trio"] doubleValue];
    if (data[@"cache_band"] && data[@"cache_band"] != NSNull.null)
        cache_band = (double)[data[@"cache_band"] doubleValue];
    if (data[@"cache_dj"] && data[@"cache_dj"] != NSNull.null)
        cache_dj = (double)[data[@"cache_dj"] doubleValue];
    if (data[@"location_zone"] && data[@"location_zone"] != NSNull.null)
        location_zone = data[@"location_zone"];
    if (data[@"provisional_location"] && data[@"provisional_location"] != NSNull.null)
        provisional_location = data[@"provisional_location"];
    if (data[@"location_id"] && data[@"location_id"] != NSNull.null)
        location_id = (NSInteger)[data[@"location_id"] integerValue];
    if (data[@"location_name"] && data[@"location_name"] != NSNull.null)
        location_name = data[@"location_name"];
    if (data[@"location_address"] && data[@"location_address"] != NSNull.null)
        location_address = data[@"location_address"];
    if (data[@"location_postcode"] && data[@"location_postcode"] != NSNull.null)
        location_postcode = data[@"location_postcode"];
    if (data[@"location_city"] && data[@"location_city"] != NSNull.null)
        location_city = data[@"location_city"];
    if (data[@"location_latitude"] && data[@"location_latitude"] != NSNull.null)
        location_latitude = data[@"location_latitude"];
    if (data[@"location_longitude"] && data[@"location_longitude"] != NSNull.null)
        location_longitude = data[@"location_longitude"];
    if (data[@"group_equipment"] && data[@"group_equipment"] != NSNull.null)
        group_equipment = data[@"group_equipment"];
    if (data[@"group_info"] && data[@"group_info"] != NSNull.null)
        group_info = data[@"group_info"];
    if (data[@"roadmap_document"] && data[@"roadmap_document"] != NSNull.null)
        roadmap_document = data[@"roadmap_document"];
    if (data[@"already_registered"] && data[@"already_registered"] != NSNull.null)
        already_registered = (int)[data[@"already_registered"] intValue];

    // Member preferences
    NSArray * mps = data[@"memberpreference"];
    memberpreference = @"";
    if (data[@"memberpreference"] != NSNull.null && mps && mps.count > 0) {
        for (int i=0;i<mps.count;i++) {
            NSString * mp = mps[i];
            if (mp) {
                if (i > 0)
                    memberpreference = [memberpreference stringByAppendingString:@","];
                memberpreference = [memberpreference stringByAppendingString:mp];
            }
        }
    }

    // Ahora los regs
    NSArray * gs = data[@"reggroups"];
    if (gs) {
        for (int i = 0; i < gs.count; i++) {
            NSDictionary * gr = gs[i];
            PerformanceGroup * group = [[PerformanceGroup alloc] initWithDictionary:gr];
            group.performance_id = self._id;
            group.performance_name = self.name;
            group.performance_status = self.status;
            group.performance_date = self.performance_date;
            [regs addObject:group];
        }
    }
    // Ahora los cands
    gs = data[@"candgroups"];
    if (gs) {
        for (int i = 0; i < gs.count; i++) {
            NSDictionary * gr = gs[i];
            PerformanceGroup * group = [[PerformanceGroup alloc] initWithDictionary:gr];
            group.performance_id = self._id;
            group.performance_name = self.name;
            group.performance_status = self.status;
            group.performance_date = self.performance_date;
            [cands addObject:group];
        }
    }
    // Ahora los sels
    gs = data[@"selgroups"];
    if (gs) {
        for (int i = 0; i < gs.count; i++) {
            NSDictionary * gr = gs[i];
            PerformanceGroup * group = [[PerformanceGroup alloc] initWithDictionary:gr];
            group.performance_id = self._id;
            group.performance_name = self.name;
            group.performance_status = self.status;
            group.performance_date = self.performance_date;
            [sels addObject:group];
        }
    }

    // Por defecto ponemos un color aleatorio
    [self setRandomFlavour];

}

-(BOOL) hasGroup:(NSInteger) groupId {
    for (int i=0;i<regs.count;i++) {
        if (((PerformanceGroup *)regs[i]).group_id == groupId)
            return YES;
    }
    for (int i=0;i<cands.count;i++) {
        if (((PerformanceGroup *)cands[i]).group_id == groupId)
            return YES;
    }
    for (int i=0;i<sels.count;i++) {
        if (((PerformanceGroup *)sels[i]).group_id == groupId)
            return YES;
    }
    return NO;
}

-(BOOL) isRegistered:(NSInteger) groupId {
    for (int i=0;i<regs.count;i++) {
        PerformanceGroup * group = regs[i];
        if (group.group_id == groupId)
            return YES;
    }
    return NO;
}

-(BOOL) isCandidate:(NSInteger) groupId {
    for (int i=0;i<cands.count;i++) {
        PerformanceGroup * group = cands[i];
        if (group.group_id == groupId)
            return YES;
    }
    return NO;
}

-(BOOL) isSelected:(NSInteger) groupId {
    for (int i=0;i<sels.count;i++) {
        PerformanceGroup * group = sels[i];
        if (group.group_id == groupId)
            return YES;
    }
    return NO;
}

-(BOOL) isRegistered {
    for (int i=0;i<theApp.appSession.performerProfile.groups.count;i++) {
        Group * g = theApp.appSession.performerProfile.groups[i];
        if ([self isRegistered:g._id]) {
            return YES;
        }
    }
    return NO;
}


-(BOOL) isCandidate {
    for (int i=0;i<theApp.appSession.performerProfile.groups.count;i++) {
        Group * g = theApp.appSession.performerProfile.groups[i];
        if ([self isSelected:g._id]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL) isSelected {
    for (int i=0;i< theApp.appSession.performerProfile.groups.count;i++) {
        Group * g = theApp.appSession.performerProfile.groups[i];
        if ([self isSelected:g._id]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL) isWinner:(NSInteger)groupId {
    for (int i=0;i<sels.count;i++) {
        PerformanceGroup * group = sels[i];
        if (group.group_id == groupId && [group.status isEqualToString:@"CONFIRMED"])
            return YES;
    }
    return NO;
}

-(BOOL) isWinner {
    for (int i=0;i<theApp.appSession.performerProfile.groups.count;i++) {
        Group * g = theApp.appSession.performerProfile.groups[i];
        if ([self isWinner:g._id]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL) isFreemium {
    if (self.access_status && [self.access_status isEqualToString:@"FREE"]) {
        return YES;
    } else {
        return NO;
    }
}


-(NSString *) getRegisteredStatus:(NSInteger) groupId {
    for (int i=0;i<regs.count;i++) {
        PerformanceGroup * group = regs[i];
        if (group.group_id == groupId)
            return group.status;
    }
    return @"";
}

-(NSString *) getCandidateStatus:(NSInteger) groupId {
    for (int i=0;i<cands.count;i++) {
        PerformanceGroup * group = cands[i];
        if (group.group_id == groupId)
            return group.status;
    }
    return @"";
}

-(NSString *) getSelectedStatus:(NSInteger) groupId {
    for (int i=0;i<sels.count;i++) {
        PerformanceGroup * group = sels[i];
        if (group.group_id == groupId)
            return group.status;
    }
    return @"";
}

-(NSString *) getVenue {
    if (location_id == 0)
        return nil;
    NSString * res = @"";
    if (location_name)
        res = [res stringByAppendingFormat:@"%@. ", location_name];
    if (location_address && ![location_address isEqualToString:@""])
        res = [res stringByAppendingFormat:@"%@. ", location_address];
    if (location_postcode && ![location_postcode isEqualToString:@""])
        res = [res stringByAppendingFormat:@"%@ ", location_postcode];
    if (location_city && ![location_city isEqualToString:@""])
        res = [res stringByAppendingFormat:@"%@ ", location_city];
    
    return [res stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];    
}

  
-(void) setRandomFlavour {
    int flavs[] = {
        0xFF272c51, // R.drawable.card_bk_blue,
        0xFFedbd45, // R.drawable.card_bk_yellow,
        0xFF1965dd, // R.drawable.card_bk_lightblue,
        0xFFea3d5f, // R.drawable.card_bk_red,
        0xFFf99595, // R.drawable.card_bk_pink,
        0xFF06b8ad, // R.drawable.card_bk_cyan
    };
    lastFlavIndex++;
    if (lastFlavIndex >= 6)
        lastFlavIndex = 0;
    flavour = flavs[lastFlavIndex];
    /*
    Random r = new Random();
    int index = r.nextInt(3);
    this.flavour = flavs[index];
    */
}

-(BOOL) matchesSearch:(NSString *) text {
    NSString * n = [name uppercaseString];
    NSString * d = [description uppercaseString];
    NSString * t = [text uppercaseString];
    
    if ([n containsString:t] || [d containsString:t])
        return YES;
    return NO;
}

-(NSString *) getMemberCountFormatted {
    if (membercount == nil || [membercount isEqualToString:@""]) {
        if (cache_dj > 0) {
            return @"Máx. 1 músico";
        } else if (cache_band > 0) {
            return @"Máx. 5 músicos";
        } else if (cache_trio > 0) {
            return @"Máx. 3 músicos";
        } else if (cache_duo > 0) {
            return @"Máx. 2 músicos";
        } else if (cache_single > 0) {
            return @"Máx. 1 músico";
        } else {
            return @"Máx. 1 músico";
        }
    }
    NSInteger mc = [membercount integerValue];
    if (mc == 1) {
        return @"Máx. 1 músico";
    }
    return [NSString stringWithFormat:@"Máx. %ld músicos", mc];
}

-(NSString *) getCacheFormatted {
    double min = 0;
    double max = 0;
    // Calculamos el m’nimo
    if (cache_single > 0) {
        min = cache_single;
    } else if (cache_dj > 0) {
        min = cache_dj;
    } else if (cache_duo > 0) {
        min = cache_duo;
    } else if (cache_trio > 0) {
        min = cache_trio;
    } else if (cache_band > 0) {
        min = cache_band;
    }
    // Calculamos el m‡ximo
    if (cache_band > 0) {
        max = cache_band;
    } else if (cache_trio > 0) {
        max = cache_trio;
    } else if (cache_duo > 0) {
        max = cache_duo;
    } else if (cache_dj > 0) {
        max = cache_dj;
    } else if (cache_single > 0) {
        max = cache_single;
    }
    if (min == 0 && max == 0) {
        return @"";
    } else if (min == max) {
        return [NSString stringWithFormat:@"%ld €", (NSInteger)min];
    } else {
        return [NSString stringWithFormat:@"%ld € - %ld €", (NSInteger)min, (NSInteger)max];
    }
}

-(NSArray *) getCacheRange {
    double min = 0;
    double max = 0;
    // Calculamos el m’nimo
    if (cache_single > 0) {
        min = cache_single;
    } else if (cache_duo > 0) {
        min = cache_duo;
    } else if (cache_trio > 0) {
        min = cache_trio;
    } else if (cache_band > 0) {
        min = cache_band;
    } else if (cache_dj > 0) {
        min = cache_dj;
    }
    // Calculamos el m‡ximo
    if (cache_dj > 0) {
        max = cache_dj;
    } else if (cache_band > 0) {
        max = cache_band;
    } else if (cache_trio > 0) {
        max = cache_trio;
    } else if (cache_duo > 0) {
        max = cache_duo;
    } else if (cache_single > 0) {
        max = cache_single;
    }
    if (min == 0 && max == 0) {
        return nil;
    } else {
        NSMutableArray * res = [[NSMutableArray alloc] init];
        [res addObject:[NSNumber numberWithDouble:min]];
        [res addObject:[NSNumber numberWithDouble:max]];
        return res;
    }
}

-(BOOL) cacheInRange:(double) from {
    NSArray * caches = [self getCacheRange];
    if (caches == nil) {
        return NO;
    }
    if ([caches[1] doubleValue] > from) // Si el "final" est‡ por encima, entonces la incluimos.
        return YES;
    else
        return NO;
}

-(NSString *) getTypology {
    NSString * typology = @"concert";
    if (pub_mode != nil) {
        if ([pub_mode isEqualToString:@"PUBLIC"] || [pub_mode isEqualToString:@"PRIVATE"]) {
            typology = @"concert";
        } else if([pub_mode isEqualToString:@"PROMO"]) {
            typology = @"promotion";
        } else if ([pub_mode isEqualToString:@"SOLIDARITY"]) {
            typology = @"solidarity";
        } else {
            // De momento nada. Deber’amos poner tambiŽn las playlists ("editorial")
        }
    }
    return typology; // concert, promotion / solidarity / editorial
}

-(NSString *) getTypologyAsText {
    NSString * typo = [self getTypology];
    if ([typo isEqualToString:@"concert"]) {
        return @"Concierto";
    } else if ([typo isEqualToString:@"promotion"]) {
        return @"Promoción";
    } else if ([typo isEqualToString:@"solidarity"]) {
        return @"C. solidario";
    } else if ([typo isEqualToString:@"editorial"]) {
        return @"Editorial";
    }
    return @"Concierto";
}

-(BOOL) checkFilter:(PerformanceFilters *)filters {

    if (filters.publish_date_from > self.publish_date) {
        return NO;
    }
    if (filters.performance_date_from > self.performance_date) {
        return NO;
    }
    if (filters.typology != nil && ![filters.typology isEqualToString:@""] && ![filters.typology isEqualToString:[self getTypology]]) {
        return NO;
    }
    if (filters.location_zone != nil && ![filters.location_zone isEqualToString:@""] && ![filters.location_zone isEqualToString:self.location_zone]) {
        return NO;
    }
    if (filters.cacheFrom != nil && ![filters.cacheFrom isEqualToString:@""] && ![self cacheInRange:[filters.cacheFrom integerValue]]) {
        return NO;
    }
    /*
    if (filters.memberpreference != nil && ![filters.memberpreference isEqualToString:@""] && ![self.memberpreference containsString:filters.memberpreference]) {
        return NO;
    }*/
    if (filters.exclusive_acqustic && !self.exclusive_acqustic) {
        return NO;
    }
    if (filters.only_pro && [self isFreemium]) {
        return NO;
    }

    return YES;
}


@end

