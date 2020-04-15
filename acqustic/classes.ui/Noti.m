//
//  Noti.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "Noti.h"
#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"
#import "NSAttributedString+DDHTML.h"

@implementation Noti

@synthesize contentView, lblMessage, lblDate, btnAction1, btnAction2;

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
        [bundle loadNibNamed:@"Noti" owner:self options:nil];
        if (self.contentView) {
            [self addSubview:self.contentView];
            /* debug
            self.contentView.frame = self.bounds;
            self.layer.borderColor = [[UIColor redColor] CGColor];
            self.layer.borderWidth = 1;
            */
        }
    }
}

-(void) prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self internalInit];
    [self.contentView prepareForInterfaceBuilder];
}

-(void) setNotification:(NSString *)message date:(long)date button:(NSString *)button {
    
    NSString * str = [NSString stringWithFormat:@"%@ <p></p>", message];
    NSAttributedString * attString = [NSAttributedString attributedStringFromHTML:str normalFont:[UIFont fontWithName:@"Roboto" size:13] boldFont:[UIFont fontWithName:@"Roboto-Bold" size:13] italicFont:[UIFont fontWithName:@"Roboto-Italic" size:13]];
    self.lblMessage.attributedText = attString;
    [Utils adjustUILabelHeight:self.lblMessage];
    
    self.lblDate.text = [Utils formatDateRelative:date];
    
    self.btnAction2.hidden = YES;

    CGRect fr;
    int yTop = self.lblMessage.frame.origin.y + self.lblMessage.frame.size.height;
    fr = self.lblDate.frame;
    fr.origin.y = yTop-15;
    self.lblDate.frame = fr;
    yTop += fr.size.height;

    fr = self.btnAction1.frame;
    [btnAction1 setTitle:button forState:UIControlStateNormal];
    fr.origin.x = (self.contentView.frame.size.width - self.btnAction1.frame.size.width)/2;
    fr.origin.y = yTop;
    self.btnAction1.frame = fr;
    
    yTop += fr.size.height + 15;
    
    fr = self.vSep.frame;
    fr.origin.y = yTop-1;
    self.vSep.frame = fr;
    
    fr = self.frame;
    fr.size.height = yTop;
    self.frame = fr;
    
    fr = self.contentView.frame;
    fr.size.height = yTop;
    self.contentView.frame = fr;
}

-(void) setNotification:(NSString *)message date:(long)date button1:(NSString *)button1 button2:(NSString *)button2 {
    NSString * str = [NSString stringWithFormat:@"%@ <p></p>", message];
    NSAttributedString * attString = [NSAttributedString attributedStringFromHTML:str normalFont:[UIFont fontWithName:@"Roboto" size:13] boldFont:[UIFont fontWithName:@"Roboto-Bold" size:13] italicFont:[UIFont fontWithName:@"Roboto-Italic" size:13]];
    self.lblMessage.attributedText = attString;
    [Utils adjustUILabelHeight:self.lblMessage];
    
    self.lblDate.text = [Utils formatDateRelative:date];
    
    //self.btnAction2.hidden = YES;

    CGRect fr;
    int yTop = self.lblMessage.frame.origin.y + self.lblMessage.frame.size.height;
    fr = self.lblDate.frame;
    fr.origin.y = yTop-15;
    self.lblDate.frame = fr;
    yTop += fr.size.height + 15;

    int buttonSep = 30;
    int buttonsWitdh = self.btnAction1.frame.size.width*2 + buttonSep;
    int lButtonX = (self.contentView.frame.size.width - buttonsWitdh)/2;
    
    fr = self.btnAction1.frame;
    [btnAction1 setTitle:button1 forState:UIControlStateNormal];
    fr.origin.x = lButtonX;
    fr.origin.y = yTop;
    self.btnAction1.frame = fr;

    fr = self.btnAction2.frame;
    [btnAction2 setTitle:button2 forState:UIControlStateNormal];
    fr.origin.x = lButtonX + self.btnAction1.frame.size.width + 30;
    fr.origin.y = yTop;
    self.btnAction2.frame = fr;

    yTop += fr.size.height + 15;
    
    fr = self.vSep.frame;
    fr.origin.y = yTop-1;
    self.vSep.frame = fr;
    
    fr = self.frame;
    fr.size.height = yTop;
    self.frame = fr;
    
    fr = self.contentView.frame;
    fr.size.height = yTop;
    self.contentView.frame = fr;

}


@end
