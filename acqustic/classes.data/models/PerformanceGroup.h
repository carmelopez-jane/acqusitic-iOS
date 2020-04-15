//
//  PerformanceGroup.h
//  Acqustic
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface PerformanceGroup : NSObject {
    NSInteger group_id;
    NSString * group_name;
    NSString * status;
    NSString * group_members_data;
    NSInteger created_at;
    NSInteger updated_at;

    NSString * performance_type;
    NSInteger performance_id;
    NSString * performance_name;
    NSString * performance_status;
    NSInteger performance_date;
    NSString * performance_pub_mode;
}

@property NSInteger group_id;
@property NSString * group_name;
@property NSString * status;
@property NSString * group_members_data;
@property NSInteger created_at;
@property NSInteger updated_at;

@property NSInteger performance_id;
@property NSString * performance_name;
@property NSString * performance_status;
@property NSString * performance_type;
@property NSString * performance_pub_mode;
@property NSInteger performance_date;

-(id) init;
-(id) initWithJSONString:(NSString *)json;
-(id) initWithDictionary:(NSDictionary *)data;
-(NSString *) getTypology;

@end
