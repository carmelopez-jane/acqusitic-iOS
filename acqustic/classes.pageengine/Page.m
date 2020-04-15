//
//  Page.m
//  ViewTransitions
//
//  Created by Javier Garcés González on 07/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "Page.h"
#import "PageTransition.h"
#import "PageEngine.h"


@implementation Page

@synthesize owner;
@synthesize pageName;
@synthesize pageView;
@synthesize _context;

-(id) init
{
    if (self = [super init]) {
        return self;
    } else {
        return nil;
    }
}

-(BOOL) onPreloadPage:(PageContext *)context {
    return NO;
}

-(void) onEnterPage:(PageContext *)context {
    
}

-(void) onRecyclePage:(PageContext *)context {
    
}

-(void) onShowPage {
    
}

-(PageContext *)onLeavePage:(NSString *)destPage {
    return nil;
}

-(void) onTransitionPage {
    
}

-(void) onDeactivate {
    
}

-(void) onActivate {
    
}

-(BOOL) onQueryVolver {
    return YES;
}

-(Page *) newPage {
    return nil;
}

-(void) endPreloading:(BOOL)success {
    [owner endPreloadingPage:success];
}



@end
