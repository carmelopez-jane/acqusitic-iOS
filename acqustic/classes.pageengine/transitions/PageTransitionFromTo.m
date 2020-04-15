//
//  PageTransition.m
//  ViewTransitions
//
//  Created by Javier Garcés González on 10/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "PageTransitionFromTo.h"


@implementation PageTransitionFromTo

@synthesize type;
@synthesize duration;

-(id) init
{
	type = ftRightToLeft;
	
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
		case ftLeftToRight:
			frame.origin.x = -screenSize.size.width; // Lo pongo a la derecha...
			break;
		case ftRightToLeft:
			frame.origin.x = screenSize.size.width; // Lo pongo a la derecha...
			break;
		case ftTopToBottom:
			frame.origin.y = -screenSize.size.height; // Lo pongo a la derecha...
			break;
		case ftBottomToTop:
			frame.origin.x = screenSize.size.height; // Lo pongo a la derecha...
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
	
	// Ponemos las coordenadas finales, que han de coincidir con la página anterior...
	frame.origin.x = oldFrame.origin.x;
	frame.origin.y = oldFrame.origin.y;
	newView.frame = frame;
	
	// Vamos allá...
	[UIView commitAnimations];
}

@end
