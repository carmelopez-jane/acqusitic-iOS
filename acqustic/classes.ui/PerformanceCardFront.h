//
//  PerformanceCardFront.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Performance.h"

IB_DESIGNABLE
@interface PerformanceCardFront : UIView {
    Performance * perf;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel * lblTitle;
@property (strong, nonatomic) IBOutlet UILabel * lblDetail;
@property (strong, nonatomic) IBOutlet UILabel * lblMasInfo;
@property (strong, nonatomic) IBOutlet UIView * vType;
@property (strong, nonatomic) IBOutlet UILabel * lblType;
@property (strong, nonatomic) IBOutlet UIView * vPro;


@property (nonatomic) Performance * perf;

-(void) prepareForInterfaceBuilder;
-(CGFloat) setPerformance:(Performance *)perf;
-(void) adjustForHeight:(CGFloat)newHeight;

@end
