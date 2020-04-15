//
//  PerformanceCardBack.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Performance.h"

IB_DESIGNABLE
@interface PerformanceCardBack : UIView {
    Performance * perf;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel * lblTitle;
@property (strong, nonatomic) IBOutlet UILabel * lblDescription;
@property (strong, nonatomic) IBOutlet UILabel * lblDetail;
@property (strong, nonatomic) IBOutlet UIButton * btnSubscribe;

@property (nonatomic) Performance * perf;


-(void) prepareForInterfaceBuilder;
-(CGFloat) setPerformance:(Performance *)perf;

@end
