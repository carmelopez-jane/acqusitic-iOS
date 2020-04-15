//
//  UIPageViewController+PageControl.m
//  cadernomagico
//
//  Created by Javier Garcés on 28/9/18.
//  Copyright © 2018 Caderno Magico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIPageViewController+PageControl.h"

@implementation UIPageViewController (PageControl)

- (UIPageControl *)pageControl
{
    __block UIPageControl *pageControl = nil;
    void (^pageControlAssignBlock)(UIPageControl *) = ^void(UIPageControl *blockPageControl) {
        pageControl = blockPageControl;
    };
    
    [self recurseForPageControlFromSubViews:self.view.subviews withAssignBlock:pageControlAssignBlock];
    
    return pageControl;
}

- (void)recurseForPageControlFromSubViews:(NSArray *)subViews withAssignBlock:(void (^)(UIPageControl *))assignBlock
{
    for (UIView *subView in subViews) {
        if ([subView isKindOfClass:[UIPageControl class]]) {
            assignBlock((UIPageControl *)subView);
            break;
        } else {
            [self recurseForPageControlFromSubViews:subView.subviews withAssignBlock:assignBlock];
        }
    }
}

@end

