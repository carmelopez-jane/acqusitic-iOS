//
//  FormItemPerformer.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "FormItemPerformer.h"
#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"

@implementation FormItemPerformer

@synthesize contentView, lblLabel, ivIcon, vIcon, ivCheck, ivStatus, vCheck;


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
        [bundle loadNibNamed:@"FormItemPerformer" owner:self options:nil];
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
}

-(void) setChecked:(BOOL)on {
    if (on) {
        self.ivCheck.image = [UIImage imageNamed:@"icon_group_member_on.png"];
    } else {
        self.ivCheck.image = [UIImage imageNamed:@"icon_group_member_off.png"];
    }
}

@end
