//
//  FormImageInput.h
//  nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import "FormInput.h"

IB_DESIGNABLE
@interface FormImageInput : FormInput <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    int mode;
    NSInteger rangeMin;
    NSInteger rangeMax;
    NSMutableArray * images; // URLs
    NSMutableArray * _images; // UIImageViews
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel * lblTitle;
@property (strong, nonatomic) IBOutlet UILabel * lblSubtitle;
@property (strong, nonatomic) IBOutlet UILabel * lblRACCError;
@property (strong, nonatomic) IBOutlet UIView * vDropImage;
@property (strong, nonatomic) IBOutlet UIImageView * ivDropImage;


-(void) prepareForInterfaceBuilder;

-(int) setup:(NSDictionary *)config lang:(NSString *)lang value:(NSString *)value error:(NSString *)error;

@end
