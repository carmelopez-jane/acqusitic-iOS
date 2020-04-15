//
//  PopupWeb.m
//  juegodeortografia
//
//  Created by Javier Garcés González on 15/06/12.
//  Copyright 2012 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Acqustic.h"
#import "Popup.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>


@implementation Popup;

-(id) init {
    return [self initWithFrame:UIScreen.mainScreen.bounds];
}

-(void) dispatchCommand:(int)cmd close:(BOOL)close
{
    if (close) {
        if (_onClose != nil)
            _onClose(self);
        [theApp closePopup:self];
    }
    if (_onCommand != nil)
        _onCommand(self, cmd, nil);
}


@end
