//
//  PageEngine.h
//  ViewTransitions
//
//  Created by Javier Garcés González on 07/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Page.h"

@class Page;
@class PageTransition;
@class PageHistoryItem;

@interface PageEnginePreloadData: NSObject {
    Page * page;
    NSString * pageName;
    PageContext * pageContext;
    PageTransition * trans;
    PageTransition * backTrans;
    BOOL goingBack;
    BOOL ignoreHistory;
}
@property Page * page;
@property NSString * pageName;
@property PageContext * pageContext;
@property PageTransition * trans;
@property PageTransition * backTrans;
@property BOOL goingBack;
@property BOOL ignoreHistory;

@end

#define PAGENAME_ONBACK     @"__BACK"
#define PARAM_ONBACK        @"isBack"

typedef void (^onEachHistoryItem)(PageEngine * engine, PageHistoryItem * item);

@interface PageEngine : NSObject {

	// Vista contenedora de las páginas
	UIView * containerView;
	UIViewController * containerController;
	
	// Indicador de si estamos en medio de una transición
	BOOL jumping;
	BOOL endJumpingDelayed;
	BOOL transitioning;
    PageEnginePreloadData * preloading;
	
	// Datos propios
	NSMutableDictionary * pages;
	NSMutableArray * history;
	Page * oldPage;
	Page * curPage;
	
	// Vistas
	UIView * curView;
	UIView * oldView;
    
    BOOL cachePages;
}

@property (assign, nonatomic) BOOL cachePages;

// Inicialización de la clase
- (id)initWithView:(UIView *)cView;

// obtener el controlador "general" de las páginas
- (UIView *) mainView;
- (UIViewController *) mainController;

// Adición de nuevas páginas a la vista
- (BOOL)addPage: (Page *)page withName: (NSString *)pageName;

// obtener página actual
- (Page *)getCurPage;

// Navegación por las páginas
- (void)jumpToPage:(NSString *)newPageName withContext: (PageContext *)context;
- (void)jumpToPage:(NSString *)newPageName withContext:(PageContext *)context withTransition: (PageTransition *)trans andBackTransition: (PageTransition *)backTrans ignoreHistory:(BOOL)ignoreHistory;
- (void)goBack;
- (NSInteger) historyCount;
- (void)clearHistory;
- (void)invalidateHistoryCache;
- (void)forEachItemInHistory:(onEachHistoryItem) onEachItem;
- (BOOL) canGoBack;
-(void) endPreloadingPage: (BOOL) result;

// Control de cuándo se activa una página tras un salto a ésta.
// Permite que no haya interacción con la página hasta después de que ésta,
// si tiene eventos diferidos, haya realmente acabado de cargarse
- (void)delayEndJumping;
- (void)endJumping;

// Métodos privados (please, don't use...)
- (void)doTransition: (PageTransition *)trans;
- (void)doTransitionBack: (PageTransition *)trans;

// Para el manejo de la resolución
+ (BOOL) isHiResDevice;
+ (BOOL) isIPadDevice;
+ (NSString *) deviceSpecificName: (NSString *)name ofType: (NSString *) ext;
+ (NSString *) deviceSpecificName: (NSString *)name ofType: (NSString *) ext needHiRes: (BOOL) hd;
+ (UIImage *) loadImageFromFile: (NSString *)fileName ofType: (NSString *) ext;
+ (UIImage *) loadImageFromMainBundle: (NSString *)resName ofType: (NSString *) ext;
+ (UIImage *) loadImageFromData: (NSData *)data;

// Para indicar actividad en la red (cuando descargamos cosas, por ejemplo)
+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible;

// Obtención del Controller más próximo a una UIView
+(UIViewController *) firstAvailableUIViewController: (UIView *) view;
+(id) traverseResponderChainForUIViewController: (UIView *)view;

// Eventos globales que se traspasan a la página actual
-(void) onDeactivate;
-(void) onActivate;

@end
