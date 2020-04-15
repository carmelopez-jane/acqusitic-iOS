//
//  Distribution.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Distribution.h"

@implementation Distribution

@synthesize group_member, group_member_percentage, group_member_documents;


-(id) init {
    if (self = [super init]) {
        group_member = 0;
        group_member_percentage = 0;
        group_member_documents = @"";
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
    if (data[@"group_member"] && data[@"group_member"] != NSNull.null)
        self.group_member = (NSInteger)[data[@"group_member"] integerValue];
    if (data[@"group_member_percentage"] && data[@"group_member_percentage"] != NSNull.null)
        self.group_member_percentage = (NSInteger)[data[@"group_member_percentage"] integerValue];
    if (data[@"group_member_documents"] && data[@"group_member_documents"] != NSNull.null) {
        NSArray * gp = data[@"group_member_documents"];
        NSString * val = @"";
        for (int i=0;i<gp.count;i++) {
            if (i > 0)
                val = [val stringByAppendingString:@","];
            val = [val stringByAppendingString:gp[i]];
        }
        self.group_member_documents = val;
    }
}


@end

