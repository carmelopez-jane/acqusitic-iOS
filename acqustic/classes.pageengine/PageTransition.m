//
//  PageTransition.m
//  ViewTransitions
//
//  Created by Javier Garcés González on 10/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "PageTransition.h"
#import "PageTransitionNone.h"
#import <QuartzCore/QuartzCore.h>


@implementation PageTransition

-(id)init {
    if (self = [super init]) {
        return self;
    } else {
        return nil;
    }
}

// API de las transiciones
-(void)setDelegate:(id)del
{
	delegate = del;
}

-(void)transitionFor: (UIView *)containerView fromView: (UIView *)oldView toView: (UIView *)newView
{
}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	// Llamo al dueño de la transición...
	if (delegate != nil)
		[delegate animationDidStop:theAnimation finished:flag];
}



+(PageTransition *) noTransition
{
	static PageTransitionNone * trans = nil;

	if (trans == nil)
		trans = [[PageTransitionNone alloc] init];

	return trans;
	
}

@end
