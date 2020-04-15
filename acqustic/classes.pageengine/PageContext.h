//
//  PageContext.h
//  PDL
//
//  Created by Javier Garcés González on 19/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PageContext : NSObject {

	NSMutableDictionary * dict;
    BOOL cachePage;
    
}

@property NSMutableDictionary * dict;
@property BOOL cachePage;


// Inicialización
-(id) init;
-(id) initWithString: (NSString *) string;
-(PageContext *) clone;

// Parámetros
-(void) addParam: (NSString *) name withValue: (NSString *)value;
-(void) addParam: (NSString *) name withIntValue: (NSInteger) value;
-(void) removeParam: (NSString *) name;

-(NSString *)paramByName: (NSString *)name;
-(NSString *)paramByName: (NSString *)name withDefault: (NSString *)defaultValue;
-(NSInteger) intParamByName: (NSString *)name;
-(NSInteger) intParamByName: (NSString *)name withDefault: (NSInteger)defaultValue;

// IsBack (parámetro especial
-(BOOL)isBack;

@end
