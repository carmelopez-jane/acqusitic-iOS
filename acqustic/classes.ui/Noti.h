//
//  Noti.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface Noti : UIView {
    
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel * lblMessage;
@property (strong, nonatomic) IBOutlet UILabel * lblDate;
@property (strong, nonatomic) IBOutlet UIButton * btnAction1;
@property (strong, nonatomic) IBOutlet UIButton * btnAction2;
@property (strong, nonatomic) IBOutlet UIView *vSep;

-(void) prepareForInterfaceBuilder;

-(void) setNotification:(NSString *)message date:(long)date button:(NSString *)button;
-(void) setNotification:(NSString *)message date:(long)date button1:(NSString *)button1 button2:(NSString *)button2;
@end
