//
//  Performer.m
//  Acqustic
//
//  Created by Javier Garcés González on 21/06/12.
//  Copyright (c) 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Performer.h"
#import "Group.h"

@implementation Performer

@synthesize _id, user_id, name, surname, surname2, telephone, email, city, province;
@synthesize ia_nif, ia_name, ia_surname, ia_surname2, ia_address, ia_city, ia_province, ia_country, ia_postcode, ia_birthDate, ia_ssnumber, ia_IBAN, ia_IRPF, ia_nif_front_image, ia_nif_back_image, ready_for_performances;
@synthesize permissions; // <String, Boolean>
@synthesize groups; // Group

// Sólo para uso en la app
@synthesize selected;


-(id) init {
    if (self = [super init]) {
        permissions = [[NSMutableDictionary alloc] init];
        groups = [[NSMutableArray alloc] init];
        name = @"";
        surname = @"";
        surname2 = @"";
        telephone = @"";
        email = @"";
        city = @"";
        province = @"";
        ia_nif = @"";
        ia_name = @"";
        ia_surname = @"";
        ia_surname2 = @"";
        ia_address = @"";
        ia_city = @"";
        ia_province = @"";
        ia_country = @"";
        ia_postcode = @"";
        ia_birthDate = 0;
        ia_ssnumber = @"";
        ia_IBAN = @"";
        ia_IRPF = 0;
        ia_nif_front_image = @"";
        ia_nif_back_image = @"";
        ready_for_performances = NO;
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

-(id) initWithDictionaryFromGroup:(NSDictionary *)data {
    
    // Inicialización por defecto
    self = [self init];
    if (self == nil)
        return nil;
    if (data != nil) {
        [self loadFromDictFromGroup:data];
    }
    return self;
}

-(void) loadFromDict:(NSDictionary *)data {
    NSDictionary * pData = data[@"performer"];

    if (pData[@"id"] && pData[@"id"] != NSNull.null)
        self._id = (NSInteger)[pData[@"id"] integerValue];
    
    if (data[@"id"] && data[@"id"] != NSNull.null)
        user_id = (NSInteger)[data[@"id"] integerValue];
    if (data[@"name"] && data[@"name"] != NSNull.null)
        name = data[@"name"];
    if (data[@"surname"] && data[@"surname"] != NSNull.null)
        surname = data[@"surname"];
    if (data[@"email"] && data[@"email"] != NSNull.null)
        email = data[@"email"];
    if (data[@"telephone"] && data[@"telephone"] != NSNull.null)
        telephone = data[@"telephone"];
    if (data[@"city"] && data[@"city"] != NSNull.null)
        city = data[@"city"];
    if (data[@"province"] && data[@"province"] != NSNull.null)
        province = data[@"province"];

    // Información de facturación
    if (pData[@"ia_nif"] && pData[@"ia_nif"] != NSNull.null)
        ia_nif = pData[@"ia_nif"];
    if (pData[@"ia_name"] && pData[@"ia_name"] != NSNull.null)
        ia_name = pData[@"ia_name"];
    if (pData[@"ia_surname"] && pData[@"ia_surname"] != NSNull.null)
        ia_surname = pData[@"ia_surname"];
    if (pData[@"ia_surname2"] && pData[@"ia_surname2"] != NSNull.null)
        ia_surname2 = pData[@"ia_surname2"];
    if (pData[@"ia_address"] && pData[@"ia_address"] != NSNull.null)
        ia_address = pData[@"ia_address"];
    if (pData[@"ia_city"] && pData[@"ia_city"] != NSNull.null)
        ia_city = pData[@"ia_city"];
    if (pData[@"ia_province"] && pData[@"ia_province"] != NSNull.null)
        ia_province = pData[@"ia_province"];
    if (pData[@"ia_country"] && pData[@"ia_country"] != NSNull.null)
        ia_country = pData[@"ia_country"];
    if (pData[@"ia_postcode"] && pData[@"ia_postcode"] != NSNull.null)
        ia_postcode = pData[@"ia_postcode"];
    if (pData[@"ia_birthDate"] && pData[@"ia_birthDate"] != NSNull.null)
        ia_birthDate = (NSInteger)[pData[@"ia_birthDate"] integerValue];
    if (pData[@"ia_ssnumber"] && pData[@"ia_ssnumber"] != NSNull.null)
        ia_ssnumber = pData[@"ia_ssnumber"];
    if (pData[@"ia_IBAN"] && pData[@"ia_IBAN"] != NSNull.null)
        ia_IBAN = pData[@"ia_IBAN"];
    if (pData[@"ia_IRPF"] && pData[@"ia_IRPF"] != NSNull.null)
        ia_IRPF = (NSInteger)[pData[@"ia_IRPF"] integerValue];
    if (pData[@"ia_nif_front_image"] && pData[@"ia_nif_front_image"] != NSNull.null)
        ia_nif_front_image = pData[@"ia_nif_front_image"];
    if (pData[@"ia_nif_back_image"] && pData[@"ia_nif_back_image"] != NSNull.null)
        ia_nif_back_image = pData[@"ia_nif_back_image"];
    if (pData[@"ia_nif_back_image"] && pData[@"ia_nif_back_image"] != NSNull.null)
        ia_nif_back_image = pData[@"ia_nif_back_image"];
    if (pData[@"ready_for_performances"] && pData[@"ready_for_performances"] != NSNull.null)
        ready_for_performances = (NSInteger)[pData[@"ready_for_performances"] integerValue];

    [self setupPermissions:pData[@"permissions"]];
    
    // Ahora los grupos
    NSArray * gs = pData[@"groups"];
    for (int i=0;i<gs.count;i++) {
        NSDictionary * gr = gs[i];
        Group * group = [[Group alloc] initWithDictionary:gr];
        [groups addObject:group];
    }
    
}

-(void) loadFromDictFromGroup:(NSDictionary *)data {
    if (data[@"id"] && data[@"id"] != NSNull.null)
        self._id = (NSInteger)[data[@"id"] integerValue];
    
    if (data[@"user_id"] && data[@"user_id"] != NSNull.null)
        user_id = (NSInteger)[data[@"user_id"] integerValue];
    if (data[@"name"] && data[@"name"] != NSNull.null)
        name = data[@"name"];
    if (data[@"surname"] && data[@"surname"] != NSNull.null)
        surname = data[@"surname"];
    if (data[@"email"] && data[@"email"] != NSNull.null)
        email = data[@"email"];
    if (data[@"ready_for_performances"] && data[@"ready_for_performances"] != NSNull.null)
        ready_for_performances = (NSInteger)[data[@"ready_for_performances"] integerValue];

    [self setupPermissions:data[@"permissions"]];
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
    dict[@"surname"] = surname;
    dict[@"email"] = email;
    dict[@"telephone"] = telephone;
    dict[@"city"] = city;
    dict[@"province"] = province;
    dict[@"ia_nif"] = ia_nif;
    dict[@"ia_name"] = ia_name;
    dict[@"ia_surname"] = ia_surname;
    dict[@"ia_address"] = ia_address;
    dict[@"ia_city"] = ia_city;
    dict[@"ia_province"] = ia_province;
    dict[@"ia_country"] = ia_country;
    dict[@"ia_postcode"] = ia_postcode;
    dict[@"ia_birthDate"] = [NSNumber numberWithInteger:self.ia_birthDate];;
    dict[@"ia_ssnumber"] = ia_ssnumber;
    dict[@"ia_IBAN"] = ia_IBAN;
    dict[@"ia_IRPF"] = [NSNumber numberWithInteger:self.ia_IRPF];;
    dict[@"ia_nif_front_image"] = ia_nif_front_image;
    dict[@"ia_nif_back_image"] = ia_nif_back_image;
    
    return dict;
}

-(BOOL)hasValueString:(NSString *)s {
    if (s == nil)
        return NO;
    if ([[s stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] isEqualToString:@""])
        return NO;
    return YES;
}
-(BOOL) hasValueInteger:(NSInteger) l {
    if (l == 0)
        return NO;
    return YES;
}

-(BOOL) isReadyForPerformances {
    return ready_for_performances;
    /*
    if ([self hasValueString:telephone] && [self hasValueString:ia_nif] && [self hasValueString:ia_name] && [self hasValueString:ia_surname] && [self hasValueString:ia_address] && [self hasValueString:ia_city] && [self hasValueString:ia_postcode] &&
        [self hasValueInteger:ia_birthDate] && [self hasValueString:ia_ssnumber] && [self hasValueString:ia_IBAN] && [self hasValueInteger:ia_IRPF] && [self hasValueString:ia_nif_front_image] && [self hasValueString:ia_nif_back_image]) {
        return YES;
    } else {
        return NO;
    }
     */
}

-(BOOL) isReadyForRegister {
    return [self isReadyForRegister:NO];
}

-(BOOL) isReadyForRegister:(BOOL)checkGroups {
    // Para ser freemium ha de tener, obligatoriamente:
    // name, surname, email, telephone, province,
    if (name == nil || [name isEqualToString:@""])
        return NO;
    if (surname == nil || [surname isEqualToString:@""])
        return NO;
    if (email == nil || [email isEqualToString:@""])
        return NO;
    if (telephone == nil || [telephone isEqualToString:@""])
        return NO;
    if (province == nil || [province isEqualToString:@""])
        return NO;
    if (checkGroups) {
        for (int i=0;i<groups.count;i++) {
            Group * g = groups[i];
            if ([g isReadyForRegister]) {
                return YES;
            }
        }
        return NO;
    }
    
    return YES;
}


@end

