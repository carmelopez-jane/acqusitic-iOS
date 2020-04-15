//
//  Page.h
//  ViewTransitions
//
//  Created by Javier Garcés González on 07/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "PageContext.h"

@class PageEngine;
@class PageTransition;

#define PAGE_HISTORY_NOHISTORY      nil

@interface Page : UIViewController {

	// PageEngine propietario...
	PageEngine * owner;
	
	// Nombre de la página actual
	NSString * pageName;
	
	// Vista de la página (no la retiene)
	UIView * pageView;
	
}

@property PageEngine * owner;
@property NSString * pageName;
@property UIView * pageView;
@property PageContext * _context;


-(id) init;

-(BOOL) onPreloadPage:(PageContext *)context;
-(void) onEnterPage:(PageContext *)context;
-(void) onRecyclePage:(PageContext *)context;
-(void) onShowPage;
-(PageContext *)onLeavePage:(NSString *)destPage;
-(void) onTransitionPage;
-(void) onDeactivate;
-(void) onActivate;
-(BOOL) onQueryVolver;

-(Page *) newPage;
-(void) endPreloading:(BOOL)success;

@end
