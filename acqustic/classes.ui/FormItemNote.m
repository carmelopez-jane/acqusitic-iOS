//
//  FormItemNote.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "FormItemNote.h"
#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"

@implementation FormItemNote

@synthesize contentView, lblLabel;

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
        [bundle loadNibNamed:@"FormItemNote" owner:self options:nil];
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
    [Utils adjustUILabelHeight:self.lblLabel];
    int newHeight = self.lblLabel.frame.size.height + 10 + 10;
    CGRect fr = self.frame;
    fr.size.height = newHeight;
    self.frame = fr;
    fr = self.contentView.frame;
    fr.size.height = newHeight;
    self.contentView.frame = fr;
}

@end
