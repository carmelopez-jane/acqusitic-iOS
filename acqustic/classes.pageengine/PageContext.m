//
//  PageContext.m
//  PDL
//
//  Created by Javier Garcés González on 19/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "PageContext.h"


@implementation PageContext

@synthesize dict;
@synthesize cachePage;


// Inicialización
-(id) init
{
    if (self = [super init]) {
        dict = [[NSMutableDictionary alloc] init];
        return self;
    } else {
        return nil;
    }
}

-(id) initWithString: (NSString *) string
{
    if (self = [super init]) {
        dict = [[NSMutableDictionary alloc] init];

        if (string != nil && [string isEqualToString:@""] == NO) {
            NSArray * parts = [string componentsSeparatedByString:@"##"];
            for (int i=0;i<[parts count];i++) {
                NSArray * eq = [parts[i] componentsSeparatedByString:@"="];
                if ([eq count] == 1) // Si sólo hay un valor, lo ponemos a "1"
                    dict[eq[0]] = @"1";
                else
                    dict[eq[0]] = eq[1];
            }
        }
    } else {
        return nil;
    }
	
	return self;
}

-(PageContext *) clone
{
    PageContext * res = [[PageContext alloc] init];
    // Hacemos la copia de los parámetros
    for (NSString * key in dict) {
        res.dict[key] = dict[key];
    }
    return res;
}

// Parámetros
-(void) addParam: (NSString *) name withValue: (NSString *)value
{
    dict[name] = value;
}

-(void) addParam: (NSString *) name withIntValue: (NSInteger) value
{
	NSString * valueStr = [NSString stringWithFormat:@"%ld", (long)value];
	[self addParam:name withValue:valueStr];
}

-(void) removeParam: (NSString *) name {
    [dict removeObjectForKey:name];
}


-(NSString *)paramByName: (NSString *)name
{
	return dict[name];
}

-(NSString *)paramByName: (NSString *)name withDefault: (NSString *)defaultValue
{
	NSString * res = dict[name];
	if (res != nil && [res isEqualToString:@""] == NO)
		return res;
	else
		return defaultValue;
}

-(NSInteger) intParamByName: (NSString *)name
{
	NSString * res = [self paramByName:name];
	if (res != nil && [res isEqualToString:@""] == NO)
		return [res integerValue];
	else
		return 0;
}

-(NSInteger) intParamByName: (NSString *)name withDefault: (NSInteger)defaultValue
{
	NSString * res = [self paramByName:name];
	if (res != nil && [res isEqualToString:@""] == NO)
		return [res integerValue];
	else
		return defaultValue;
}

// IsBack (parámetro especial
-(BOOL)isBack
{
	NSInteger val = [self intParamByName:@"isBack"];
	if (val == 1)
		return YES;
	else
		return NO;
}



@end
