//
//  PageTransition.h
//  ViewTransitions
//
//  Created by Javier Garcés González on 10/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface PageTransition : NSObject {
	id delegate;
}

-(id)init;

// API de las transiciones
-(void)setDelegate:(id)delegate;
-(void)transitionFor: (UIView *)containerView fromView: (UIView *)oldView toView: (UIView *)newView;

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag;


// API público
+(PageTransition *) noTransition;

@end
