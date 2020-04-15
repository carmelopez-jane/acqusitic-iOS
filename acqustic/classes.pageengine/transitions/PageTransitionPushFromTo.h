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
	pftLeftToRight,
	pftRightToLeft,
	pftTopToBottom,
	pftBottomToTop
} PageTransitionPushFromToType;

@interface PageTransitionPushFromTo : PageTransition {

	PageTransitionPushFromToType type;
	NSNumber * duration;

}

@property(nonatomic,assign) PageTransitionPushFromToType type;
@property(nonatomic,copy) NSNumber * duration;


// API de las transiciones
-(void)transitionFor: (UIView *)containerView fromView: (UIView *)oldView toView: (UIView *)newView;

@end
