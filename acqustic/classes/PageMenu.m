//
//  PageMenu
//  PageMenu
//
//  Created by Javier Garces Gonzalez on 10/02/16.
//  Copyright 2016 Sinergia sistemas informaticos S.L. All rights reserved.
//

#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"
#import "PageMenu.h"
#import "PageMenuView.h"
#import "Preferences.h"
#import "WSDataManager.h"


@implementation PageMenu

@synthesize menu = _menu;
@synthesize contentView = _contentView;

-(id) init {
    if (self = [super init]) {
        return self;
    } else {
        return nil;
    }
}

-(void) onEnterPage:(PageContext *)context {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // Cargamos el menú
    _menu = [[PageMenuView alloc] initWithFrame:screenRect esAdmin:NO onMenuClicked:^(int option) {
        // Aquí saltamos a las diferentes secciones
        PageContext * ctx;
        switch (option) {
            case MENU_OPTION_EJERCICIOS:
                [theApp.pages jumpToPage:@"COURSESSEL" withContext:nil];
                break;
            case MENU_OPTION_PINS:
                [theApp.pages jumpToPage:@"COURSESPINSSEL" withContext:nil];
                break;
            case MENU_OPTION_ALUMNO:
                [theApp.pages jumpToPage:@"USERS" withContext:nil];
                break;
            case MENU_OPTION_TOUR:
                ctx = [[PageContext alloc] init];
                [ctx addParam:@"STANDALONE" withValue:@"1"];
                [theApp.pages jumpToPage:@"TOUR" withContext:ctx];
                break;
            case MENU_OPTION_CUENTA:
                [theApp.pages jumpToPage:@"PROFILE" withContext:nil];
                break;
            case MENU_OPTION_SALIR:
                [theApp showBlockView];
                [WSDataManager logOut:^(int code, NSDictionary *result, NSDictionary * badges) {
                    [theApp hideBlockView];
                    [theApp.appSession loggedOut];
                    PageContext * ctx = [[PageContext alloc] init];
                    [ctx addParam:@"STANDALONE" withValue:@"1"];
                    [theApp.pages jumpToPage:@"LOGIN" withContext:ctx];
                }];
                break;
            case MENU_OPTION_BACK:
                [theApp.pages goBack];
                break;
        }
    }];
    [self.pageView addSubview:_menu];
    
    self.contentView = _menu.contentView;

    /* NO
    if (theApp.appSession.curPlayerInfo) {
        _menu.lblLogo.text = theApp.appSession.curPlayerInfo.userName;
    } else {
        _menu.lblLogo.text = @"";
    }*/
}

// Sobrecargada para que lo añada en el content
-(UIView *) loadNIB:(NSString *)nibName {
    // Ponemos la vista con el contenido, ajustando tamaño, fondo y demás...
    CGRect posRect = CGRectMake(0,0,self.contentView.frame.size.width, self.contentView.frame.size.height);
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    UIView * myView = nibViews[0];
    myView.backgroundColor = [UIColor clearColor];
    myView.frame = posRect;
    [self.contentView addSubview:myView];
    return myView;
}

-(void)refreshLblLogo {
    /*
    if (theApp.appSession.curPlayerInfo) {
        _menu.lblLogo.text = theApp.appSession.curPlayerInfo.userName;
    } else {
        _menu.lblLogo.text = @"";
    }*/
}

@end





