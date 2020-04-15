//
//  PerformanceDist.h
//  Acqustic
//
//  Created by Javier Garcés González on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas informáticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface PerformanceDist : NSObject {

    // Distribución
    NSMutableArray * distValues; // Distribution
    int performersCount;

    NSInteger memberId0;
    NSInteger percent0;
    NSString * documents0;
    NSInteger memberId1;
    NSInteger percent1;
    NSString * documents1;
    NSInteger memberId2;
    NSInteger percent2;
    NSString * documents2;
    NSInteger memberId3;
    NSInteger percent3;
    NSString * documents3;
    NSInteger memberId4;
    NSInteger percent4;
    NSString * documents4;
    NSInteger memberId5;
    NSInteger percent5;
    NSString * documents5;
    NSInteger memberId6;
    NSInteger percent6;
    NSString * documents6;
    NSInteger memberId7;
    NSInteger percent7;
    NSString * documents7;
    NSInteger memberId8;
    NSInteger percent8;
    NSString * documents8;
    NSInteger memberId9;
    NSInteger percent9;
    NSString * documents9;
    
}

@property NSMutableArray * distValues; // Distribution

@property NSInteger memberId0;
@property NSInteger percent0;
@property NSString * documents0;
@property NSInteger memberId1;
@property NSInteger percent1;
@property NSString * documents1;
@property NSInteger memberId2;
@property NSInteger percent2;
@property NSString * documents2;
@property NSInteger memberId3;
@property NSInteger percent3;
@property NSString * documents3;
@property NSInteger memberId4;
@property NSInteger percent4;
@property NSString * documents4;
@property NSInteger memberId5;
@property NSInteger percent5;
@property NSString * documents5;
@property NSInteger memberId6;
@property NSInteger percent6;
@property NSString * documents6;
@property NSInteger memberId7;
@property NSInteger percent7;
@property NSString * documents7;
@property NSInteger memberId8;
@property NSInteger percent8;
@property NSString * documents8;
@property NSInteger memberId9;
@property NSInteger percent9;
@property NSString * documents9;

-(id) init;
-(void) fillInDistributionForForm:(NSArray *) performers;
-(NSString *) getDistribution;
-(BOOL) checkDistribution;

@end
