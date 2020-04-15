//
//  Album.h
//  Acqustic
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Album : NSObject {
    NSInteger _id;
    NSString * title;
    NSString * status;
    NSInteger original_publish_date;
    NSInteger publish_date;
    NSString * primary_style;
    NSString * secondary_style;
    NSString * upc_code;
    NSString * rejection_explanation;
    NSString * cover;
    NSInteger song_count;
    NSMutableArray* songs; /* Song */
}

@property NSInteger _id;
@property NSString * title;
@property NSString * status;
@property NSInteger original_publish_date;
@property NSInteger publish_date;
@property NSString * primary_style;
@property NSString * secondary_style;
@property NSString * upc_code;
@property NSString * rejection_explanation;
@property NSString * cover;
@property NSInteger song_count;
@property NSMutableArray* songs; /* Song */


-(id) init;
-(id) initWithJSONString:(NSString *)json;
-(id) initWithDictionary:(NSDictionary *)data;
-(NSMutableDictionary *) fillInPostParams:(NSMutableDictionary *)dict;

@end
