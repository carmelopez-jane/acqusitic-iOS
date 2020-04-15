//
//  Imageitem.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface Imageitem : UIView {
    
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIImageView * ivIcon;
@property (strong, nonatomic) IBOutlet UIView * vDelete;
@property (strong, nonatomic) IBOutlet UIImageView * ivImage;

-(void) prepareForInterfaceBuilder;

@end
