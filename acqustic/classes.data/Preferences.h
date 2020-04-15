//
//  Preferences.h
//  SegurParking
//
//  Created by Joan on 19/8/15.
//  Copyright (c) 2015 Bab Software. All rights reserved.
//

#import <Foundation/Foundation.h>

//------------------------------------------------------------
// Almacén de preferencias encriptado y privado.
// No se hace backup del archivo
//------------------------------------------------------------

@interface Preferences : NSObject{
    NSString * _fileName;
    NSMutableDictionary * _preferences;
}

@property NSString * fileName;
@property NSMutableDictionary * preferences;

+(void)init;
+(NSObject *)objectForKey:(NSString *)key;
+(void)setObject:(NSObject *)value forKey:(NSString *)key;
+(int)integerForKey:(NSString *)key;
+(void)setInteger:(int)value forKey:(NSString *)key;
+(void)removeObjectForKey:(NSString *)key;
+(void)synchronize;


@end
