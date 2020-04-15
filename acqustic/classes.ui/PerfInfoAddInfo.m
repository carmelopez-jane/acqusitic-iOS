//
//  PerfInfoAddInfo.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PerfInfoAddInfo.h"
#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"

@implementation PerfInfoAddInfo

@synthesize contentView, lblTitle, vMoreInfo, tvMoreInfo;

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
        [bundle loadNibNamed:@"PerfInfoAddInfo" owner:self options:nil];
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
