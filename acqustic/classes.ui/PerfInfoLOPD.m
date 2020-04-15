//
//  PerfInfoLOPD.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PerfInfoLOPD.h"
#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"

@implementation PerfInfoLOPD

@synthesize contentView, lblTitle, swConditions, lblConditions;

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
        [bundle loadNibNamed:@"PerfInfoLOPD" owner:self options:nil];
        if (self.contentView) {
            [self addSubview:self.contentView];
            self.contentView.frame = self.bounds;
            self.swConditions.transform = CGAffineTransformMakeScale(0.75, 0.75);
            // Hacemos un ajuste de coordenadas básico
            [Utils adjustUILabelHeight:self.lblConditions];
        }
    }
}

-(void) prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self internalInit];
    [self.contentView prepareForInterfaceBuilder];
}

-(NSString *) title {
    if (!self.lblTitle)
        return nil;
    return self.lblTitle.text;
}

-(void) setTitle:(NSString *)title {
    if (!self.lblTitle)
        return;
    self.lblTitle.text = title;
}


@end
