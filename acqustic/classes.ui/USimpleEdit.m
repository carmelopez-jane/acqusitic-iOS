//
//  USimpleEdit.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "USimpleEdit.h"

@implementation USimpleEdit

@synthesize view, tfText;

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
        [bundle loadNibNamed:@"USimpleEdit" owner:self options:nil];
        if (self.view) {
            [self addSubview:self.view];
            self.view.frame = self.bounds;

            [self.tfText setFont:[UIFont fontWithName:@"Arial-Rounded" size:15]];
            self.tfText.autocorrectionType = UITextAutocorrectionTypeNo;
            
            self.backgroundColor = [UIColor clearColor];
        }
    }
}

-(void) prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self internalInit];
    [self.view prepareForInterfaceBuilder];
}


@end
