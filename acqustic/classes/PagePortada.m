//
//  PagePortada.m
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PagePortada.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "WSDataManager.h"

@interface PagePortada ()

@end

@implementation PagePortada

@synthesize lblVersion, ivLogo;

-(void)onEnterPage:(PageContext *)context{
    
    done = NO;
    
    [super onEnterPage:context];
    [self loadNIB:@"PagePortada"];
    
    NSString * version = [AppDelegate getAppVersion];
    self.lblVersion.text = version;
    
    // Delay execution of my block for 10 seconds.
    PagePortada * refThis = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        refThis->done = YES;
        if ([[theApp.pages getCurPage].pageName isEqualToString:@"PORTADA"])
            [refThis goToMain];
    });
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBkClicked)];
    [self.pageView addGestureRecognizer:tap];
    
}

-(UIView *) loadNIB:(NSString *)nibName {
    // Ponemos la vista con el contenido, ajustando tamaño, fondo y demás...
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    UIView * myView = nibViews[0];
    myView.backgroundColor = [UIColor clearColor];
    myView.frame = screenRect;
    [self.pageView addSubview:myView];
    return myView;
}


-(PageContext *)onLeavePage:(NSString *)destPage {
    return PAGE_HISTORY_NOHISTORY;
}

-(void)onBkClicked {
    if (done) {
        [self goToMain];
    }
}

-(void) goToMain {
    [theApp showBlockView];
    [WSDataManager getAppConfig:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [theApp.appConfig setup:result];
            [theApp jumpToStart:NO];
        } else {
            [theApp stdError:code];
        }
    }];
}

@end
