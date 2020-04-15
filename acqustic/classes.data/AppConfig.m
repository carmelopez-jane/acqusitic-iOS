//
//  AppConfig.m
//  acqustic
//
//  Created by Javier Garcés on 02/02/2020.
//  Copyright © 2020 Foxtenn. All rights reserved.
//

#import "AppConfig.h"

@implementation AppConfig

@synthesize values, chat_outofschedule_message_es, chat_start_hour, chat_end_hour, chat_weekdays, chat_holydays;

-(id) init {
    return [super init];
}

-(void) setup:(NSDictionary *) data {
    values = data[@"values"];
    NSDictionary * chatData = data[@"chat"];
    chat_outofschedule_message_es = chatData[@"chat_outofschedule_message_es"];
    chat_start_hour = [self getHourFromStringDate:chatData[@"chat_start_hour"] defaultValue:0];
    chat_end_hour = [self getHourFromStringDate:chatData[@"chat_end_hour"] defaultValue:2359];
    if (chat_end_hour < chat_start_hour) // Si por tema de zona horaria acaba antes de empezar, sumamos 24 horas...
        chat_end_hour += 2400;
    chat_weekdays = [[NSMutableArray alloc] init];
    NSArray * wds = [chatData[@"chat_weekdays"] componentsSeparatedByString:@","];
    if (wds != nil && wds.count > 0 && ![wds[0] isEqualToString:@""]) {
        for (int i=0;i<wds.count;i++) {
            if ([wds[i] isEqualToString:@"MO"]) { [chat_weekdays addObject:[NSNumber numberWithInt:2]]; }
            else if ([wds[i] isEqualToString:@"TU"]) { [chat_weekdays addObject:[NSNumber numberWithInt:3]]; }
            else if ([wds[i] isEqualToString:@"WE"]) { [chat_weekdays addObject:[NSNumber numberWithInt:4]]; }
            else if ([wds[i] isEqualToString:@"TH"]) { [chat_weekdays addObject:[NSNumber numberWithInt:5]]; }
            else if ([wds[i] isEqualToString:@"FR"]) { [chat_weekdays addObject:[NSNumber numberWithInt:6]]; }
            else if ([wds[i] isEqualToString:@"SA"]) { [chat_weekdays addObject:[NSNumber numberWithInt:7]]; }
            else if ([wds[i] isEqualToString:@"SU"]) { [chat_weekdays addObject:[NSNumber numberWithInt:1]]; }
        }
    }
    chat_holydays = [[NSMutableArray alloc] init];
    NSArray * hs = chatData[@"chat_holydays"];
    for (int i=0;i<hs.count;i++) {
        NSDictionary * dateObject = hs[i];
        NSString * datestr = dateObject[@"chat_holydays_date"];
        NSString * date = [self getDateFromStringDate:datestr defaultValue:nil];
        if (date != nil) {
            [chat_holydays addObject:date];
        }
    }

}

-(int) getHourFromStringDate:(NSString *)date defaultValue:(int)defaultValue {
    if (date == nil || (NSNull *)date == NSNull.null)
        return defaultValue;
    NSDateFormatter * fd = [[NSDateFormatter alloc] init];
    fd.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss";
    fd.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate * d = [fd dateFromString:date];
    fd = [[NSDateFormatter alloc] init];
    fd.dateFormat = @"HHmm";
    return [[fd stringFromDate:d] intValue];
}

-(NSString *) getDateFromStringDate:(NSString *)date defaultValue:(NSString *)defaultValue {
    if (date == nil || (NSNull *)date == NSNull.null)
        return defaultValue;
    NSDateFormatter * fd = [[NSDateFormatter alloc] init];
    fd.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss";
    fd.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate * d = [fd dateFromString:date];
    fd = [[NSDateFormatter alloc] init];
    fd.dateFormat = @"yyyy-MM-dd";
    return [fd stringFromDate:d];
}

-(NSArray *) getValues:(NSString *)index {
    return values[index];
}

-(BOOL) inChatSchedule {
    NSDateFormatter * hourdf = [[NSDateFormatter alloc] init];
    hourdf.dateFormat = @"HHmm";
    NSDateFormatter * datedf = [[NSDateFormatter alloc] init];
    datedf.dateFormat = @"yyyy-MM-dd";
    NSDate * dt = [NSDate dateWithTimeIntervalSinceNow:0];
    int hour = [[hourdf stringFromDate:dt] intValue];
    if (hour < chat_start_hour)
        hour += 2400;
    NSString * day = [datedf stringFromDate:dt];
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    int weekDay = (int)[comp weekday];
    // Miramos la hora
    if (hour < chat_start_hour || hour > chat_end_hour) {
        return NO; // Fuera de hora
    }
    // Miramos el día de la semana
    if (chat_weekdays != nil) {
        BOOL found = NO;
        for (int i=0;i<chat_weekdays.count;i++) {
            if ([chat_weekdays[i] intValue] == weekDay) {
                found = YES;
                break;
            }
        }
        if (!found)
            return NO;
    }
    // Miramos si es un día de fiesta
    if (chat_holydays) {
        for (int i=0;i<chat_holydays.count;i++) {
            if ([chat_holydays[i] isEqualToString:day])
                return NO;
        }
    }
    return YES;
}




@end
