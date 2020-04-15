//
//  Invoicereq.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Invoicereq.h"
#import "Distribution.h"
#import "Performer.h"
#import "WSDataManager.h"

@implementation Invoicereq

@synthesize _id, status, description, group_id, contact_name, contact_email, performance_city, performance_date, name, nif, address, postcode, city, country, netamount, invoice_id, invoice_date;

@synthesize  distValues; // Distribution

@synthesize memberId0, percent0, documents0;
@synthesize memberId1, percent1, documents1;
@synthesize memberId2, percent2, documents2;
@synthesize memberId3, percent3, documents3;
@synthesize memberId4, percent4, documents4;
@synthesize memberId5, percent5, documents5;
@synthesize memberId6, percent6, documents6;
@synthesize memberId7, percent7, documents7;
@synthesize memberId8, percent8, documents8;
@synthesize memberId9, percent9, documents9;


-(id) init {
    if (self = [super init]) {
        self.status = @"NEW";
        self.country = @"es";
        self.distValues = [[NSMutableArray alloc] init];
        self.description = @"";
        contact_name = @"";
        contact_email = @"";
        performance_city = @"";
        performance_date = 0;
        name = @"";
        nif = @"";
        address = @"";
        postcode = @"";
        city = @"";
        netamount = 0;
        invoice_id = 0;
        invoice_date = 0;
        documents0 = @"";
        documents1 = @"";
        documents2 = @"";
        documents3 = @"";
        documents4 = @"";
        documents5 = @"";
        documents6 = @"";
        documents7 = @"";
        documents8 = @"";
        documents9 = @"";
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
    if (data[@"status"] && data[@"status"] != NSNull.null)
        status = data[@"status"];
    if (data[@"contact_name"] && data[@"contact_name"] != NSNull.null)
        contact_name = data[@"contact_name"];
    if (data[@"contact_email"] && data[@"contact_email"] != NSNull.null)
        contact_email = data[@"contact_email"];
    if (data[@"performance_city"] && data[@"performance_city"] != NSNull.null)
        performance_city = data[@"performance_city"];
    if (data[@"description"] && data[@"description"] != NSNull.null)
        description = data[@"description"];
    if (data[@"performance_date"] && data[@"performance_date"] != NSNull.null)
        performance_date = (NSInteger)[data[@"performance_date"] integerValue];
    if (data[@"name"] && data[@"name"] != NSNull.null)
        name = data[@"name"];
    if (data[@"nif"] && data[@"nif"] != NSNull.null)
        nif = data[@"nif"];
    if (data[@"address"] && data[@"address"] != NSNull.null)
        address = data[@"address"];
    if (data[@"postcode"] && data[@"postcode"] != NSNull.null)
        postcode = data[@"postcode"];
    if (data[@"city"] && data[@"city"] != NSNull.null)
        city = data[@"city"];
    if (data[@"country"] && data[@"country"] != NSNull.null)
        country = data[@"country"];
    if (country == nil || [country isEqualToString:@""])
        country = @"es";
    if (data[@"netamount"] && data[@"netamount"] != NSNull.null)
        netamount = (double)[data[@"netamount"] doubleValue];
    if (data[@"invoice_id"] && data[@"invoice_id"] != NSNull.null)
        invoice_id = (NSInteger)[data[@"invoice_id"] integerValue];
    if (data[@"invoice_date"] && data[@"invoice_date"] != NSNull.null)
        invoice_date = (NSInteger)[data[@"invoice_date"] integerValue];
    
    // Ahora tenemos que proceder con la distribución...
    NSArray * dist = data[@"distribution"];
    if (dist) {
        for(int i=0;i<dist.count;i++) {
            NSDictionary * item = dist[i];
            Distribution * di = [[Distribution alloc] initWithDictionary:item];
            [distValues addObject:di];
        }
    }
}

-(void) fillInDistributionForForm:(NSArray *) performers {
    for (int i=0;i<performers.count;i++) {
        NSInteger perfId = ((Performer *)performers[i])._id;
        // Miramos de localizar el miembro
        Distribution * dist = nil;
        for (int j=0;j<distValues.count;j++) {
            if (perfId == ((Distribution *)distValues[j]).group_member) {
                dist = distValues[j];
                break;
            }
        }
        if (dist) {
            [self setValue:[NSNumber numberWithInteger:dist.group_member] forKey:[NSString stringWithFormat:@"memberId%d", i]];
            [self setValue:[NSNumber numberWithInteger:dist.group_member_percentage] forKey:[NSString stringWithFormat:@"percent%d", i]];
            [self setValue:dist.group_member_documents forKey:[NSString stringWithFormat:@"documents%d", i]];
        } else {
            [self setValue:[NSNumber numberWithInteger:perfId] forKey:[NSString stringWithFormat:@"memberId%d", i]];
            [self setValue:[NSNumber numberWithInteger:0] forKey:[NSString stringWithFormat:@"percent%d", i]];
            [self setValue:@"" forKey:[NSString stringWithFormat:@"documents%d", i]];
        }
    }
}

-(NSString *) getDistributionItem:(NSInteger) memberId percent:(NSInteger) percent documents:(NSString *) documents {
    NSMutableDictionary * res = [[NSMutableDictionary alloc] init];
    res[@"group_member"] = [NSNumber numberWithInteger:memberId];
    res[@"group_member_percentage"] = [NSNumber numberWithInteger:percent];
    NSMutableArray * docs = [[NSMutableArray alloc] init];
    if (documents && ![documents isEqualToString:@""]) {
        NSArray * dds = [documents componentsSeparatedByString:@","];
        for (int i=0;i<dds.count;i++) {
            [docs addObject:dds[i]];
        }
    }
    res[@"group_member_documents"] = docs;
    // Ahora pasamos a string el JSON
    return [WSDataManager stringFromJSON:res];
}

-(NSString *) getDistribution {
    NSString * res = @"";
    if (memberId0 != 0) {
        if (![res isEqualToString:@""])
            res = [res stringByAppendingString:@","];
        res = [res stringByAppendingString:[self getDistributionItem:memberId0 percent:percent0 documents:documents0]];
    }
    if (memberId1 != 0) {
        if (![res isEqualToString:@""])
            res = [res stringByAppendingString:@","];
        res = [res stringByAppendingString:[self getDistributionItem:memberId1 percent:percent1 documents:documents1]];
    }
    if (memberId2 != 0) {
        if (![res isEqualToString:@""])
            res = [res stringByAppendingString:@","];
        res = [res stringByAppendingString:[self getDistributionItem:memberId2 percent:percent2 documents:documents2]];
    }
    if (memberId3 != 0) {
        if (![res isEqualToString:@""])
            res = [res stringByAppendingString:@","];
        res = [res stringByAppendingString:[self getDistributionItem:memberId3 percent:percent3 documents:documents3]];
    }
    if (memberId4 != 0) {
        if (![res isEqualToString:@""])
            res = [res stringByAppendingString:@","];
        res = [res stringByAppendingString:[self getDistributionItem:memberId4 percent:percent4 documents:documents4]];
    }
    if (memberId5 != 0) {
        if (![res isEqualToString:@""])
            res = [res stringByAppendingString:@","];
        res = [res stringByAppendingString:[self getDistributionItem:memberId5 percent:percent5 documents:documents5]];
    }
    if (memberId6 != 0) {
        if (![res isEqualToString:@""])
            res = [res stringByAppendingString:@","];
        res = [res stringByAppendingString:[self getDistributionItem:memberId6 percent:percent6 documents:documents6]];
    }
    if (memberId7 != 0) {
        if (![res isEqualToString:@""])
            res = [res stringByAppendingString:@","];
        res = [res stringByAppendingString:[self getDistributionItem:memberId7 percent:percent7 documents:documents7]];
    }
    if (memberId8 != 0) {
        if (![res isEqualToString:@""])
            res = [res stringByAppendingString:@","];
        res = [res stringByAppendingString:[self getDistributionItem:memberId8 percent:percent8 documents:documents8]];
    }
    if (memberId9 != 0) {
        if (![res isEqualToString:@""])
            res = [res stringByAppendingString:@","];
        res = [res stringByAppendingString:[self getDistributionItem:memberId9 percent:percent9 documents:documents9]];
    }
    if (![res isEqualToString:@""]) {
        NSString * f = @"[";
        f = [f stringByAppendingString:res];
        f = [f stringByAppendingString:@"]"];
        res = f;
    }
    return res;
}

-(NSMutableDictionary *) fillInPostParams:(NSMutableDictionary *)dict {
    if (!dict)
        dict = [[NSMutableDictionary alloc] init];
    dict[@"id"] = [NSNumber numberWithInteger:self._id];
    dict[@"group_id"] = [NSNumber numberWithInteger:self.group_id];
    dict[@"description"] = description;
    dict[@"contact_name"] = contact_name;
    dict[@"contact_email"] = contact_email;
    dict[@"performance_city"] = performance_city;
    dict[@"performance_date"] = [NSNumber numberWithInteger:self.performance_date];
    dict[@"name"] = name;
    dict[@"nif"] = nif;
    dict[@"address"] = address;
    dict[@"postcode"] = postcode;
    dict[@"city"] = city;
    dict[@"country"] = country;
    dict[@"distribution"] = [self getDistribution];
    dict[@"netamount"] = [NSNumber numberWithInteger:self.netamount];

    return dict;
}


@end

