//
//  PageEngine.m
//  ViewTransitions
//
//  Created by Javier Garcés González on 07/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "PageEngine.h"
#import "Page.h"
#import "PageHistoryItem.h"
#import "PageTransition.h"

#import <QuartzCore/QuartzCore.h>

@implementation PageEnginePreloadData
@synthesize page;
@synthesize pageName;
@synthesize pageContext;
@synthesize trans;
@synthesize backTrans;
@synthesize goingBack;
@synthesize ignoreHistory;
@end

#define HISTORY_PAGEVIEW_TIMEOUT        (30 * 60 * 1000) // 30 minutos
#define HISTORY_PAGEVIEW_CACHE          10


@implementation PageEngine

@synthesize cachePages;


- (id)initWithView:(UIView *)cView;
{
    if (self = [super init]) {
        containerView = cView;
        pages = [[NSMutableDictionary alloc] initWithCapacity:100 ];
        history = [[NSMutableArray alloc] initWithCapacity:100 ];
        oldPage = nil;
        curPage = nil;
        transitioning = NO;
        jumping = NO;
        endJumpingDelayed = NO;
        preloading = nil;
        curView = nil;
        oldView = nil;
        cachePages = YES;
        return self;
    } else {
        return nil;
    }
}

- (UIView *) mainView
{
	return containerView;
}

- (UIViewController *) mainController
{
	return containerController;
}


- (BOOL)addPage: (Page *)page withName: (NSString *)pageName
{
	if (pages[pageName] != nil)
		return NO;
	
	page.owner = self;
	page.pageName = pageName;
	
    pages[pageName] = page;
	return YES;
}

- (Page *)getCurPage {
    return curPage;
}

- (void)jumpToPage:(NSString *)newPageName withContext: (PageContext *)context;
{
    [self jumpToPage:newPageName withContext:context withTransition: nil andBackTransition: nil ignoreHistory: NO];
}

- (void)jumpToPage:(NSString *)newPageName withContext:(PageContext *)context withTransition: (PageTransition *)trans andBackTransition: (PageTransition *)backTrans ignoreHistory:(BOOL)ignoreHistory
{
	// Si ya estamos saltando, no volvemos a saltar...
	if (jumping == YES)
		return;
	
	jumping = YES;
    preloading = nil;
    
    // Si no hay context, creamos uno vacío
    if (context == nil)
        context = [[PageContext alloc] init];
    
    NSLog(@"JUMP TO PAGE: %@", newPageName);
    
    // Miramos la página a la que saltar
    Page * page = (Page *)pages[newPageName];
    if (page == nil) { // Si no había página
        jumping = NO;
        NSLog(@"JUMP TO PAGE - PAGE DOES NOT EXIST: %@", newPageName);
        return;
    }
    
    // Creamos una página nueva
    Page * newPage = [page newPage];
    if (newPage != nil) {
        newPage.pageName = page.pageName;
        newPage.owner = self;
        page = newPage;
    }
    
    page._context = context;
    if ([page onPreloadPage: context] == YES) {
        preloading = [[PageEnginePreloadData alloc] init];
        preloading.goingBack = NO;
        preloading.page = page;
        preloading.pageName = newPageName;
        preloading.pageContext = context;
        preloading.trans = trans;
        preloading.backTrans = backTrans;
        preloading.ignoreHistory = ignoreHistory;
        return;
    }
    
    [self endJumpToPage: page withPageName: newPageName withContext: context withTransition: trans andBackTransition: backTrans ignoreHistory: ignoreHistory];
}

- (void)endJumpToPage:(Page *)page withPageName: (NSString *)pageName withContext:(PageContext *)context withTransition: (PageTransition *)trans andBackTransition: (PageTransition *)backTrans ignoreHistory:(BOOL)ignoreHistory
{

	// Salimos de la página actual
	if (curPage != nil)
	{
		// Dejamos la página actual
        PageContext * ctx = [curPage onLeavePage: pageName];
        if (ctx  != PAGE_HISTORY_NOHISTORY && ignoreHistory == NO) {
            // Procedemos a crear el item del histórico
            PageHistoryItem * hItem = [[PageHistoryItem alloc] init];
            hItem.pageName = curPage.pageName;
            hItem.pageContext = ctx;
            hItem.pageTransition = backTrans;
            // Miramos guardar la info de caché...
            if (cachePages && ctx.cachePage) {
                PageHistoryItemCacheInfo * cinfo = [[PageHistoryItemCacheInfo alloc] init];
                cinfo.view = curView;
                cinfo.page = curPage;
                cinfo.timestamp = [[NSDate date] timeIntervalSince1970];
                hItem.cache = cinfo;
            }
            // Limpiamos la caché del histórico, para on sobrecargarlo
            [self clearHistoryCache];
            // Añadimos al histórico el item
            [history addObject:hItem];
        }
	}

    [self swapViews:page withContext: context andTransition: trans];
}

- (void)goBack
{
	// Si ya estamos saltando, no volvemos a saltar...
	if (jumping == YES)
		return;
	
	if (history.count > 0)
	{
        jumping = YES;
        
        NSLog(@"GOING BACK");
        
        // Pregunamos si queremos volver realmente
        if (curPage != nil) {
            if ([curPage onQueryVolver] == NO) {
                jumping = NO;
                return;
            }
        }
        
		// Obtengo el último elemento del array y lo quito
		PageHistoryItem * item = (PageHistoryItem *) [history lastObject];
        
        PageHistoryItemCacheInfo * cinfo = item.cache;
        if (cinfo != nil) {
            Page * page = cinfo.page;
            PageContext * context = [item.pageContext clone];
            [context addParam:PARAM_ONBACK withValue:@"1"];
            
            
            // Aquí sí que ya podemos proceder a eliminar del histórico el elemento
            [history removeLastObject];
            [self swapViewsWithView:page withView: cinfo.view withContext:context andTransition:item.pageTransition];
            [item cleanUpCache];
        } else {
		
            // Hacemos el cambio de página
            Page * page = (Page *)pages[item.pageName];
            if (page == nil) { // Si no había página... no debería pasar nunca
                jumping = NO;
                return;
            }
		
            Page * newPage = [page newPage];
            if (newPage != nil) {
                newPage.pageName = page.pageName;
                newPage.owner = self;
                page = newPage;
            }
            
            PageContext * context;
            if (item.pageContext == nil) {
                context = [[PageContext alloc] init];
            } else {
                context = [item.pageContext clone];
            }
            [context addParam:PARAM_ONBACK withValue: @"1"];
            page._context = context;
            if ([page onPreloadPage:context]) {
                preloading = [[PageEnginePreloadData alloc] init];
                preloading.goingBack = YES;
                preloading.page = page;
                preloading.pageName = PAGENAME_ONBACK;
                preloading.pageContext = context;
                preloading.trans = item.pageTransition;
                preloading.backTrans = item.pageTransition;
                preloading.ignoreHistory = NO;
                return;
            }
            [self endGoBack: page withContext: context andTransition: item.pageTransition];
        }
	}
}

-(void) endGoBack: (Page * )page withContext: (PageContext * )context andTransition: (PageTransition *)trans
{
    [history removeLastObject];
    if (curPage != nil) {
        [curPage onLeavePage:PAGENAME_ONBACK];
    }
    
    [self swapViews: page withContext: context andTransition: trans];
}

-(void) swapViews: (Page *)page withContext: (PageContext *)context andTransition: (PageTransition *) trans
{
    // Creamos la nueva vista para esta página
    UIView * newView = [[UIView alloc] initWithFrame: CGRectMake(0,0,containerView.bounds.size.width, containerView.bounds.size.height)];
    // Por defecto, no dejamos interactuar con la vista (hasta que haya acabado la transición)
    newView.userInteractionEnabled = NO;
    // Habilito el clipping para la capa
    newView.clipsToBounds = YES;
    // Oculto la capa para poder realizar el efecto en cuestión...
    newView.hidden = YES;
    // Añadimos la nueva capa a la pantalla
    [containerView addSubview:newView];
    
    // Inicializamos la página, pasándole el context
    page.pageView = newView;
    [page onEnterPage:context];
    // Indicamos que va a comenzar la transición
    [page onTransitionPage];
    
    // Asignamos como página actual la nueva
    oldPage = curPage;
    curPage = page;
    
    // Reasigno las vistas...
    oldView = curView;
    curView = newView;
    
    // Hacemos el salto interno...
    [self doTransition: trans];
    
    // Y listo!!!
}

-(void) swapViewsWithView: (Page *)page withView: (UIView *)view withContext: (PageContext *)context andTransition: (PageTransition *) trans
{
    // Creamos la nueva vista para esta página
    UIView * newView = view;
    // Por defecto, no dejamos interactuar con la vista (hasta que haya acabado la transición)
    newView.userInteractionEnabled = NO;
    // Habilito el clipping para la capa
    newView.clipsToBounds = YES;
    // Oculto la capa para poder realizar el efecto en cuestión...
    newView.hidden = YES;
    // Añadimos la nueva capa a la pantalla
    [containerView addSubview:newView];
    
    // Inicializamos la página, pasándole el context (cuidado! como está reciclada, llamamos a Recycle, no EnterPage)
    page.pageView = newView;
    [page onRecyclePage: context];
    // Indicamos que va a comenzar la transición
    [page onTransitionPage];
    
    // Asignamos como página actual la nueva
    oldPage = curPage;
    curPage = page;
    
    // Reasigno las vistas...
    oldView = curView;
    curView = newView;
    
    // Hacemos el salto interno...
    [self doTransition: trans];
    
    // Y listo!!!
}

-(void) endPreloadingPage: (BOOL) result
{
    if (preloading == nil)
        return;
    
    if (result) { // Si la cosa ha ido bien, continuamos...
        if (preloading.goingBack == YES) {
            [self endGoBack:preloading.page withContext:preloading.pageContext andTransition:preloading.trans];
        } else {
            [self endJumpToPage:preloading.page withPageName:preloading.pageName withContext: preloading.pageContext withTransition: preloading.trans andBackTransition: preloading.backTrans ignoreHistory:preloading.ignoreHistory];
        }
    } else { // Abortamos
        jumping = NO;
    }
    preloading = nil;
}

-(void) clearHistoryCache {
    for (int i=0;i<history.count;i++) {
        PageHistoryItem * item = history[i];
        if (item.cache != nil) {
            PageHistoryItemCacheInfo * cinfo = item.cache;
            // Si hace más de media hora o hay más de HISTORY_PAGEVIEW_CACHE elementos en el histórico, me lo cargo...
            if (([[NSDate date] timeIntervalSince1970] - cinfo.timestamp) > HISTORY_PAGEVIEW_TIMEOUT || i > HISTORY_PAGEVIEW_CACHE) {
                [item cleanUpCache];
            }
        }
    }
}

-(void) invalidateHistoryCache
{
    for (int i=0;i<history.count;i++) {
        PageHistoryItem * item = history[i];
        if (item.cache != nil) {
            PageHistoryItemCacheInfo * cinfo = item.cache;
            [item cleanUpCache];
        }
    }
}

- (void)forEachItemInHistory:(onEachHistoryItem) onEachItem {
    for (int i=0;i<history.count;i++) {
        PageHistoryItem * item = history[i];
        onEachItem(self, item);
    }
}



- (NSInteger) historyCount
{
	return [history count];
}

- (void)clearHistory
{
	history = [[NSMutableArray alloc] initWithCapacity:100 ];
}

- (BOOL) canGoBack
{
    if ([history count] > 0)
        return YES;
    else
        return NO;
}

- (void)doTransition: (PageTransition *) trans
{
	// Nos aseguramos de tener transición, aunque sea "ninguna"
	if (trans == nil)
		trans = [PageTransition noTransition];
	// Hacemos la transición si la hay...
	transitioning = YES;
	if (oldView != nil) // Si tiene transición y proviene de otra página anterior
	{
		[trans setDelegate: self];
		[trans transitionFor:containerView fromView: oldView toView: curView ];
		
	}
	else // Lo hacemos a pelo (generalmente para el primer caso...)
	{
		if (oldView != nil)
			oldView.hidden = YES;
		curView.hidden = NO;
		
		// llamamos a animationDidStop para que resuelva el cambio de vistas
		[self animationDidStop:nil finished:YES];
	}
	
}

- (void)doTransitionBack: (PageTransition *) trans
{
	// Nos aseguramos de tener transición, aunque sea "ninguna"
	if (trans == nil)
		trans = [PageTransition noTransition];
	// Hacemos la transición si la hay...
	transitioning = YES;

	[trans setDelegate: self];
	[trans transitionFor:containerView fromView: oldView toView: curView ];
	
}

// Evento al que se llama cuando acaba la animación/transición de una página a otra...
-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	// Hemos acabado la transición
	transitioning = NO;
	if (oldView != nil)
	{
		// Quitamos la vista de la supervista, ahora que ya no es visible
		[oldView removeFromSuperview];
	}

	// Activamos la nueva página (y acabamos el salto) si no se ha
	// diferido la activación hasta que la página considere oportuno
	if (endJumpingDelayed == NO)
	{
		NSLog(@"Activamos página %@", curPage.pageName);
		// Indicamos que ha acabado el salto
		jumping = NO;
		// Activamos la nueva vista
		curView.userInteractionEnabled = YES;
	}

	// Enviamos el evento de visible a la página
    [curPage onShowPage];

}

- (void)delayEndJumping
{
	endJumpingDelayed = YES;
}

- (void)endJumping
{
	// Deshabilitamos el endJumpingDelayed
	endJumpingDelayed = NO;
	
	// Si ya hemos acabado la transición, entonces procedemos a
	// "cerrar el asunto".
	// Si la transición todavía está en progreso, entonces será
	// cuando acabe ésta que se "activará" la página.
	if (transitioning == NO)
	{
		NSLog(@"Activamos página diferida %@", curPage.pageName);
		// Indicamos que ha acabado el salto
		jumping = NO;
		// Activamos la nueva vista
		curView.userInteractionEnabled = YES;
		
	}
}



// Para el manejo de la resolución
+ (BOOL) isHiResDevice
{
	BOOL isHD = NO;
	
	if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) //iPad and iPhone 4
	{
		//NSLog(@"Responde a scale: %f", [[UIScreen mainScreen] scale]);
		if([[UIScreen mainScreen] scale] == 2)
		{
			isHD = YES;
		}
	}

	//NSLog(@"Device model: %@", [[UIDevice currentDevice] model]);
	
	return isHD;
}

+ (BOOL )isIPadDevice
{
	// Miramos si es iPad (sólo si está definida la coña marinera...
	// Atención: ninguno de los dos métodos funciona en el iPad simulator, que
	// siempre indica que se está ejecutando en un iPhone, por lo que nunca se
	// detecta el verdadero dispositivo.
	#ifdef UI_USER_INTERFACE_IDIOM
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return YES;
	#endif
	/* Método alternativo, quizás mejor aún que el anterior
	 if([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound)
		return YES;
	 */
	return NO;
}

+ (NSString *) deviceSpecificName: (NSString *)name ofType: (NSString *) ext
{
	BOOL isHD = [PageEngine isHiResDevice];
	if (isHD == YES)
		return [NSString stringWithFormat:@"%@-hd.%@", name, ext];
	else
		return [NSString stringWithFormat:@"%@.%@", name, ext];
}

+ (NSString *) deviceSpecificName: (NSString *)name ofType: (NSString *) ext needHiRes: (BOOL) hd
{
	if (hd == YES)
		return [NSString stringWithFormat:@"%@-hd.%@", name, ext];
	else
		return [NSString stringWithFormat:@"%@.%@", name, ext];
}



+ (UIImage *) loadImageFromFile: (NSString *)fileName  ofType: (NSString *) ext
{
	NSString * realFileName = [self deviceSpecificName: fileName ofType: ext];
	BOOL isHD = [PageEngine isHiResDevice];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:realFileName];
	if (isHD == YES && fileExists == YES) // Si estamos en alta resolución y existe el fichero...
	{
		// Cargamos la imagen, aplicamos el escalado, si es necesario
		UIImage * image = [UIImage imageNamed:realFileName];
		image = [UIImage imageWithCGImage: image.CGImage scale:2 orientation:image.imageOrientation];
		return image;
	}
	else // Si no estamos en alta resolución o no hay versión del archivo en alta resolución
	{
		if (isHD == YES) // Si estábamos en alta resolución, obtenemos el nombre del archivo "normal"
			realFileName = [self deviceSpecificName: fileName ofType: ext needHiRes: NO];
		UIImage * image = [UIImage imageNamed:realFileName];
		return image;
	}
}

+ (UIImage *) loadImageFromMainBundle: (NSString *)resName ofType: (NSString *) ext
{
	NSString * realFileName;
	BOOL isHD = [PageEngine isHiResDevice];
	if (isHD == YES)
	{
		realFileName = [NSString stringWithFormat:@"%@-hd", resName];
	}
	else
	{
		realFileName = [NSString stringWithFormat:@"%@", resName];
	}
	NSString * realFilePath = [[NSBundle mainBundle] pathForResource:realFileName ofType:ext];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:realFilePath];
	if (isHD == YES && fileExists == YES) // Si estamos en alta resolución y existe el fichero...
	{
		// Cargamos la imagen, aplicamos el escalado, si es necesario
		UIImage * image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:realFileName ofType:ext]];
		image = [UIImage imageWithCGImage: image.CGImage scale:2 orientation:image.imageOrientation];
		return image;
	}
	else // Si no estamos en alta resolución o no hay versión del archivo en alta resolución
	{
		if (isHD == YES) // Si estábamos en alta resolución, obtenemos el nombre del archivo "normal"
			realFileName = [NSString stringWithFormat:@"%@", resName];
		UIImage * image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:realFileName ofType:ext]];
		return image;
	}
}

+ (UIImage *) loadImageFromData: (NSData *)data
{
	BOOL isHD = [PageEngine isHiResDevice];
	UIImage * image = [UIImage imageWithData:data ];

	if (isHD == YES)
		image = [UIImage imageWithCGImage: image.CGImage scale:2 orientation:image.imageOrientation];

	return image;
}

+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible
{
    static NSInteger NumberOfCallsToSetVisible = 0;
    if (setVisible) 
        NumberOfCallsToSetVisible++;
    else 
        NumberOfCallsToSetVisible--;
	
    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error, 
    // it should probably be removed from production code.
    NSAssert(NumberOfCallsToSetVisible >= 0, @"Network Activity Indicator was asked to hide more often than shown");
    
    // Display the indicator as long as our static counter is > 0.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(NumberOfCallsToSetVisible > 0)];
}



+(UIViewController *) firstAvailableUIViewController: (UIView *) view
{
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[PageEngine traverseResponderChainForUIViewController: view];
}

+(id) traverseResponderChainForUIViewController: (UIView *)view
{
    id nextResponder = [view nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [PageEngine traverseResponderChainForUIViewController: nextResponder];
    } else {
        return nil;
    }
}


// Eventos globales que se traspasan a la página actual
-(void) onDeactivate
{
    if (curPage != nil)
        [curPage onDeactivate];
}

-(void) onActivate
{
    if (curPage != nil)
        [curPage onActivate];
}


@end
