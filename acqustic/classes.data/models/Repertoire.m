//
//  Repertoire.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Repertoire.h"
#import "Song.h"

@implementation Repertoire

@synthesize _id, title, songs, song_count;

-(id) init {
    if (self = [super init]) {
        title = @"";
        song_count = 0;
        songs = [[NSMutableArray alloc] init];
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
    if (data[@"title"] && data[@"title"] != NSNull.null)
        title = data[@"title"];
    if (data[@"song_count"] && data[@"song_count"] != NSNull.null)
        song_count = (NSInteger)[data[@"song_count"] integerValue];
    
    NSMutableArray * ss = data[@"songs"];
    if (ss != nil) {
        song_count = ss.count;
        for (int i=0;i<ss.count;i++) {
            Song * s = [[Song alloc] initWithDictionary:ss[i]];
            [songs addObject:s];
        }
    }
}

-(NSMutableDictionary *) fillInPostParams:(NSMutableDictionary *)dict {
    if (!dict)
        dict = [[NSMutableDictionary alloc] init];
    dict[@"id"] = [NSNumber numberWithInteger:self._id];
    dict[@"title"] = self.title;

    return dict;
}

@end

