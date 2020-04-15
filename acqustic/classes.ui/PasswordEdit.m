//
//  PasswordEdit.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PasswordEdit.h"

@implementation PasswordEdit

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
        [bundle loadNibNamed:@"PasswordEdit" owner:self options:nil];
        if (self.view) {
            [self addSubview:self.view];
            self.view.frame = self.bounds;

            [self.tfText setFont:[UIFont fontWithName:@"Arial-Rounded" size:16]];

            // Configuramos la vista lateral
            UIButton * viewButton = [UIButton buttonWithType:UIButtonTypeCustom];
            viewButton.frame = CGRectMake(0,0,25,25);
            self.tfText.rightViewMode = UITextFieldViewModeAlways;
            [viewButton setImage:[UIImage imageNamed:@"icon_password_open.png"] forState:UIControlStateNormal];
            [viewButton setImage:[UIImage imageNamed:@"icon_password_closed.png"] forState:UIControlStateSelected];

            viewButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [viewButton addTarget:self action:@selector(onView:) forControlEvents:UIControlEventTouchUpInside];
            self.tfText.rightView = viewButton;
            self.tfText.rightViewMode = UITextFieldViewModeAlways;
            self.tfText.autocorrectionType = UITextAutocorrectionTypeNo;
            self.tfText.secureTextEntry = YES;

            self.backgroundColor = [UIColor clearColor];
        }
    }
}

-(void) prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self internalInit];
    [self.view prepareForInterfaceBuilder];
}

-(void) onView:(UIButton *)sender {
    if (sender.selected)
    {
        sender.selected = NO;
        self.tfText.secureTextEntry = YES;
        if (self.tfText.isFirstResponder) {
            [self.tfText resignFirstResponder];
            [self.tfText becomeFirstResponder];
        }
    }
    else
    {
        sender.selected = YES;
        self.tfText.secureTextEntry = NO;
        if (self.tfText.isFirstResponder) {
            [self.tfText resignFirstResponder];
            [self.tfText becomeFirstResponder];
        }
    }
}

@end
