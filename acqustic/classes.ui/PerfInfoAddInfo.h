//
//  PerfInfoAddInfo.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface PerfInfoAddInfo : UIView {
    
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel * lblTitle;
@property (strong, nonatomic) IBOutlet UIView * vMoreInfo;
@property (strong, nonatomic) IBOutlet UITextView * tvMoreInfo;

@property (nonatomic) IBInspectable NSString * title;

-(void) prepareForInterfaceBuilder;

@end
