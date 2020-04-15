//
//  PageRegisterFreemium.m
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageRegisterFreemium.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "HeaderEdit.h"
#import "WSDataManager.h"
#import "NSAttributedString+DDHTML.h"
#import "PageCompleteFreemium.h"

@interface PageRegisterFreemium ()

@end

@implementation PageRegisterFreemium

@synthesize svContent, lblTitle, btnComplete, btnLater;

-(void)onEnterPage:(PageContext *)context {
    
    [super onEnterPage:context];

    [self loadNIB:@"PageRegisterFreemium"];
    //[super setTopColor:RACC_YELLOW];

    _ctx = context;
    
    [btnComplete addTarget:self action:@selector(onComplete:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnLater addTarget:self action:@selector(onLater:) forControlEvents:UIControlEventTouchUpInside];
    
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return PAGE_HISTORY_NOHISTORY;
}

-(void) onComplete:(UIButton *)btn {
    PageContext * ctx = [[PageContext alloc] init];
    [ctx addParam:@"mode" withIntValue:FREEMIUM_MODE_REGISTERBASICDATA];
    [theApp.pages jumpToPage:@"COMPLETEFREEMIUM" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
}

-(void) onLater:(UIButton *)btn {
    [theApp jumpToStart:NO];
}

@end
