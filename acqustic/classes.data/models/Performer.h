//
//  Performer.h
//  Acqustic
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Performer : NSObject {
    NSInteger _id;
    // Información básica del usuario
    NSInteger user_id;
    NSString * name;
    NSString * surname;
    NSString * surname2;
    NSString * telephone;
    NSString * email;
    NSString * city;
    // Información de facturación
    NSString * ia_nif;
    NSString * ia_name;
    NSString * ia_surname;
    NSString * ia_surname2;
    NSString * ia_address;
    NSString * ia_city;
    NSString * ia_province;
    NSString * ia_country;
    NSString * ia_postcode;
    NSInteger ia_birthDate;
    NSString * ia_ssnumber;
    NSString * ia_IBAN;
    NSInteger ia_IRPF;
    NSInteger ready_for_performances;

    NSString * ia_nif_front_image;
    NSString * ia_nif_back_image;

    NSMutableDictionary * permissions; // <String, Boolean>

    NSMutableArray * groups; // Group

    // Sólo para uso en la app
    BOOL selected;
}

@property NSInteger _id;
@property NSInteger user_id;
@property NSString * name;
@property NSString * surname;
@property NSString * surname2;
@property NSString * telephone;
@property NSString * email;
@property NSString * city;
@property NSString * province;
// Información de facturación
@property NSString * ia_nif;
@property NSString * ia_name;
@property NSString * ia_surname;
@property NSString * ia_surname2;
@property NSString * ia_address;
@property NSString * ia_city;
@property NSString * ia_province;
@property NSString * ia_country;
@property NSString * ia_postcode;
@property NSInteger ia_birthDate;
@property NSString * ia_ssnumber;
@property NSString * ia_IBAN;
@property NSInteger ia_IRPF;
@property NSInteger ready_for_performances;

@property NSString * ia_nif_front_image;
@property NSString * ia_nif_back_image;

@property NSMutableDictionary * permissions; // <String, Boolean>

@property NSMutableArray * groups; // Group


// Sólo para uso en la app
@property BOOL selected;

-(id) init;
-(id) initWithJSONString:(NSString *)json;
-(id) initWithDictionary:(NSDictionary *)data;
-(id) initWithDictionaryFromGroup:(NSDictionary *)data;
-(NSMutableDictionary *) fillInPostParams:(NSMutableDictionary *)dict;
-(BOOL) hasPermission:(NSString *)permission;
-(BOOL) isReadyForPerformances;
-(BOOL) isReadyForRegister;
-(BOOL) isReadyForRegister:(BOOL)checkGroups;

@end
