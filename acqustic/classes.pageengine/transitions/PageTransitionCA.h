//
//  PageTransition.h
//  ViewTransitions
//
//  Created by Javier Garcés González on 10/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "PageTransition.h"


@interface PageTransitionCA : PageTransition {

	// Transición de entrada y de salida...
	NSString * type;
	NSString * subType;
	NSNumber * duration;
	
}

@property(nonatomic,retain) NSString * type;
@property(nonatomic,retain) NSString * subType;
@property(nonatomic,copy) NSNumber * duration;

// API de las transiciones
-(void)transitionFor: (UIView *)containerView fromView: (UIView *)oldView toView: (UIView *)newView;

@end
