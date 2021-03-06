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

typedef enum {
	ftLeftToRight,
	ftRightToLeft,
	ftTopToBottom,
	ftBottomToTop
} PageTransitionFromToType;

@interface PageTransitionFromTo : PageTransition {

	PageTransitionFromToType type;
	NSNumber * duration;

}

@property(nonatomic,assign) PageTransitionFromToType type;
@property(nonatomic,copy) NSNumber * duration;


// API de las transiciones
-(void)transitionFor: (UIView *)containerView fromView: (UIView *)oldView toView: (UIView *)newView;

@end
