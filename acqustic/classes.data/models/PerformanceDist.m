//
//  PerformanceDist.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "PerformanceDist.h"
#import "Performer.h"
#import "Distribution.h"
#import "WSDataManager.h"

@implementation PerformanceDist

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
        distValues = [[NSMutableArray alloc] init];
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


-(void) fillInDistributionForForm:(NSArray *) performers {
    performersCount = (int)performers.count;
    int userPercent = 100 / performers.count;
    int lastUserPercent = 100 - userPercent*(performers.count-1);
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
            [self setValue:[NSNumber numberWithInteger:(i<performersCount-1)?userPercent:lastUserPercent] forKey:[NSString stringWithFormat:@"percent%d", i]];
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

-(BOOL) checkDistribution {
    int total = 0;
    if (memberId0 != 0) {
        total += percent0;
    }
    if (memberId1 != 0) {
        total += percent1;
    }
    if (memberId2 != 0) {
        total += percent2;
    }
    if (memberId3 != 0) {
        total += percent3;
    }
    if (memberId4 != 0) {
        total += percent4;
    }
    if (memberId5 != 0) {
        total += percent5;
    }
    if (memberId6 != 0) {
        total += percent6;
    }
    if (memberId7 != 0) {
        total += percent7;
    }
    if (memberId8 != 0) {
        total += percent8;
    }
    if (memberId9 != 0) {
        total += percent9;
    }
    return (total == 100);
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



@end

