//
//  FormItem.h
//  Acqustic
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Performance.h"
#import "PerformanceCardFront.h"
#import "PerformanceCardBack.h"

IB_DESIGNABLE
@interface PerformanceCard : UICollectionViewCell {
    Performance * perf;
    PerformanceCardFront * frontCard;
    PerformanceCardBack * backCard;
}

@property Performance * perf;

-(void) setPerformance:(Performance *)p;
-(void) flip;
@end
