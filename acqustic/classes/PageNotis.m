//
//  PageNotis.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageNotis.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Noti.h"
#import "Notification.h"
#import "PerformanceGroup.h"
#import "WSDataManager.h"
#import "FormItemHeader.h"
#import "FormItemSep.h"
#import "FormItemSepfull.h"
#import "Utils.h"

@interface PageNotis ()

@end

#define TAB_NOTIS     1
#define TAB_INPROGRESS         2
#define TAB_WON                 3

@implementation PageNotis

@synthesize vHeader, svContent, tabNotifications, tabInprogress, tabWon;

-(BOOL) onPreloadPage:(PageContext *)context {
    [theApp showBlockView];
    PageNotis * refThis = self;
    [WSDataManager getAllNotifications:^(int code, NSDictionary *result, NSDictionary * badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [self setBadges:badges];
            self->notis = [[NSMutableArray alloc] init];
            NSArray * nData = result[@"notifications"];
            for (int i=0;i<nData.count;i++) {
                Notification * n = [[Notification alloc] initWithDictionary:nData[i]];
                [self->notis addObject:n];
            }
            self->won = [[NSMutableArray alloc] init];
            self->history = [[NSMutableArray alloc] init];
            nData = result[@"history"];
            NSInteger now = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
            for (int i=0;i<nData.count;i++) {
                PerformanceGroup * pg = [[PerformanceGroup alloc] initWithDictionary:nData[i]];
                if (![refThis inNotis:pg.performance_id]) {// Si no está en la sección de notificaciones...
                    if (pg.performance_date < now)
                        [self->history addObject:pg];
                    else
                        [self->won addObject:pg];
                }
            }
            self->inprogress = [[NSMutableArray alloc] init];
            nData = result[@"performances"];
            for (int i=0;i<nData.count;i++) {
                PerformanceGroup * pg = [[PerformanceGroup alloc] initWithDictionary:nData[i]];
                if (![refThis inNotis:pg.performance_id] && ![refThis inWon:pg.performance_id]) // Si no está en la sección de notificaciones...
                    [self->inprogress addObject:pg];
            }
            [refThis endPreloading:YES];
        } else {
            [theApp stdError:code];
            [refThis endPreloading:NO];
        }
    }];
    return YES;
}

-(void)onEnterPage:(PageContext *)context{
    
    [super onEnterPage:context];

    [self loadNIB:@"PageNotis"];

    _ctx = context;

    [self.vHeader setActiveSection:HEADER_SECTION_NOTIS];
    [self setupBadges:vHeader];
    
    [tabNotifications setSelected:YES];
    
    int tabWidth = self.svContent.frame.size.width / 3;
    int lastTabWidth = tabWidth;
    if (tabWidth*3 < self.svContent.frame.size.width)
        lastTabWidth = self.svContent.frame.size.width-2*tabWidth;
    CGRect fr = tabNotifications.frame;
    fr.origin.x = 0; fr.size.width = tabWidth;
    tabNotifications.frame = fr;
    fr = tabInprogress.frame;
    fr.origin.x = tabWidth; fr.size.width = tabWidth;
    tabInprogress.frame = fr;
    fr = tabWon.frame;
    fr.origin.x = 2*tabWidth; fr.size.width = lastTabWidth;
    tabWon.frame = fr;

    [Utils setOnClick:tabNotifications withBlock:^(UIView *sender) {
        [self.tabNotifications setSelected:YES];
        [self.tabInprogress setSelected:NO];
        [self.tabWon setSelected:NO];
        self->activeTab = TAB_NOTIS;
        [self fillInNotifications];
    }];
    [Utils setOnClick:tabInprogress withBlock:^(UIView *sender) {
        [self.tabNotifications setSelected:NO];
        [self.tabInprogress setSelected:YES];
        [self.tabWon setSelected:NO];
        self->activeTab = TAB_INPROGRESS;
        [self fillInInprogress];
    }];
    [Utils setOnClick:tabWon withBlock:^(UIView *sender) {
        [self.tabNotifications setSelected:NO];
        [self.tabInprogress setSelected:NO];
        [self.tabWon setSelected:YES];
        self->activeTab = TAB_WON;
        [self fillInWon];
    }];
    
    activeTab = TAB_NOTIS;
    [self fillInNotifications];
 
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor blackColor];
    refreshControl.attributedTitle = nil;
    [refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [svContent addSubview:refreshControl];
    svContent.alwaysBounceVertical = YES;

}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    PageContext * ctx = [_ctx clone];
    ctx.cachePage = YES;
    return ctx;
}

-(void) onRecyclePage:(PageContext *)context {
    [self refreshAll:YES refreshControl:nil];
}

-(void) onActivate {
    [self refresh];
}

-(BOOL) inNotis:(NSInteger)performanceId {
    for (int i=0;i<notis.count;i++) {
        Notification * n = notis[i];
        NSInteger npid = [n.param1 integerValue];
        if ([n.type isEqualToString:NOTI_PERFORMANCE_CANDIDATE] || ([n.type isEqualToString:NOTI_PERFORMANCE_SELECTED] && npid == performanceId))
            return YES;
    }
    return NO;
}

-(BOOL) inWon:(NSInteger) performanceId {
    for (int i=0;i<won.count;i++) {
        PerformanceGroup * pg = won[i];
        if (pg.performance_id == performanceId)
            return YES;
    }
    return NO;
}

-(void) refresh {
    [self refreshAll:YES refreshControl:nil];
}

- (void)onRefresh:(UIRefreshControl *)refreshControl
{
    [self refreshAll:NO refreshControl:refreshControl];
}

-(void) refreshAll:(BOOL) setWaitMode refreshControl:(UIRefreshControl *)refreshControl {
    PageNotis * refThis = self;
    if (setWaitMode)
        [theApp showBlockView];
    [WSDataManager getAllNotifications:^(int code, NSDictionary *result, NSDictionary *badges) {
        if (setWaitMode)
            [theApp hideBlockView];
        if (refreshControl)
            [refreshControl endRefreshing];
        if (code == WS_SUCCESS) {
            [self setBadges:badges];
            [self setupBadges:self.vHeader];
            [self->notis removeAllObjects];
            [self->inprogress removeAllObjects];
            [self->won removeAllObjects];
            [self->history removeAllObjects];
            NSArray * nData = result[@"notifications"];
            for (int i=0;i<nData.count;i++) {
                Notification * n = [[Notification alloc] initWithDictionary:nData[i]];
                [self->notis addObject:n];
            }
            nData = result[@"history"];
            NSInteger now = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
            for (int i=0;i<nData.count;i++) {
                PerformanceGroup * pg = [[PerformanceGroup alloc] initWithDictionary:nData[i]];
                if (![refThis inNotis:pg.performance_id]) { // Si no está en la sección de notificaciones...
                    if (pg.performance_date < now)
                        [self->history addObject:pg];
                    else
                        [self->won addObject:pg];
                }
            }
            nData = result[@"performances"];
            for (int i=0;i<nData.count;i++) {
                PerformanceGroup * pg = [[PerformanceGroup alloc] initWithDictionary:nData[i]];
                if (![refThis inNotis:pg.performance_id] && ![refThis inWon:pg.performance_id]) // Si no está en la sección de notificaciones...
                    [self->inprogress addObject:pg];
            }
            if (self->activeTab == TAB_NOTIS)
                [self fillInNotifications];
            else if (self->activeTab == TAB_INPROGRESS)
                [self fillInInprogress];
            else if (self->activeTab == TAB_WON)
                [self fillInWon];
        }
    }];
}

-(void) fillInNotifications {
    [Utils cleanUpScrollView:self.svContent];
    int yTop = 0;
    // Añadimos la cabecera
    FormItemHeader * header = [[FormItemHeader alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.width, 55)];
    header.ivIcon.hidden = YES; header.vIcon.hidden = YES;
    header.lblLabel.text = @"Notificaciones pendientes";
    [svContent addSubview:header];
    yTop += header.frame.size.height;
    FormItemSepFull * sep = [[FormItemSepFull alloc] initWithFrame:CGRectMake(15,yTop,self.svContent.frame.size.width-30, 1)];
    [svContent addSubview:sep];
    yTop++;
    // Añadimos las notificaciones
    for (int i=0;i<notis.count;i++) {
        Noti * item = [[Noti alloc] initWithFrame:CGRectMake(0,yTop, self.svContent.frame.size.width, 100)];
        [self fillInNotification:item noti:notis[i]];
        [svContent addSubview:item];
        yTop += item.frame.size.height;
    }
    svContent.contentSize = CGSizeMake(0, yTop+20);
}

-(void) fillInInprogress {
    [Utils cleanUpScrollView:self.svContent];
    int yTop = 0;
    // Añadimos la cabecera
    FormItemHeader * header = [[FormItemHeader alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.width, 55)];
    header.ivIcon.hidden = YES; header.vIcon.hidden = YES;
    header.lblLabel.text = @"Preselecciones activas";
    [svContent addSubview:header];
    yTop += header.frame.size.height;
    FormItemSepFull * sep = [[FormItemSepFull alloc] initWithFrame:CGRectMake(15,yTop,self.svContent.frame.size.width-30, 1)];
    [svContent addSubview:sep];
    yTop++;
    // Añadimos las notificaciones
    for (int i=0;i<inprogress.count;i++) {
        Noti * item = [[Noti alloc] initWithFrame:CGRectMake(0,yTop, self.svContent.frame.size.width, 100)];
        [self fillInPendingPerformance:item perf:inprogress[i]];
        [svContent addSubview:item];
        yTop += item.frame.size.height;
    }
    svContent.contentSize = CGSizeMake(0, yTop+20);
}

-(void) fillInWon {
    [Utils cleanUpScrollView:self.svContent];
    int yTop = 0;
    // Añadimos la cabecera
    FormItemHeader * header = [[FormItemHeader alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.width, 55)];
    header.ivIcon.hidden = YES; header.vIcon.hidden = YES;
    header.lblLabel.text = @"Mis próximos conciertos";
    [svContent addSubview:header];
    yTop += header.frame.size.height;
    FormItemSepFull * sep = [[FormItemSepFull alloc] initWithFrame:CGRectMake(15,yTop,self.svContent.frame.size.width-30, 1)];
    [svContent addSubview:sep];
    yTop++;
    // Añadimos las notificaciones
    for (int i=0;i<won.count;i++) {
        Noti * item = [[Noti alloc] initWithFrame:CGRectMake(0,yTop, self.svContent.frame.size.width, 100)];
        [self fillInHistoryPerformance:item perf:won[i]];
        [svContent addSubview:item];
        yTop += item.frame.size.height;
    }
    // Añadimos la cabecera
    header = [[FormItemHeader alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.width, 55)];
    header.ivIcon.hidden = YES; header.vIcon.hidden = YES;
    header.lblLabel.text = @"Historial";
    [svContent addSubview:header];
    yTop += header.frame.size.height;
    sep = [[FormItemSepFull alloc] initWithFrame:CGRectMake(15,yTop,self.svContent.frame.size.width-30, 1)];
    [svContent addSubview:sep];
    yTop++;
    // Añadimos las notificaciones
    for (int i=0;i<history.count;i++) {
        Noti * item = [[Noti alloc] initWithFrame:CGRectMake(0,yTop, self.svContent.frame.size.width, 100)];
        [self fillInHistoryPerformance:item perf:history[i]];
        [svContent addSubview:item];
        yTop += item.frame.size.height;
    }
    svContent.contentSize = CGSizeMake(0, yTop+20);
}

-(void) fillInNotification:(Noti *)item noti:(Notification *) noti {
    //UIUtils.setText(item, R.id.tv_date, StringUtils.formatDateRelativeOneLine(noti.created_at));
    PageNotis * refThis = self;
    if ([noti.type isEqualToString:NOTI_PROFILE_SHARE_PERMISSIONS_REQUESTED]) {
        [item setNotification:noti.message date:noti.created_at button1:@"Confirmar" button2:@"Denegar"];
        [Utils setOnClick:item.btnAction1 withBlock:^(UIView *sender) {
            [refThis onRequestSharePermissionConfirm:item noti:noti];
        }];
        [Utils setOnClick:item.btnAction2 withBlock:^(UIView *sender) {
            [refThis onRequestSharePermissionDeny:item noti:noti];
        }];
    } else if ([noti.type isEqualToString:NOTI_PROFILE_SHARE_PERMISSIONS_CONFIRMED]) {
        [item setNotification:noti.message date:noti.created_at button:@"Aceptar"];
        [Utils setOnClick:item.btnAction1 withBlock:^(UIView *sender) {
            [refThis onMarkAsDone:item noti:noti];
        }];
    } else if ([noti.type isEqualToString:NOTI_PROFILE_SHARE_PERMISSIONS_DENIED]) {
        [item setNotification:noti.message date:noti.created_at button:@"Aceptar"];
        [Utils setOnClick:item.btnAction1 withBlock:^(UIView *sender) {
            [refThis onMarkAsDone:item noti:noti];
        }];
    } else if ([noti.type isEqualToString:NOTI_GROUP_SHARE_PERMISSIONS_REQUESTED]) {
        [item setNotification:noti.message date:noti.created_at button1:@"Confirmar" button2:@"Denegar"];
        [Utils setOnClick:item.btnAction1 withBlock:^(UIView *sender) {
            [refThis onRequestShareGroupPermissionConfirm:item noti:noti];
        }];
        [Utils setOnClick:item.btnAction2 withBlock:^(UIView *sender) {
            [refThis onRequestShareGroupPermissionDeny:item noti:noti];
        }];
    } else if ([noti.type isEqualToString:NOTI_GROUP_SHARE_PERMISSIONS_CONFIRMED]) {
        [item setNotification:noti.message date:noti.created_at button:@"Aceptar"];
        [Utils setOnClick:item.btnAction1 withBlock:^(UIView *sender) {
            [refThis onMarkAsDone:item noti:noti];
        }];
    } else if ([noti.type isEqualToString:NOTI_GROUP_SHARE_PERMISSIONS_DENIED]) {
        [item setNotification:noti.message date:noti.created_at button:@"Aceptar"];
        [Utils setOnClick:item.btnAction1 withBlock:^(UIView *sender) {
            [refThis onMarkAsDone:item noti:noti];
        }];
    } else if ([noti.type isEqualToString:NOTI_PERFORMANCE_REGISTERED]) {
        // Esta no se muestra...
    } else if ([noti.type isEqualToString:NOTI_PERFORMANCE_CANDIDATE]) {
        [item setNotification:noti.message date:noti.created_at button:@"Ver oferta"];
        [Utils setOnClick:item.btnAction1 withBlock:^(UIView *sender) {
            // Actualizamos el perfil primero, por si ha cambiado el estado de la suscripción
            [WSDataManager getProfile:^(int code, NSDictionary *result, NSDictionary *badges) {
                if (code == WS_SUCCESS) {
                    [self setBadges:badges];
                    [self setupBadges:self.vHeader];
                    // Si está suscrito, seguimos. Si no, a suscripciones
                    if ([theApp.appSession isSubscribed]) {
                        PageContext * ctx = [[PageContext alloc] init];
                        [ctx addParam:@"performanceId" withValue:noti.param1];
                        [ctx addParam:@"groupId" withValue:noti.param4];
                        [ctx addParam:@"notificationId" withIntValue:noti._id];
                        [theApp.pages jumpToPage:@"PERFORMANCECONFIRMCANDIDATE" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
                    } else {
                        PageContext * ctx = [[PageContext alloc] init];
                        [ctx addParam:@"performanceId" withValue:noti.param1];
                        [ctx addParam:@"groupId" withValue:noti.param4];
                        [ctx addParam:@"notificationId" withIntValue:noti._id];
                        [theApp.pages jumpToPage:@"USERSUBSCRIPTION" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
                    }
                } else {
                    [theApp stdError:code];
                }
            }];
        }];
    } else if ([noti.type isEqualToString:NOTI_PERFORMANCE_SELECTED]) {
        [item setNotification:noti.message date:noti.created_at button:@"Ver oferta"];
        [Utils setOnClick:item.btnAction1 withBlock:^(UIView *sender) {
            // Actualizamos el perfil primero, por si ha cambiado el estado de la suscripción
            [WSDataManager getProfile:^(int code, NSDictionary *result, NSDictionary *badges) {
                if (code == WS_SUCCESS) {
                    [self setBadges:badges];
                    [self setupBadges:self.vHeader];
                    // Si está suscrito, seguimos. Si no, a suscripciones
                    if ([theApp.appSession isSubscribed]) {
                        PageContext * ctx = [[PageContext alloc] init];
                        [ctx addParam:@"performanceId" withValue:noti.param1];
                        [ctx addParam:@"groupId" withValue:noti.param4];
                        [ctx addParam:@"notificationId" withIntValue:noti._id];
                        [theApp.pages jumpToPage:@"PERFORMANCECONFIRMSELECTED" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
                    } else {
                        PageContext * ctx = [[PageContext alloc] init];
                        [ctx addParam:@"performanceId" withValue:noti.param1];
                        [ctx addParam:@"groupId" withValue:noti.param4];
                        [ctx addParam:@"notificationId" withIntValue:noti._id];
                        [theApp.pages jumpToPage:@"USERSUBSCRIPTION" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
                    }
                } else {
                    [theApp stdError:code];
                }
            }];
        }];
    } else if ([noti.type isEqualToString:NOTI_PERFORMANCE_CANCELLED]) {

    } else if ([noti.type isEqualToString:NOTI_PERFORMANCE_WON]) {

    } else if ([noti.type isEqualToString:NOTI_PERFORMANCE_LOST]) {

    } else if ([noti.type isEqualToString:NOTI_PLAYLIST_CANDIDATE]) {

    } else if ([noti.type isEqualToString:NOTI_PLAYLIST_SELECTED]) {

    } else if ([noti.type isEqualToString:NOTI_PLAYLIST_CANCELLED]) {

    } else if ([noti.type isEqualToString:NOTI_PLAYLIST_WON]) {

    } else if ([noti.type isEqualToString:NOTI_PLAYLIST_LOST]) {

    }
}

-(void) fillInPendingPerformance:(Noti *) item perf:(PerformanceGroup *)perf {
    NSString * message;
    if ([[perf getTypology] isEqualToString:@"concert"] || [[perf getTypology] isEqualToString:@"solidarity"]) {
        message = [NSString stringWithFormat:@"Formas parte de la propuesta artística de <b>%@</b> y estamos esperando a que el cliente decida entre los artistas propuestos. Haz click en Ver oferta para volver a revisar los detalles.", perf.performance_name];
    } else {
        message = [NSString stringWithFormat:@"Estamos revisando tu candidatura en <b>%@</b> y recibirás un mensaje nuestro en breves. Haz click en ver oferta para revisar los detalles.", perf.performance_name];
    }
    [item setNotification:message date:perf.performance_date button:@"Ver oferta"];
    [Utils setOnClick:item.btnAction1 withBlock:^(UIView *sender) {
        PageContext * ctx = [[PageContext alloc] init];
        [ctx addParam:@"performanceId" withIntValue:perf.performance_id];
        [ctx addParam:@"groupId" withIntValue:perf.group_id];
        [theApp.pages jumpToPage:@"PERFORMANCERESUME" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
    }];
}

-(void) fillInHistoryPerformance:(Noti *)item perf:(PerformanceGroup *)perf {
    NSString * message;
    if ([[perf getTypology] isEqualToString:@"concert"] || [[perf getTypology] isEqualToString:@"solidarity"]) {
        message = [NSString stringWithFormat:@"Concierto <b>%@</b> el %@. Haz click en ver oferta para revisar los detalles.", perf.performance_name, [Utils formatDate:perf.performance_date]];
    } else {
        message = [NSString stringWithFormat:@"Promoción en <b>%@</b> el %@. Haz click en ver oferta para revisar los detalles", perf.performance_name, [Utils formatDate:perf.performance_date]];
    }
    [item setNotification:message date:perf.performance_date button:@"Ver oferta"];
    [Utils setOnClick:item.btnAction1 withBlock:^(UIView *sender) {
        PageContext * ctx = [[PageContext alloc] init];
        [ctx addParam:@"performanceId" withIntValue:perf.performance_id];
        [ctx addParam:@"groupId" withIntValue:perf.group_id];
        [theApp.pages jumpToPage:@"PERFORMANCERESUME" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
    }];
}

// -------------------------------------------
// ACCIONES DE LAS NOTIFICACIONES
// -------------------------------------------
-(void) onMarkAsDone:(Noti *) item noti:(Notification *)noti {
    // Marcamos como leído el mensaje y desaparece...
    [WSDataManager markNotificationAsDone:noti._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        if (code == WS_SUCCESS) {
            [self setBadges:badges];
            [self setupBadges:self.vHeader];
        }
    }];
    // Ahora la quitamos de la lista y refrescamos...
    [notis removeObject:noti];
    [self fillInNotifications];
}
-(void) onRequestSharePermissionConfirm:(Noti *) item noti:(Notification *)noti {
    PageNotis * refThis = self;
    [WSDataManager confirmSharePermissionPerformerProfile:noti.user_id notificationId:noti._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        if (code == WS_SUCCESS) {
            [refThis->notis removeObject:noti];
            [self setBadges:badges];
            [self setupBadges:self.vHeader];
            [refThis fillInNotifications];
        } else {
            [theApp stdError:code];
        }
    }];
}
-(void) onRequestSharePermissionDeny:(Noti *) item noti:(Notification *)noti {
    PageNotis * refThis = self;
    [WSDataManager denySharePermissionPerformerProfile:noti.user_id notificacionId:noti._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        if (code == WS_SUCCESS) {
            [refThis->notis removeObject:noti];
            [self setBadges:badges];
            [self setupBadges:self.vHeader];
            [refThis fillInNotifications];
        } else {
            [theApp stdError:code];
        }
    }];
}
-(void) onRequestShareGroupPermissionConfirm:(Noti *) item noti:(Notification *)noti {
    int groupId = [noti.param3 intValue];
    
    PageNotis * refThis = self;
    [WSDataManager confirmSharePermissionGroupProfile:groupId notificationId:noti._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        if (code == WS_SUCCESS) {
            [refThis->notis removeObject:noti];
            [self setBadges:badges];
            [self setupBadges:self.vHeader];
            [refThis fillInNotifications];
        } else {
            [theApp stdError:code];
        }
    }];
}
-(void) onRequestShareGroupPermissionDeny:(Noti *) item noti:(Notification *)noti {
    int groupId = [noti.param3 intValue];
    
    PageNotis * refThis = self;
    [WSDataManager denySharePermissionGroupProfile:groupId notificationId:noti._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        if (code == WS_SUCCESS) {
            [refThis->notis removeObject:noti];
            [self setBadges:badges];
            [self setupBadges:self.vHeader];
            [refThis fillInNotifications];
        } else {
            [theApp stdError:code];
        }
    }];
}


@end
