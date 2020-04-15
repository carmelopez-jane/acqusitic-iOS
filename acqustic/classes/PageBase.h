//
//  PageBase.h
//  PageBase
//
//  Created by Javier Garcés González on 10/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Page.h"
#import "HeaderNav.h"


@interface PageBase : Page {
    UIView * topView;
    UIView * bottomView;
    UIView * midView;
    NSDictionary * _badges;
    HeaderNav * _headerNav;
}

-(void) onEnterPage:(PageContext *)context;
-(UIView *) loadNIB:(NSString *)nibName;
-(void) setTopColor:(UIColor *)color;
-(void) setBottomColor:(UIColor *)color;
-(void) setBadges:(NSDictionary *)badges;
-(void) setupBadges:(HeaderNav *) header;
-(void) refreshBadges;

-(void) onShowKeyboard:(CGRect)pos;
-(void) onHideKeyboard;
@end
