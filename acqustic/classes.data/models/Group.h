//
//  Group.h
//  Acqustic
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Group : NSObject {
    NSInteger _id;
    NSString * name;
    NSString * description;
    NSString * type;
    NSString * location;
    NSString * province;
    NSString * memberpreference;
    NSString * styles;
    NSString * videos;
    NSString * social;
    NSString * images;

    BOOL deleted;
    NSMutableArray * performers; // Performers
    NSMutableArray * repertoire; // Repertoire
    NSMutableArray * songs; // Song
    NSMutableArray * albums; // Album
    NSMutableArray * agenda; // Agendaitem
    NSMutableArray * invoicereqs; // Invoicereq

    NSMutableDictionary * permissions; // <String, Boolean>
}

@property NSInteger _id;
@property NSString * name;
@property NSString * description;
@property NSString * type;
@property NSString * location;
@property NSString * province;
@property NSString * memberpreference;
@property NSString * styles;
@property NSString * videos;
@property NSString * social;
@property NSString * images;

@property BOOL deleted;
@property NSMutableArray * performers; // Performers
@property NSMutableArray * repertoire; // Repertoire
@property NSMutableArray * songs; // Song
@property NSMutableArray * albums; // Album
@property NSMutableArray * agenda; // Agendaitem
@property NSMutableArray * invoicereqs; // Invoicereq

@property NSMutableDictionary * permissions; // <String, Boolean>

-(id) init;
-(id) initWithJSONString:(NSString *)json;
-(id) initWithDictionary:(NSDictionary *)data;
-(NSMutableDictionary *) fillInPostParams:(NSMutableDictionary *)dict;
-(void) setupPermissions:(NSArray *)pms;
-(BOOL) hasPermission:(NSString *)permission;
-(BOOL) isReadyForRegister;

@end
