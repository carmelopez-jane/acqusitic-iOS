//
//  PagePerfConfirmCandidate.m
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PagePerfConfirmCandidate.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "HeaderEdit.h"
#import "WSDataManager.h"
#import "NSAttributedString+DDHTML.h"
#import "Performance.h"

#define     STEP_INTRO          1
#define     STEP_DATE           2
#define     STEP_DESC           3
#define     STEP_CACHE          4
#define     STEP_MOREINFO       5

@interface PagePerfConfirmCandidate ()

@end

@implementation PagePerfConfirmCandidate

@synthesize svContent, lblTitle, lblDescription, lblGroup, vClose, vChat, ivAlert,svInfo, btnAction1, btnAction2, btnAction3;

-(BOOL)onPreloadPage:(PageContext *)context {
    [theApp showBlockView];
    
    performanceId = [context intParamByName:@"performanceId"];
    
    PagePerfConfirmCandidate * refThis = self;
    [WSDataManager getPerformance:performanceId withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            refThis->performance = [[Performance alloc] initWithDictionary:result];
            [WSDataManager getProfile:^(int code, NSDictionary *result, NSDictionary *badges) {
                if (code == WS_SUCCESS) {
                    theApp.appSession.performerProfile = [[Performer alloc] initWithDictionary:result];
                    NSInteger group_id = [context intParamByName:@"groupId"];
                    [WSDataManager getGroup:group_id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                        if (code == WS_SUCCESS) {
                            Group * group = [[Group alloc] initWithDictionary:result];
                            theApp.appSession.currentGroup = group;
                            [refThis endPreloading:YES];
                        } else {
                            [theApp stdError:code];
                            [refThis endPreloading:NO];
                        }
                    }];
                } else {
                    [theApp stdError:code];
                    [refThis endPreloading:NO];
                }
            }];
        } else {
            [theApp stdError:code];
            [refThis endPreloading:NO];
        }
    }];
    
    return YES;
}

-(void)onEnterPage:(PageContext *)context {
    
    [super onEnterPage:context];
    [self setTopColor:[Utils uicolorFromARGB:0xFF333333]];
    [self setBottomColor:[Utils uicolorFromARGB:0xFF333333]];


    [self loadNIB:@"PagePerfConfirmCandidate"];
    //[super setTopColor:RACC_YELLOW];

    _ctx = context;
    
    self.lblDescription.text = performance.name;
    
    [Utils setOnClick:self.vClose withBlock:^(UIView *sender) {
        [theApp.pages goBack];
    }];
    
    // Miramos el grupo
    /* PRELOAD SE ENCARGA
    NSInteger groupId = [context intParamByName:@"groupId"];
    if (groupId != 0) {
        for (int i=0;i<theApp.appSession.performerProfile.groups.count;i++) {
            Group * g = theApp.appSession.performerProfile.groups[i];
            if (g._id == groupId) {
                theApp.appSession.currentGroup = g;
            }
        }
    }
    */
    self.lblGroup.text = theApp.appSession.currentGroup.name;
    
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0,0,svInfo.frame.size.width,svInfo.frame.size.height)];
    [self.svInfo addSubview:infoView];
    
    // Ajustamos la posición de los elementos
    [Utils adjustUILabelHeight:self.lblTitle];
    [Utils adjustUILabelHeight:self.lblDescription];
    [Utils adjustUILabelHeight:self.lblGroup];
    [Utils setupVerticalRaw:@[self.lblTitle, self.lblDescription, self.lblGroup] sep:10];
    // Ajustamos la zona de scroll
    step = STEP_INTRO;
    [self setupStep];
    
    [self.btnAction1 addTarget:self action:@selector(onAction1Clicked) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAction2 addTarget:self action:@selector(onAction2Clicked) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAction3 addTarget:self action:@selector(onAction3Clicked) forControlEvents:UIControlEventTouchUpInside];
    
    [Utils setOnClick:self.vChat withBlock:^(UIView *sender) {
        [self addChat];
    }];

}

                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}

-(void) setupStep {
    // Limpiamos el infoView
    [[infoView subviews]
    makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // Vamos allá...
    switch (step) {
        case STEP_INTRO: {
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,0,infoView.frame.size.width, infoView.frame.size.height)];
            lbl.numberOfLines = 0;
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.font = [UIFont fontWithName:@"Roboto" size:13];
            lbl.text = @"A continuación, vamos a mostrar toda la información detallada de la oferta a la que te has inscrito para confirmar la preselección.\n\nTen en cuenta que es necesario seguir los pasos para confirmarla.";
            [infoView addSubview:lbl];
            btnAction1.hidden = NO; [btnAction1 setTitle:@"Continuar" forState:UIControlStateNormal];
            btnAction2.hidden = YES;
            btnAction3.hidden = YES;
            [self setupButtons];
            break;
        }
        case STEP_DATE: {
            NSString * date = [Utils formatDate:performance.performance_date withFormat:@"EEEE d MMM"];
            NSString * hour = [Utils formatTime:performance.performance_date];
            if (performance.performance_enddate != 0 && performance.performance_enddate != performance.performance_date) {
                hour = [hour stringByAppendingFormat:@" - %@", [Utils formatTime:performance.performance_enddate]];
            }
            NSString * location = performance.provisional_location;
            NSString * venue = [performance getVenue];
            NSString * loc = (venue && ![venue isEqualToString:@""])?venue:location;
            [self setupInfoBlock:@"Fecha y dirección" icon:@"icon_card_date.png" content:[NSString stringWithFormat:@"%@\n%@", date, hour] icon2:@"icon_card_location.png" content2:loc];
            btnAction1.hidden = NO; [btnAction1 setTitle:@"Continuar" forState:UIControlStateNormal];
            btnAction2.hidden = YES;
            btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
            [self setupButtons];
            break;
        }
        case STEP_DESC: {
            NSString * maxPeople = [performance getMemberCountFormatted];
            NSString * type = [performance getTypologyAsText];
            NSString * allInfo = [NSString stringWithFormat:@"%@\n%@", maxPeople, type];
            NSString * equipment = performance.group_equipment;
            [self setupInfoBlock:@"Descripción del evento" icon:@"icon_card_type.png" content:allInfo icon2:@"icon_card_equipment.png" content2:equipment];
            btnAction1.hidden = NO; [btnAction1 setTitle:@"Continuar" forState:UIControlStateNormal];
            btnAction2.hidden = YES;
            btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
            [self setupButtons];
            break;
        }
        case STEP_CACHE: {
            NSString * cache = [performance getCacheFormatted];
            [self setupInfoBlock:@"Caché" icon:@"icon_card_cache.png" content:cache icon2:nil content2:nil];
            if (performance.group_info == nil || [performance.group_info isEqualToString:@""]) {
                btnAction1.hidden = NO; [btnAction1 setTitle:@"Confirmar" forState:UIControlStateNormal];
                btnAction2.hidden = NO; [btnAction2 setTitle:@"Rechazar" forState:UIControlStateNormal];
                btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
            } else {
                btnAction1.hidden = NO; [btnAction1 setTitle:@"Continuar" forState:UIControlStateNormal];
                btnAction2.hidden = YES;
                btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
            }
            [self setupButtons];
            break;
        }
        case STEP_MOREINFO: {
            NSString * info = performance.group_info;
            [self setupInfoBlock:@"Información adicional" icon:@"icon_card_info.png" content:info icon2:nil content2:nil];
            btnAction1.hidden = NO; [btnAction1 setTitle:@"Confirmar" forState:UIControlStateNormal];
            btnAction2.hidden = NO; [btnAction2 setTitle:@"Rechazar" forState:UIControlStateNormal];
            btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
            [self setupButtons];
            break;
        }
    }
}

-(void) setupInfoBlock:(NSString *)title icon:(NSString *)icon content:(NSString *)content icon2:(NSString *)icon2 content2:(NSString *)content2 {
    
    int yTop = 0;
    UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,0,infoView.frame.size.width, infoView.frame.size.height)];
    lbl.numberOfLines = 0;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = ACQUSTIC_GREEN;
    lbl.text = title;
    lbl.font = [UIFont fontWithName:@"Roboto" size:15];
    [Utils adjustUILabelHeight:lbl];
    [infoView addSubview:lbl];
    yTop += 60;
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake((infoView.frame.size.width-20)/2,yTop,20,20)];
    img.image = [UIImage imageNamed:icon];
    [infoView addSubview:img];
    yTop += img.frame.size.height + 10;
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,yTop,infoView.frame.size.width, infoView.frame.size.height)];
    lbl.numberOfLines = 0;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = [UIColor blackColor];
    lbl.text = content;
    lbl.font = [UIFont fontWithName:@"Roboto-Light" size:16];
    [Utils adjustUILabelHeight:lbl];
    [infoView addSubview:lbl];
    yTop += lbl.frame.size.height + 60;
    if (icon2 && content2 && ![content2 isEqualToString:@""]) {
        img = [[UIImageView alloc] initWithFrame:CGRectMake((infoView.frame.size.width-20)/2,yTop,20,20)];
        img.image = [UIImage imageNamed:icon2];
        [infoView addSubview:img];
        yTop += img.frame.size.height + 10;
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,yTop,infoView.frame.size.width, infoView.frame.size.height)];
        lbl.numberOfLines = 0;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.textColor = [UIColor blackColor];
        lbl.text = content2;
        lbl.font = [UIFont fontWithName:@"Roboto-Light" size:16];
        [Utils adjustUILabelHeight:lbl];
        [infoView addSubview:lbl];
        yTop += lbl.frame.size.height + 30;
    }
    /*
    CGRect fr = infoView.frame;
    fr.size.height = yTop;
    infoView.frame = fr;
    */
}

-(void) nextStep {
    step++;
    [self setupStep];
}

-(void) prevStep {
    step--;
    [self setupStep];
}

-(void) onAction1Clicked {
    if (step < STEP_CACHE ) {
        [self nextStep];
    } else if (step == STEP_CACHE && performance.group_info != nil && ![performance.group_info isEqualToString:@""]) {
        [self nextStep];
    } else {
        NSInteger groupId = theApp.appSession.currentGroup._id;
        /*
        [theApp QueryMessage:@"Vas a confirmar tu candidatura a esta oferta.\n¿Seguimos adelante?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
            if (command == POPUP_CMD_YES) {
         */
                [theApp showBlockView];
                [WSDataManager performanceConfirmCandidate:groupId performance:self->performance withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
                    [theApp hideBlockView];
                    if (code == WS_SUCCESS) {
                        NSInteger notificationId = [self->_ctx intParamByName:@"notificationId"];
                        if (notificationId > 0) {
                            [theApp showBlockView];
                            [WSDataManager markNotificationAsDone:notificationId withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
                                [theApp hideBlockView];
                                //[theApp MessageBox:@"¡Estupendo!\n¡Seguimos!"];
                                [theApp.pages goBack];
                            }];
                        }  else {
                           //[theApp MessageBox:@"¡Estupendo!\n¡Seguimos!"];
                           [theApp.pages goBack];
                        }
                    } else {
                        [theApp stdError:code];
                    }
                }];
        /*
            }
        }];
        */
    }
}

-(void) onAction2Clicked {
    if (step < STEP_MOREINFO) {
        [self nextStep];
    } else {
        NSInteger groupId = theApp.appSession.currentGroup._id;
        [theApp QueryMessage:@"¿Seguro que quieres renunciar a participar en este concierto?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
            if (command == POPUP_CMD_YES) {
                [theApp showBlockView];
                [WSDataManager performanceRejectCandidate:groupId performance:self->performance withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
                    [theApp hideBlockView];
                    if (code == WS_SUCCESS) {
                        NSInteger notificationId = [self->_ctx intParamByName:@"notificationId"];
                        if (notificationId > 0) {
                            [theApp showBlockView];
                            [WSDataManager markNotificationAsDone:notificationId withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
                                [theApp hideBlockView];
                                [theApp MessageBox:@"¡Estupendo!\n¡Otra vez será!"];
                                [theApp.pages goBack];
                            }];
                        }  else {
                           [theApp MessageBox:@"¡Estupendo!\n¡Otra vez será!"];
                           [theApp.pages goBack];
                        }
                    } else {
                        [theApp stdError:code];
                    }
                }];
            }
        }];
    }
}

-(void) setupButtons {
    CGRect fr;
    int bottom = self.vInfo.frame.size.height - 25; // El botón inferior
    if (!btnAction3.hidden) {
        fr = btnAction3.frame;
        fr.origin.y = bottom - 35;
        btnAction3.frame = fr;
        bottom -= 42; // 5 separación entre botones
    }
    if (!btnAction2.hidden) {
        fr = btnAction2.frame;
        fr.origin.y = bottom - 35;
        btnAction2.frame = fr;
        bottom -= 42; // 5 separación entre botones
    }
    if (!btnAction1.hidden) {
        fr = btnAction1.frame;
        fr.origin.y = bottom - 35;
        btnAction1.frame = fr;
        bottom -= 42; // 5 separación entre botones
    }
}

-(void) onAction3Clicked {
    // ANTERIOR
    if (step > STEP_INTRO)
        [self prevStep];
}

-(void) addChat {
    NSString * title = [NSString stringWithFormat:@"Actuación %@", performance.name];
    [WSDataManager newChat:title type:@"operation" targetType:@"performance" targetId:performance._id withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
        if (code == WS_SUCCESS) {
            NSInteger chatId = [result[@"id"] integerValue];
            PageContext * ctx = [[PageContext alloc] init];
            [ctx addParam:@"chatId" withIntValue:chatId];
            [theApp.pages jumpToPage:@"CHAT" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:FALSE];
        }
    }];
}



@end
