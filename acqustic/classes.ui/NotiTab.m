//
//  NotiTab.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "NotiTab.h"
#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"

@implementation NotiTab

@synthesize contentView, lblTitle, vSep, vMarker;

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
        [bundle loadNibNamed:@"NotiTab" owner:self options:nil];
        if (self.contentView) {
            [self addSubview:self.contentView];
            self.contentView.frame = self.bounds;
            self.vMarker.hidden = YES;
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

-(void) setSelected:(BOOL)selected {
    if (selected) {
        lblTitle.textColor = ACQUSTIC_GREEN;
        vMarker.hidden = NO;
    } else {
        lblTitle.textColor = [Utils uicolorFromARGB:0xFFABB0B0];
        vMarker.hidden = YES;
    }
}



@end
