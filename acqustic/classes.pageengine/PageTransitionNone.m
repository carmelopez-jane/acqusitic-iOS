//
//  PageTransition.m
//  ViewTransitions
//
//  Created by Javier Garcés González on 10/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "PageTransitionNone.h"


@implementation PageTransitionNone

-(id)init {
    if (self = [super init]) {
        return self;
    } else {
        return nil;
    }
}


// API de las transiciones
-(void)transitionFor: (UIView *)containerView fromView: (UIView *)oldView toView: (UIView *)newView
{
	newView.hidden = NO;
	oldView.hidden = YES;
	
	[self animationDidStop:nil finished:YES];
	
}

@end
