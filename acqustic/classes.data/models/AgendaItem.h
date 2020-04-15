//
//  Agendaitem.h
//  Acqustic
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Agendaitem : NSObject {
    NSInteger _id;
    NSInteger group_id;
    NSString * description;
    NSInteger performance_date;
    NSString * type;
    NSString * venue;
    NSString * address;
    NSString * postcode;
    NSString * city;
    NSString * province;
    NSString * country;
}

@property NSInteger _id;
@property NSInteger group_id;
@property NSString * description;
@property NSInteger performance_date;
@property NSString * type;
@property NSString * venue;
@property NSString * address;
@property NSString * postcode;
@property NSString * city;
@property NSString * province;
@property NSString * country;

-(id) init;
-(id) initWithJSONString:(NSString *)json;
-(id) initWithDictionary:(NSDictionary *)data;
-(NSMutableDictionary *) fillInPostParams:(NSMutableDictionary *)dict;
@end
