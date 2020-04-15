//
//  PageTransition.m
//  ViewTransitions
//
//  Created by Javier Garcés González on 10/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "PageTransitionCA.h"


@implementation PageTransitionCA

@synthesize type;
@synthesize subType;
@synthesize duration;



// API de las transiciones
-(void)transitionFor: (UIView *)containerView fromView: (UIView *)oldView toView: (UIView *)newView;
{
	// First create a CATransition object to describe the transition
	CATransition * transition = [CATransition animation];
	// Animate over 3/4 of a second
	transition.duration = [duration doubleValue];
	// using the ease in/out timing function
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	// Now to set the type of transition. Since we need to choose at random, we'll setup a couple of arrays to help us.
	transition.type = type;
	if (subType != nil)
		transition.subtype = subType;
	// Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
	[containerView.layer addAnimation:transition forKey:nil];
	
	// Nos ponemos de delegados de la transición, para saber cuándo acaba
	transition.delegate = self;

	// Finalmente, ponemos en marcha la "grabadora" para la animación.
	// Cualquier cambio posterior en la vista contenedora se hará usando los efectos de la transición
	[containerView.layer addAnimation:transition forKey:nil];
	
	// Procedemos a realizar los "efectos", básicamente estableciendo el estado final
	if (oldView != nil)
		oldView.hidden = YES;
	newView.hidden = NO;
	
}


@end
