//
//  Album.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Album.h"
#import "Song.h"

@implementation Album

@synthesize _id, title, status, original_publish_date, publish_date, primary_style, secondary_style, upc_code, rejection_explanation, cover, song_count, songs;


-(id) init {
    if (self = [super init]) {
        status = @"NEW";
        original_publish_date = 0;
        publish_date = 0;
        primary_style = @"";
        secondary_style = @"";
        upc_code = @"";
        rejection_explanation = @"";
        cover = @"";
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
        self.title = data[@"title"];
    if (data[@"status"] && data[@"status"] != NSNull.null)
        self.status = data[@"status"];
    if (data[@"original_publish_date"] && data[@"original_publish_date"] != NSNull.null)
        self.original_publish_date = (NSInteger)[data[@"original_publish_date"] integerValue];
    if (data[@"publish_date"] && data[@"publish_date"] != NSNull.null)
        self.publish_date = (NSInteger)[data[@"publish_date"] integerValue];
    if (data[@"primary_style"] && data[@"primary_style"] != NSNull.null)
        self.primary_style = data[@"primary_style"];
    if (data[@"secondary_style"] && data[@"secondary_style"] != NSNull.null)
        self.secondary_style = data[@"secondary_style"];
    if (data[@"upc_code"] && data[@"upc_code"] != NSNull.null)
        self.upc_code = data[@"upc_code"];
    if (data[@"rejection_explanation"] && data[@"rejection_explanation"] != NSNull.null)
        self.rejection_explanation = data[@"rejection_explanation"];
    else
        self.rejection_explanation = @"";
    if (data[@"cover"] && data[@"cover"] != NSNull.null)
        self.cover = data[@"cover"];
    else
        self.cover = @"";
    if (data[@"song_count"] && data[@"song_count"] != NSNull.null)
        self.song_count = (NSInteger)[data[@"song_count"] integerValue];

    NSArray * songsData = (NSArray *)data[@"songs"];
    if (songsData) {
        for (int i=0;i<songsData.count;i++) {
            Song * song = [[Song alloc] initWithDictionary:songsData[i]];
            [self.songs addObject:song];
        }
        self.song_count = songsData.count;
    }
}

-(NSMutableDictionary *) fillInPostParams:(NSMutableDictionary *)dict {
    if (!dict)
        dict = [[NSMutableDictionary alloc] init];
    dict[@"id"] = [NSNumber numberWithInteger:self._id];
    dict[@"title"] = title;
    dict[@"original_publish_date"] = [NSNumber numberWithInteger:self.original_publish_date];
    dict[@"publish_date"] = [NSNumber numberWithInteger:self.publish_date];
    dict[@"primary_style"] = primary_style;
    dict[@"secondary_style"] = secondary_style;
    dict[@"upc_code"] = upc_code;
    dict[@"cover"] = cover;
    
    return dict;
}

@end

