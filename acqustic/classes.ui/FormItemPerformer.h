//
//  FormItemPerformer.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormItem.h"
#import "Performer.h"

IB_DESIGNABLE
@interface FormItemPerformer : FormItem {
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel *lblLabel;
@property (strong, nonatomic) IBOutlet UIImageView * ivIcon;
@property (strong, nonatomic) IBOutlet UIView * vIcon;
@property (strong, nonatomic) IBOutlet UIImageView * ivCheck;
@property (strong, nonatomic) IBOutlet UIImageView * ivStatus;
@property (strong, nonatomic) IBOutlet UIView * vCheck;

-(void) prepareForInterfaceBuilder;
-(void) updateSize;
-(void) setChecked:(BOOL)on;

@end
