//
//  ChatBallonTF.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "ChatBallonTF.h"
#import "Utils.h"
#import "Acqustic.h"

@implementation ChatBallonTF

@synthesize contentView, tfText, lblTime, bkView;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit];
        _type = BALLOON_TEXT;
        _content = self.tfText;
        [self setupSize:_content fromUser:NO];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internalInit];
        _type = BALLOON_TEXT;
        _content = self.tfText;
        [self setupSize:_content fromUser:NO];
    }
    return self;
}

-(id)initWithText:(NSString *)text time:(NSString *)time fromUser:(BOOL)fromUser {
    self = [super initWithFrame:CGRectMake(0,0,375,150)];
    if (self) {
        [self internalInit];
        _type = BALLOON_TEXT;
        _content = self.tfText;
        self.tfText.text = text;
        self.lblTime.text = time;
        self.tfText.dataDetectorTypes = (UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber);
        self.tfText.editable = NO;
        self.tfText.selectable = YES;
        self.tfText.userInteractionEnabled = YES;
        if (fromUser) {
            self.tfText.textAlignment = NSTextAlignmentRight;
        } else {
            self.tfText.textAlignment = NSTextAlignmentLeft;
        }
        // Tengo que ajustar el tamaño de la cosa
        CGFloat fullWidth = UIScreen.mainScreen.bounds.size.width;
        int maxBallonSize = fullWidth - (375-262);
        [Utils adjustUITextViewSize:self.tfText fromWidth:150 toWidth:maxBallonSize];
        [self setupSize:_content fromUser:fromUser];
    }
    
    return self;
}

-(id)initWithImage:(NSString *)imageUrl time:(NSString *)time fromUser:(BOOL)fromUser {
    self = [super initWithFrame:CGRectMake(0,0,375,150)];
    if (self) {
        [self internalInit];
        _type = BALLOON_IMAGE;
        self.tfText.hidden = YES;
        self.lblTime.text = time;
        UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageUrl]];
        img.clipsToBounds = YES;
        img.contentMode = UIViewContentModeScaleAspectFill;
        CGFloat fullWidth = UIScreen.mainScreen.bounds.size.width;
        int maxBallonSize = fullWidth - (375-262);
        img.frame = CGRectMake(tfText.frame.origin.x,tfText.frame.origin.y+5,maxBallonSize,200);
        _content = img;
        [self.bkView addSubview:img];
        [self setupSize:_content fromUser:fromUser];
    }
    return self;
}

-(id)initWithForm:(UIView *)form time:(NSString *)time fromUser:(BOOL)fromUser {
    self = [super initWithFrame:CGRectMake(0,0,375,150)];
    if (self) {
        [self internalInit];
        _type = BALLOON_IMAGE;
        self.tfText.hidden = YES;
        form.frame = CGRectMake(self.tfText.frame.origin.x, self.tfText.frame.origin.y, self.tfText.frame.size.width, form.frame.size.height);
        [self.bkView addSubview:form];
        _content = form;
        [self setupSize:_content fromUser:fromUser];
    }
    return self;
}

-(void)internalInit {
    NSBundle * bundle = [NSBundle bundleForClass:self.class];
    if (bundle) {
        [bundle loadNibNamed:@"ChatBallonTF" owner:self options:nil];
        if (self.contentView) {
            [self addSubview:self.contentView];
            self.contentView.frame = self.bounds;
        }
    }
}

-(void) setupSize:(UIView *)content fromUser:(BOOL)fromUser {
    
    // Activo o desactivo uno u otro modo (usuario)
    if (fromUser) {
        self.bkView.backgroundColor = [Utils uicolorFromARGB:0x33B7B7B7];
    } else {
        self.bkView.backgroundColor = [Utils uicolorFromARGB:0x3306B8AD];
    }
    // Ajustamos el tamaño de todo alrededor del texto
    self.bkView.frame = CGRectMake(self.bkView.frame.origin.x, self.bkView.frame.origin.y, content.frame.size.width + 16 + 16, content.frame.size.height + 8 + 25);
    self.contentView.frame = CGRectMake(0,0,self.bkView.frame.origin.x+self.bkView.frame.size.width,self.bkView.frame.origin.y+self.bkView.frame.size.height+15);
    self.frame = self.contentView.frame;
}

-(void) prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self internalInit];
    _type = BALLOON_TEXT;
    _content = self.tfText;
    [self setupSize:_content fromUser:NO];
}

-(NSString *) text {
    if (!self.tfText)
        return nil;
    return self.tfText.text;
}

-(void) setText:(NSString *)text {
    if (!self.tfText)
        return;
    self.tfText.text = text;
}

-(NSString *)time {
    if (!self.lblTime)
        return nil;
    return self.lblTime.text;
}

-(void) setTime:(NSString *)time {
    if (!self.lblTime)
        return;
    self.lblTime.text = time;
}

-(void) setOnClick:(UIView_onClicked)onClick {
    _onClick = onClick;
}

@end
