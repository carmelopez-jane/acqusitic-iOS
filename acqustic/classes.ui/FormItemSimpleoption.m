//
//  FormItemSimpleoption.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "FormItemSimpleoption.h"
#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"

@implementation FormItemSimpleoption

@synthesize contentView, lblLabel, tfValue, ivIcon, vIcon;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internalInit];
    }
    return self;
}

-(void)internalInit {
    NSBundle * bundle = [NSBundle bundleForClass:self.class];
    if (bundle) {
        [bundle loadNibNamed:@"FormItemSimpleoption" owner:self options:nil];
        if (self.contentView) {
            [self addSubview:self.contentView];
            self.contentView.frame = self.bounds;
        }
    }
}

-(void) prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self internalInit];
    [self.contentView prepareForInterfaceBuilder];
}

-(void) updateSize {
    // El label no puede pasar del 60%
    int maxLabelWidth = self.frame.size.width*0.6;
    CGSize sz = [self.lblLabel intrinsicContentSize];
    if (sz.width > maxLabelWidth)
        sz.width = maxLabelWidth;
    CGRect fr = self.lblLabel.frame;
    fr.size.width = sz.width;
    self.lblLabel.frame = fr;
    // Ahora ajustamos el valor
    fr = self.tfValue.frame;
    int newX = (self.lblLabel.frame.origin.x + self.lblLabel.frame.size.width + 10);
    int diff = newX - fr.origin.x;
    fr.origin.x += diff;
    fr.size.width -= diff;
    self.tfValue.frame = fr;
}


@end
