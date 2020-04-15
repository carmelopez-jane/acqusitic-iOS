//
//  AppConfig.h
//  acqustic
//
//  Created by Javier Garcés on 02/02/2020.
//  Copyright © 2020 Foxtenn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppConfig : NSObject {
    NSDictionary * values;
    NSString * chat_outofschedule_message_es;
    int chat_start_hour;
    int chat_end_hour;
    NSMutableArray * chat_weekdays;
    NSMutableArray * chat_holydays;

}

@property NSDictionary * values;
@property NSString * chat_outofschedule_message_es;
@property int chat_start_hour;
@property int chat_end_hour;
@property NSMutableArray * chat_weekdays;
@property NSMutableArray * chat_holydays;

-(id) init;
-(void) setup:(NSDictionary *) data;
-(int) getHourFromStringDate:(NSString *)date defaultValue:(int)defaultValue;
-(NSString *) getDateFromStringDate:(NSString *)date defaultValue:(NSString *)defaultValue;
-(NSArray *) getValues:(NSString *)index;
-(BOOL) inChatSchedule;

@end

NS_ASSUME_NONNULL_END
