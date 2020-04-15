//
//  FormItem.m
//  Acqustic
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PerformanceCard.h"

@implementation PerformanceCard

@synthesize perf;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}


//cause making TWPhotoCollectionViewCell in storyboard
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}


- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    frontCard = [[PerformanceCardFront alloc] initWithFrame:self.frame];
    //frontCard.backgroundColor = [UIColor redColor];
    frontCard.layer.cornerRadius = 10;
    
    backCard = [[PerformanceCardBack alloc] initWithFrame:self.frame];
    //backCard.backgroundColor = [UIColor greenColor];
    backCard.layer.cornerRadius = 10;
}

-(void) setPerformance:(Performance *)p {
    self.perf = p;
    [frontCard setPerformance:p];
    [frontCard adjustForHeight:p.cardHeight];
    [backCard setPerformance:p];
    [frontCard adjustForHeight:p.cardHeight];
    [frontCard removeFromSuperview];
    [backCard removeFromSuperview];
    if (self.perf.isBackVisible) {
        [self addSubview:backCard];
    } else {
        [self addSubview:frontCard];
    }
}

- (void) flip {
    PerformanceCard * refThis = self;
    UIViewAnimationOptions to = UIViewAnimationOptionTransitionFlipFromRight;
    if (!self.perf.isBackVisible) {
        [UIView transitionFromView:frontCard toView:backCard duration:0.5 options:to completion:^(BOOL finished) {
            refThis.perf.isBackVisible = YES;
        }];
    } else {
        [UIView transitionFromView:backCard toView:frontCard duration:0.5 options:to completion:^(BOOL finished) {
            refThis.perf.isBackVisible = NO;
        }];
    }
    /*
    PerformanceCard * refThis = self;
    int to = UIViewAnimationTransitionFlipFromRight | UIViewAnimationOptionShowHideTransitionViews;
    [UIView transitionWithView:frontCard duration:10.0 options:to animations:^{
        refThis->frontCard.hidden = YES;
    } completion:^(BOOL finished) {
    }];
    [UIView transitionWithView:backCard duration:10.0 options:to animations:^{
        refThis->backCard.hidden = NO;
    } completion:^(BOOL finished) {
    }];
     */
}

@end
