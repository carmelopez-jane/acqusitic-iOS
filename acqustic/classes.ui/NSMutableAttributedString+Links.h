//
//  ProgressIndicatorView.h
//  iQuiosc
//
//  Created by Joan on 05/09/14.
//  Copyright (c) 2014 Bab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface NSMutableAttributedString (SetAsLinkSupport)

- (BOOL)setAsLink:(NSString*)textToFind linkURL:(NSString*)linkURL;

@end

/*
 https://stackoverflow.com/questions/21629784/how-can-i-make-a-clickable-link-in-an-nsattributedstring
 
 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:"I love stackoverflow!"];

 BOOL linkWasSet = [attributedString setAsLink:@"stackoverflow" linkURL:@"http://stackoverflow.com"];

 if (linkWasSet) {
     // adjust more attributedString properties
 }
 */
