//
//  UIGestureRecognizer+Blocks.m
//  UIGestureRecognizers_Demo
//
//  Created by Ian Outterside on 10/04/2013.
//  Copyright (c) 2013 Duchy Software Ltd. All rights reserved.
//

/* 
 
 Discussion

 This catagory leverages the objective-c runtime to dynamically bind a block to a UIGestureRecognizer object.
 This means that all UIGestureRecognizer subclasses (eg UITapGestureRecognizer, UIPanGestureRecognizer etc) can
 now leverage the power of blocks simply by importing the catagory.
 
 To use the block based API, simply call:
 
 UI(Tap/Pan/etc)GestureRecognizer *gesture = [[UI(Tap/Pan/etc)GestureRecognizer alloc] initWithBlock:^(UIGestureRecognizer *recognizer){
    
    // Callback code
 
    // In the callback code, if you need specfic actions of the recognizer, simply cast it back to its original type - eg:
 
    // UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer *)recognizer;
 }];

 */

#import "UIGestureRecognizer+Blocks.h"
#import <objc/runtime.h> // Need the objective-c runtime for object associations

@implementation UIGestureRecognizer (Blocks)

// Create static reference pointer to access stored block operation
static char kUIGESTURERECOGNIZER_BLOCK_IDENTIFIER;

- (id)initWithBlock:(UIGestureRecognizerActionBlock)block {
    
    if (self = [self init]) {
        
        // Add a target/action to the recognizer, calling back to [self completionHandler]
        [self addTarget:self action:@selector(completionHandler)];

        objc_setAssociatedObject(self, &kUIGESTURERECOGNIZER_BLOCK_IDENTIFIER, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return self;
}

// This fires when the normal target:action fires
- (void)completionHandler {
    
    // Fetch the block operation from the association
    UIGestureRecognizerActionBlock block = (UIGestureRecognizerActionBlock)objc_getAssociatedObject(self, &kUIGESTURERECOGNIZER_BLOCK_IDENTIFIER);
    
    // If the block operation exists, call start. This invokes the anonymous block, in turn invoking the passed in block
    if (block) {
        block(self);
    }
}


@end
