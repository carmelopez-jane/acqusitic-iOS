//
//  PerfInfoLOPD.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface PerfInfoLOPD : UIView {
    
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel * lblTitle;
@property (strong, nonatomic) IBOutlet UISwitch * swConditions;
@property (strong, nonatomic) IBOutlet UILabel * lblConditions;

@property (nonatomic) IBInspectable NSString * title;

-(void) prepareForInterfaceBuilder;

@end
