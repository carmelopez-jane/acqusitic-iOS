//
//  PageMenu.h
//  PageMenu
//
//  Created by Javier Garcés González on 10/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Page.h"
#import "PageBase.h"
#import "PageMenuView.h"


@interface PageMenu : PageBase {
    PageMenuView * _menu;
    UIView * _contentView;
}

@property PageMenuView * menu;
@property UIView * contentView;

-(void)refreshLblLogo;

@end
