//
//  UIGestureRecognizer+Blocks.h
//  UIGestureRecognizers_Demo
//
//  Created by Ian Outterside on 10/04/2013.
//  Copyright (c) 2013 Ian Builds Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

// Declare a completion block to be called when the action fires
typedef void (^UIGestureRecognizerActionBlock)(UIGestureRecognizer *);

@interface UIGestureRecognizer (Blocks)

// New initializer for the gesture recognizer with blocks
- (id)initWithBlock:(UIGestureRecognizerActionBlock)block;

@end
