//
//  FormItemSep.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormItem.h"

IB_DESIGNABLE
@interface FormItemSep : FormItem {
    
}

@property (strong, nonatomic) IBOutlet UIView *contentView;

-(void) prepareForInterfaceBuilder;

@end
