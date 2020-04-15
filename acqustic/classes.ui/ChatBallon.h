//
//  ChatBallon.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"

#define BALLOON_TEXT            0
#define BALLOON_IMAGE           1
#define BALLOON_BUDGET          2

IB_DESIGNABLE
@interface ChatBallon : UIView {
    UIView_onClicked _onClick;
    int _type;
    UIView * _content;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIView *bkView;
@property (strong, nonatomic) IBOutlet UILabel * lblText;
@property (strong, nonatomic) IBOutlet UILabel * lblTime;

@property (nonatomic) IBInspectable NSString * text;
@property (nonatomic) IBInspectable NSString * time;

-(id)initWithText:(NSString *)text time:(NSString *)time fromUser:(BOOL)fromUser;
-(id)initWithImage:(NSString *)imageUrl time:(NSString *)time fromUser:(BOOL)fromUser;
-(id)initWithForm:(UIView *)form time:(NSString *)time fromUser:(BOOL)fromUser;
-(void) prepareForInterfaceBuilder;
-(void) setOnClick:(UIView_onClicked)onClick;

@end
