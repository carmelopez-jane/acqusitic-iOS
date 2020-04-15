//
//  Repertoire.h
//  Acqustic
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Repertoire : NSObject {
    NSInteger _id;
    NSString * title;
    NSInteger song_count;
    NSMutableArray * songs;
}

@property NSInteger _id;
@property NSString * title;
@property NSInteger song_count;
@property NSMutableArray * songs;

-(id) init;
-(id) initWithJSONString:(NSString *)json;
-(id) initWithDictionary:(NSDictionary *)data;
-(NSMutableDictionary *) fillInPostParams:(NSMutableDictionary *)dict;

@end
