//
//  NotiTab.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface NotiTab : UIView {
    
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel * lblTitle;
@property (strong, nonatomic) IBOutlet UIView * vSep;
@property (strong, nonatomic) IBOutlet UIView * vMarker;

@property (nonatomic) IBInspectable NSString * title;

-(void) prepareForInterfaceBuilder;
-(void) setSelected:(BOOL)selected;

@end
