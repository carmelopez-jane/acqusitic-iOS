//
//  FormItemSubitem.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormItem.h"

IB_DESIGNABLE
@interface FormItemSubitem : FormItem {
    
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel *lblLabel;
@property (strong, nonatomic) IBOutlet UILabel *lblValue;
@property (strong, nonatomic) IBOutlet UIImageView * ivIcon;
@property (strong, nonatomic) IBOutlet UIView * vIcon;

-(void) prepareForInterfaceBuilder;
-(void) updateSize;

@end
