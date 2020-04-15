//
//  WSDataManager.m
//  SegurParking
//
//  Created by Joan on 19/8/15.
//  Copyright (c) 2015 Bab Software. All rights reserved.
//

#import "Preferences.h"
/*
#import "RNEncryptor.h"
#import "RNDecryptor.h"
*/

static Preferences * _prefs;
static NSString * _cpd = @"S1!2ld0kdfjc";

@implementation Preferences

@synthesize preferences = _preferences;
@synthesize fileName = _fileName;

-(id)initWithFile:(NSString *)fName {
    if (self = [super init]) {
        _fileName = fName;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:_fileName]) {
            // Cargo
            NSError * error = nil;
            NSData * data = [NSData dataWithContentsOfFile:_fileName];
            //data = [RNDecryptor decryptData:data withPassword:_cpd error:&error];
            if (data != nil && error == nil) {
                NSDictionary * dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if (dataDict) {
                    _preferences = [[NSMutableDictionary alloc] initWithDictionary:dataDict];
                }
            }
        }
        if (_preferences == nil) {
            _preferences = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

+(void)init {
    NSString * prefFolder = [Preferences getPreferencesFolder];
    NSString * prefsFile = [NSString stringWithFormat:@"%@/pdata.pfr", prefFolder];
    _prefs = [[Preferences alloc] initWithFile:prefsFile];
}

+(NSObject *)objectForKey:(NSString *)key {
    return [_prefs.preferences objectForKey:key];
}

+(void)setObject:(NSObject *)value forKey:(NSString *)key {
    [_prefs.preferences setValue:value forKey:key];
}

+(int)integerForKey:(NSString *)key {
    return [(NSString *)[Preferences objectForKey:key] intValue];
}

+(void)setInteger:(int)value forKey:(NSString *)key {
    [Preferences setObject:[NSString stringWithFormat:@"%d", value] forKey:key];
}


+(void)removeObjectForKey:(NSString *)key {
    [_prefs.preferences removeObjectForKey:key];
}

+(void)synchronize {
    // Guardamos en disco...
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:_prefs.preferences options:0 error:&error];
    if (jsonData) {
        error = nil;
        //jsonData = [RNEncryptor encryptData:jsonData withSettings:kRNCryptorAES256Settings password:_cpd error:&error];
        if (error == nil) {
            [jsonData writeToFile:_prefs.fileName options:NSDataWritingAtomic error:&error];
            [Preferences addSkipBackupAttributeToItemAtPath:_prefs.fileName];
        }
    }
}

+(BOOL)addSkipBackupAttributeToItemAtPath:(NSString *) filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+(NSString *)getPreferencesFolder {
    //returns Application's support directory
    //something like this on a real device : /private/var/mobile/Containers/Data/Application/APPID/Library/Application%20Support/YOURAPPBUNDLEID/
    //something like this on the simulator : /Users/MACUSERID/Library/Developer/CoreSimulator/Devices/SIMDEVICEID/data/Containers/Data/Application/APPUUID/Library/Application%20Support/YOURAPPBUNDLEID/
    NSString * ApplicationSupportDirectory = nil;
    NSString * ApplicationDirectory = nil;
    NSArray * AllDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,NSUserDomainMask,YES);
    if (AllDirectories.count >= 1) {
        ApplicationSupportDirectory = AllDirectories[0];
    }
    if (ApplicationSupportDirectory != nil) {
        ApplicationDirectory = [ApplicationSupportDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
    }
    
    // Create the path if it doesn't exist
    if (ApplicationDirectory != nil) {
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:ApplicationDirectory
                    withIntermediateDirectories:YES
                    attributes:nil
                    error:&error];
        if (!success) {
            return nil;
        }
    }
    // If we've made it this far, we have a success
    return ApplicationDirectory;
}

@end
