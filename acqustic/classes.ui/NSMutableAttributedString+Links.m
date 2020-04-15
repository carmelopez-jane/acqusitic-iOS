//
//  ProgressIndicatorView.m
//  iQuiosc
//
//  Created by Joan on 05/09/14.
//  Copyright (c) 2014 Bab. All rights reserved.
//

#import "UIView+Border.h"

@implementation NSMutableAttributedString (SetAsLinkSupport)

- (BOOL)setAsLink:(NSString*)textToFind linkURL:(NSString*)linkURL {

     NSRange foundRange = [self.mutableString rangeOfString:textToFind];
     if (foundRange.location != NSNotFound) {
         [self addAttribute:NSLinkAttributeName value:linkURL range:foundRange];
         return YES;
     }
     return NO;
}

@end


