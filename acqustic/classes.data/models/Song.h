//
//  Song.h
//  Acqustic
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Song : NSObject {
    NSInteger _id;
    NSInteger group_id;
    NSString * title;
    NSString * authors;
    NSString * type;
    NSString * feat_artists;
    NSString * irsc;
    NSString * lang;
    BOOL explicit_content;
    NSString * audiofile;
}

@property NSInteger _id;
@property NSInteger group_id;
@property NSString * title;
@property NSString * authors;
@property NSString * type;
@property NSString * feat_artists;
@property NSString * irsc;
@property NSString * lang;
@property BOOL explicit_content;
@property NSString * audiofile;

-(id) init;
-(id) initWithJSONString:(NSString *)json;
-(id) initWithDictionary:(NSDictionary *)data;
-(NSMutableDictionary *) fillInPostParams:(NSMutableDictionary *)dict;

@end
