//
//  Group.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Group.h"
#import "Performer.h"
#import "Repertoire.h"
#import "Song.h"
#import "Album.h"
#import "AgendaItem.h"
#import "Invoicereq.h"
#import "Permission.h"

@implementation Group

@synthesize _id, name, description, type, location, province, memberpreference, styles, videos, social, images, deleted;
@synthesize performers, repertoire, songs, albums, agenda, invoicereqs, permissions;


-(id) init {
    if (self = [super init]) {
        name = @"";
        description = @"";
        type = @"";
        location = @"";
        province = @"";
        memberpreference = @"";
        styles = @"";
        videos = @"";
        social = @"";
        images = @"";
        deleted = NO;
        performers = [[NSMutableArray alloc] init];
        repertoire = [[NSMutableArray alloc] init]; // Repertoire
        songs = [[NSMutableArray alloc] init]; // Song
        albums = [[NSMutableArray alloc] init]; // Album
        agenda = [[NSMutableArray alloc] init]; // Agendaitem
        invoicereqs = [[NSMutableArray alloc] init]; // Invoicereq
        permissions = [[NSMutableDictionary alloc] init];

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
    if (data[@"name"] && data[@"name"] != NSNull.null)
        self.name = data[@"name"];
    if (data[@"type"] && data[@"type"] != NSNull.null)
        self.type = data[@"type"];
    if (data[@"location"] && data[@"location"] != NSNull.null)
        self.location = data[@"location"];
    if (data[@"province"] && data[@"province"] != NSNull.null)
        self.province = data[@"province"];
    if (data[@"memberpreference"] && data[@"memberpreference"] != NSNull.null)
        self.memberpreference = data[@"memberpreference"];
    if (data[@"description"] && data[@"description"] != NSNull.null)
        self.description = data[@"description"];
    if (data[@"deleted"] && data[@"deleted"] != NSNull.null)
        self.deleted = (NSInteger)[data[@"deleted"] integerValue];
    if (data[@"styles"] && data[@"styles"] != NSNull.null)
        self.styles = data[@"styles"];
    if (data[@"images"] && data[@"images"] != NSNull.null)
        self.images = data[@"images"];
    if (data[@"videos"] && data[@"videos"] != NSNull.null)
        self.videos = data[@"videos"];
    if (data[@"social"] && data[@"social"] != NSNull.null)
        self.social = data[@"social"];
    
    [self setupPermissions:data[@"permissions"]];
    
    if (data[@"performers"]) {
        NSArray * pData = data[@"performers"];
        for (int i=0;i<pData.count;i++) {
            NSDictionary * pd = pData[i];
            Performer * p = [[Performer alloc] initWithDictionaryFromGroup:pd];
            [performers addObject:p];
        }
    }
    if (data[@"agenda"]) {
        NSArray * pData = data[@"agenda"];
        for (int i=0;i<pData.count;i++) {
            NSDictionary * pd = pData[i];
            Agendaitem * ai = [[Agendaitem alloc] initWithDictionary:pd];
            [agenda addObject:ai];
        }
    }
    if (data[@"songs"]) {
        NSArray * pData = data[@"songs"];
        for (int i=0;i<pData.count;i++) {
            NSDictionary * pd = pData[i];
            Song * s = [[Song alloc] initWithDictionary:pd];
            [songs addObject:s];
        }
    }
    if (data[@"repertoires"]) {
        NSArray * pData = data[@"repertoires"];
        for (int i=0;i<pData.count;i++) {
            NSDictionary * pd = pData[i];
            Repertoire * s = [[Repertoire alloc] initWithDictionary:pd];
            [repertoire addObject:s];
        }
    }
    if (data[@"albums"]) {
        NSArray * pData = data[@"albums"];
        for (int i=0;i<pData.count;i++) {
            NSDictionary * pd = pData[i];
            Album * s = [[Album alloc] initWithDictionary:pd];
            [albums addObject:s];
        }
    }
    if (data[@"invoicereqs"]) {
        NSArray * pData = data[@"invoicereqs"];
        for (int i=0;i<pData.count;i++) {
            NSDictionary * pd = pData[i];
            Invoicereq * iv = [[Invoicereq alloc] initWithDictionary:pd];
            [invoicereqs addObject:iv];
        }
    }

}

-(void) setupPermissions:(NSArray *)pms {
    [permissions removeAllObjects];
    if (pms == nil)
        return;
    for (int i=0;i<pms.count;i++) {
        [permissions setObject:[NSNumber numberWithBool:YES] forKey:pms[i]];
    }
}

-(BOOL) hasPermission:(NSString *)permission {
    if (permissions[permission]) {
        return YES;
    } else {
        return NO;
    }
}

-(NSMutableDictionary *) fillInPostParams:(NSMutableDictionary *)dict {
    if (!dict)
        dict = [[NSMutableDictionary alloc] init];
    dict[@"id"] = [NSNumber numberWithInteger:self._id];

    dict[@"name"] = name;
    dict[@"type"] = type;
    dict[@"location"] = location;
    dict[@"province"] = province;
    dict[@"memberpreference"] = memberpreference;
    dict[@"description"] = description;
    dict[@"styles"] = styles;
    dict[@"images"] = images;
    dict[@"videos"] = videos;
    dict[@"social"] = social;
    dict[@"deleted"] = [NSNumber numberWithInteger:self.deleted];
    NSString * ps = @"";
    for (int i=0;i<performers.count;i++) {
        if (i > 0)
            ps = [ps stringByAppendingString:@","];
        ps = [ps stringByAppendingFormat:@"%ld", ((Performer *)performers[i])._id];
    }
    dict[@"performers"] = ps;

    return dict;
}

-(BOOL) isReadyForRegister {
    // Debe tener los siguientes campos: nombre, tipo, memberpreference, ubicacion, provincia, estilos, videos
    if (name == nil || [name isEqualToString:@""])
        return NO;
    if (type == nil || [type isEqualToString:@""])
        return NO;
    if (memberpreference == nil || [memberpreference isEqualToString:@""])
        return NO;
    if (location == nil || [location isEqualToString:@""])
        return NO;
    if (province == nil || [province isEqualToString:@""])
        return NO;
    if (styles == nil || [styles isEqualToString:@""])
        return NO;
    if (videos == nil || [videos isEqualToString:@""])
        return NO;
    return YES;
}


@end

