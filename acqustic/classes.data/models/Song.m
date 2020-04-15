//
//  Song.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Song.h"

@implementation Song

@synthesize _id, group_id, title, authors, type, feat_artists, irsc, lang, explicit_content, audiofile;

-(id) init {
    if (self = [super init]) {
        title = @"";
        authors = @"";
        type = @"";
        feat_artists = @"";
        irsc = @"";
        lang = @"";
        explicit_content = NO;
        audiofile = @"";
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
        group_id = (NSInteger)[data[@"_id"] integerValue];
    if (data[@"title"] && data[@"title"] != NSNull.null)
        title = data[@"title"];
    if (data[@"authors"] && data[@"authors"] != NSNull.null)
        authors = data[@"authors"];
    if (data[@"type"] && data[@"type"] != NSNull.null)
        type = data[@"type"];
    if (data[@"feat_artists"] && data[@"feat_artists"] != NSNull.null)
        feat_artists = data[@"feat_artists"];
    if (data[@"irsc"] && data[@"irsc"] != NSNull.null)
        irsc = data[@"irsc"];
    if (data[@"lang"] && data[@"lang"] != NSNull.null)
        lang = data[@"lang"];
    if (data[@"explicit_content"] && data[@"explicit_content"] != NSNull.null)
        explicit_content = (NSInteger)[data[@"explicit_content"] integerValue];
    if (data[@"audiofile"] && data[@"audiofile"] != NSNull.null)
        audiofile = data[@"audiofile"];

}

-(NSMutableDictionary *) fillInPostParams:(NSMutableDictionary *)dict {
    if (!dict)
        dict = [[NSMutableDictionary alloc] init];
    dict[@"id"] = [NSNumber numberWithInteger:self._id];

    dict[@"group_id"] = [NSNumber numberWithInteger:self._id];
    dict[@"title"] = title;
    dict[@"authors"] = authors;
    dict[@"type"] = type;
    dict[@"feat_artists"] = feat_artists;
    dict[@"irsc"] = irsc;
    dict[@"lang"] = lang;
    dict[@"explicit_content"] = [NSNumber numberWithInteger:self.explicit_content];
    dict[@"audiofile"] = audiofile;
    
    return dict;
}

@end

