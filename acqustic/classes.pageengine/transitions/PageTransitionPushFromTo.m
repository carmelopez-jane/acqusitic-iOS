//
//  PageTransition.m
//  ViewTransitions
//
//  Created by Javier Garcés González on 10/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "PageTransitionPushFromTo.h"


@implementation PageTransitionPushFromTo

@synthesize type;
@synthesize duration;

-(id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	type = pftRightToLeft;
	
	return self;
}


// API de las transiciones
-(void)transitionFor: (UIView *)containerView fromView: (UIView *)oldView toView: (UIView *)newView
{
    CGRect screenSize = [[UIScreen mainScreen] bounds];
	// Cambio de posición de la vista para que aparezca del lado correcto
	CGRect frame = newView.frame;
	CGRect oldFrame = oldView.frame;
	switch (type)
	{
		case pftLeftToRight:
			frame.origin.x = -screenSize.size.width; // Lo pongo a la derecha...
			break;
		case pftRightToLeft:
			frame.origin.x = screenSize.size.width; // Lo pongo a la derecha...
			break;
		case pftTopToBottom:
			frame.origin.y = -screenSize.size.height; // Lo pongo a la derecha...
			break;
		case pftBottomToTop:
			frame.origin.y = screenSize.size.height; // Lo pongo a la derecha...
			break;
	}
	newView.frame = frame;

	// Muestro la vista para realizar el "efecto"
	newView.hidden = NO;
	
	// Comenzamos la animación
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: [duration doubleValue]];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate: self];
	
	// Ponemos las coordenadas finales de la nueva vista
	frame.origin.x = oldFrame.origin.x;
	frame.origin.y = oldFrame.origin.y;
	newView.frame = frame;
	// Ponemos las coordenadas finales de la antigua vista
	frame = oldView.frame;
	switch (type)
	{
		case pftLeftToRight:
			frame.origin.x = screenSize.size.width; // Lo pongo a la derecha...
			break;
		case pftRightToLeft:
			frame.origin.x = -screenSize.size.width; // Lo pongo a la derecha...
			break;
		case pftTopToBottom:
			frame.origin.y = screenSize.size.height; // Lo pongo a la derecha...
			break;
		case pftBottomToTop:
			frame.origin.y = -screenSize.size.height; // Lo pongo a la derecha...
			break;
	}
	oldView.frame = frame;
	
	
	// Vamos allá...
	[UIView commitAnimations];
}

@end
