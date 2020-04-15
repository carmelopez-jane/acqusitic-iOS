//
//  ProgressIndicatorView.m
//  iQuiosc
//
//  Created by Joan on 05/09/14.
//  Copyright (c) 2014 Bab. All rights reserved.
//

#import "UIView+Border.h"

@implementation UIView (Border)

@dynamic borderColor,borderWidth,cornerRadius;

-(void)setBorderColor:(UIColor *)borderColor{
    [self.layer setBorderColor:borderColor.CGColor];
}

-(void)setBorderWidth:(CGFloat)borderWidth{
    [self.layer setBorderWidth:borderWidth];
}

-(void)setCornerRadius:(CGFloat)cornerRadius{
    [self.layer setCornerRadius:cornerRadius];
}

@end

