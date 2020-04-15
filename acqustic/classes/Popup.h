//
//  UIMenuView.h
//  ViewTransitions
//
//  Created by Javier Garcés González on 12/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

// Algunos comandos de popup ya trillados
#define POPUP_CMD_OK                      1
#define POPUP_CMD_YES                     1
#define POPUP_CMD_CANCEL                  2
#define POPUP_CMD_NO                      2
#define POPUP_CMD_OTHER                   10

#define POPUP_CMD_LAST                      10

@class Popup;

typedef void (^Popup_onCommand)(Popup * pm, int command, NSObject * data);
typedef void (^Popup_onLink)(Popup * pm, NSString * url);
typedef void (^Popup_onClose)(Popup * pm);

@interface Popup : UIView {

    Popup_onCommand _onCommand;
    Popup_onClose _onClose;
}

@property (strong, nonatomic) Popup_onCommand onCommand;
@property (strong, nonatomic) Popup_onClose onClose;

-(id) init;
-(void) dispatchCommand:(int)cmd close:(BOOL)close;

@end
