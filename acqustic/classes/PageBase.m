//
//  PageBase.m
//  PageBase
//
//  Created by Javier GarcÃ©s GonzÃ¡lez on 10/07/11.
//  Copyright 2011 Sinergia sistemas informÃ¡ticos S.L. All rights reserved.
//

#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"
#import "PageBase.h"
#import "WSDataManager.h"


@implementation PageBase

-(void) onEnterPage:(PageContext *)context {
    // Tenemos que detectar si hay notch
    UIWindow * mainWindow = UIApplication.sharedApplication.keyWindow;
    BOOL hasNotch = [theApp hasNotch];
    if (hasNotch) {
        topView = [[UIView alloc] initWithFrame:CGRectMake(0,0,mainWindow.frame.size.width, mainWindow.safeAreaInsets.top)];
        bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,mainWindow.frame.size.height-mainWindow.safeAreaInsets.bottom,mainWindow.frame.size.width, mainWindow.safeAreaInsets.bottom)];
        midView = [[UIView alloc] initWithFrame:CGRectMake(0,topView.frame.size.height,mainWindow.frame.size.width, mainWindow.frame.size.height - mainWindow.safeAreaInsets.top - mainWindow.safeAreaInsets.bottom)];
        NSLog(@"WINDOW VIEW: %f %f", mainWindow.frame.origin.y, mainWindow.frame.size.height);
        NSLog(@"MID VIEW: %f %f", midView.frame.origin.y, midView.frame.size.height);
        [self.pageView addSubview:topView];
        [self.pageView addSubview:bottomView];
        [self.pageView addSubview:midView];
    } else {
        int safeY = 22;
        topView = [[UIView alloc] initWithFrame:CGRectMake(0,0,mainWindow.frame.size.width, safeY)];
        midView = [[UIView alloc] initWithFrame:CGRectMake(0,topView.frame.size.height,mainWindow.frame.size.width, mainWindow.frame.size.height - safeY)];
        bottomView = nil;
        [self.pageView addSubview:topView];
        [self.pageView addSubview:midView];
    }
}

-(UIView *) loadNIB:(NSString *)nibName {
    // Ponemos la vista con el contenido, ajustando tamaño, fondo y demás...
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    UIView * myView = nibViews[0];
    myView.backgroundColor = [UIColor clearColor];
    myView.frame = CGRectMake(0,0,midView.frame.size.width, midView.frame.size.height);
    [midView addSubview:myView];
    return myView;
}


-(void) setTopColor:(UIColor *)color {
    if (topView) {
        topView.backgroundColor = color;
    }
}

-(void) setBottomColor:(UIColor *)color {
    if (bottomView) {
        bottomView.backgroundColor = color;
    }
}

-(void) onShowKeyboard:(CGRect)pos {
    
}

-(void) onHideKeyboard {
    
}


-(void) setBadges:(NSDictionary *)badges {
    _badges = badges;
}

-(void) setupBadges:(HeaderNav *) header {
    _headerNav = header;
    if (header && _badges) {
        [header setBadges:_badges];
    }
}

-(void) refreshBadges {
    if (_headerNav) {
        [WSDataManager getNotificationBadges:^(int code, NSDictionary *result, NSDictionary *badges) {
            [self setBadges:badges];
            [self setupBadges:self->_headerNav];
        }];
    }
}


@end
