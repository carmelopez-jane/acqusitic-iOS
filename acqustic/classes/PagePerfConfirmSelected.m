//
//  PagePerfConfirmSelected.m
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PagePerfConfirmSelected.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "HeaderEdit.h"
#import "WSDataManager.h"
#import "NSAttributedString+DDHTML.h"
#import "FormItemPerformer.h"
#import "FormItemSepfull.h"
#import "FormItemHeader.h"
#import "FormItemSubnote.h"

#define     STEP_INTRO                      1
#define     STEP_DATE                       2
#define     STEP_DESC                       3
#define     STEP_CACHE                      4
#define     STEP_MOREINFO                   5

#define     STEP_DISTRIBUTION_INTRO         6
#define     STEP_DISTRIBUTION_CHECKDATOS    7
#define     STEP_DISTRIBUTION_DIST          8
#define     STEP_DISTRIBUTION_DOCUS         9
#define     STEP_DISTRIBUTION_ADDINFO       10
#define     STEP_DISTRIBUTION_LOPD          11
#define     STEP_DISTRIBUTION_CONFIRM       12


@interface PagePerfConfirmSelected ()

@end

@implementation PagePerfConfirmSelected

@synthesize svContent, lblTitle, lblDescription, lblGroup, vClose, vChat, ivAlert, vInfo, svInfo, btnAction1, btnAction2, btnAction3;

-(BOOL)onPreloadPage:(PageContext *)context {
    [theApp showBlockView];
    performanceId = [context intParamByName:@"performanceId"];
    PagePerfConfirmSelected * refThis = self;
    
    [WSDataManager getPerformance:performanceId withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            refThis->performance = [[Performance alloc] initWithDictionary:result];
            [WSDataManager getProfile:^(int code, NSDictionary *result, NSDictionary *badges) {
                if (code == WS_SUCCESS) {
                    theApp.appSession.performerProfile = [[Performer alloc] initWithDictionary:result];
                    self->group_id = [context intParamByName:@"groupId"];
                    [WSDataManager getGroup:self->group_id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                        if (code == WS_SUCCESS) {
                            self->group = [[Group alloc] initWithDictionary:result];
                            theApp.appSession.currentGroup = self->group;
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


    [self loadNIB:@"PagePerfConfirmSelected"];
    //[super setTopColor:RACC_YELLOW];

    distributionFM = nil;
    finalPerformers = [[NSMutableArray alloc] init];
    group_notes = @"";

    _ctx = context;
    
    baseY = self.vInfo.frame.origin.y;
    baseHeight = self.vInfo.frame.size.height;
    infoY = self.svInfo.frame.origin.y;
    infoHeight = self.svInfo.frame.size.height;
    
    self.lblDescription.text = performance.name;
    
    [Utils setOnClick:self.vClose withBlock:^(UIView *sender) {
        [theApp.pages goBack];
    }];
    
    // Miramos el grupo
    /*
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
    //step = STEP_INTRO;
    step = STEP_DISTRIBUTION_INTRO;
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
            [self setupModeIntro];
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
            [self setupModeIntro];
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
            [self setupModeIntro];
            NSString * type = [performance getTypologyAsText];
            NSString * equipment = performance.group_equipment;
            [self setupInfoBlock:@"Descripción del evento" icon:@"icon_card_type.png" content:type icon2:@"icon_card_equipment.png" content2:equipment];
            btnAction1.hidden = NO; [btnAction1 setTitle:@"Continuar" forState:UIControlStateNormal];
            btnAction2.hidden = YES;
            btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
            [self setupButtons];
            break;
        }
        case STEP_CACHE: {
            [self setupModeIntro];
            NSString * cache = [performance getCacheFormatted];
            [self setupInfoBlock:@"Caché" icon:@"icon_card_cache.png" content:cache icon2:nil content2:nil];
            btnAction1.hidden = NO; [btnAction1 setTitle:@"Continuar" forState:UIControlStateNormal];
            btnAction2.hidden = YES;
            btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
            [self setupButtons];
            break;
        }
        case STEP_MOREINFO: {
            [self setupModeIntro];
            NSString * info = performance.group_info;
            [self setupInfoBlock:@"Información adicional" icon:@"icon_card_info.png" content:info icon2:nil content2:nil];
            btnAction1.hidden = NO; [btnAction1 setTitle:@"Confirmar" forState:UIControlStateNormal];
            btnAction2.hidden = NO; [btnAction2 setTitle:@"Rechazar" forState:UIControlStateNormal];
            btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
            [self setupButtons];
            break;
        }
        case STEP_DISTRIBUTION_INTRO: {
            [self setupModeDistribution1];
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,0,infoView.frame.size.width, infoView.frame.size.height)];
            lbl.numberOfLines = 0;
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.font = [UIFont fontWithName:@"Roboto" size:13];
            lbl.text = @"A continuación, para la confirmación del concierto, es necesario realizar una factura.\n\nRecuerda que es muy importante emitir la factura para todos los miembros que vayan a la actuación. Se rechazará si se detecta cualquier error o faltan miembros.\n\nPulsa en el botón “Hacer Factura” para continuar con el tramite.";
            [infoView addSubview:lbl];
            btnAction1.hidden = NO; [btnAction1 setTitle:@"Hacer factura" forState:UIControlStateNormal];
            btnAction2.hidden = YES;
            btnAction3.hidden = YES;
            [self setupButtons];
            break;
        }
        case STEP_DISTRIBUTION_CHECKDATOS: {
            [self setupModeDistribution1];
            int yPos = 40;
            UILabel * lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(0,0,infoView.frame.size.width, infoView.frame.size.height)];
            lbl2.numberOfLines = 0;
            lbl2.textAlignment = NSTextAlignmentCenter;
            lbl2.font = [UIFont fontWithName:@"Roboto" size:13];
            lbl2.text = @"Indica los miembros que tocaréis en el concierto pulsando el icono circular junto al nombre del miembro";
            [infoView addSubview:lbl2];
            [Utils adjustUILabelHeight:lbl2];
            yPos += lbl2.frame.size.height + 10;
            FormItemHeader * h = [[FormItemHeader alloc] initWithFrame:CGRectMake(0,yPos,infoView.frame.size.width, 55)];
            h.lblLabel.text = @"Miembros";
            h.ivIcon.hidden = YES;
            [infoView addSubview:h];
            yPos += 55;
            FormItemSepFull * s = [[FormItemSepFull alloc] initWithFrame:CGRectMake(0,yPos,infoView.frame.size.width, 1)];
            yPos += 1;
            [infoView addSubview:s];
            for (int i=0;i<group.performers.count;i++) {
                if (i > 0) {
                    FormItemSepFull * sep = [[FormItemSepFull alloc] initWithFrame:CGRectMake(0, yPos, infoView.frame.size.width, 1)];
                    [infoView addSubview:sep];
                    yPos++;
                }
                Performer * p = group.performers[i];
                FormItemPerformer * vp = [[FormItemPerformer alloc] initWithFrame:CGRectMake(0,yPos,infoView.frame.size.width, 55)];
                vp.lblLabel.text = p.name;
                vp.tag = i;
                vp.vCheck.tag = i;
                vp.vIcon.tag = i;
                if (![p hasPermission:@"share"]) {
                    vp.ivIcon.image = [UIImage imageNamed:@"icon_info.png"];
                }
                if ([p isReadyForPerformances]) {
                    vp.ivStatus.image = [UIImage imageNamed:@"icon_check_ok.png"];
                } else {
                    vp.ivStatus.image = [UIImage imageNamed:@"icon_check_ko.png"];
                }
                [Utils setOnClick:vp withBlock:^(UIView *sender) {
                    FormItemPerformer * vp = (FormItemPerformer *)sender;
                    Performer * p = self->group.performers[sender.tag];
                    if (p.selected) {
                        p.selected = NO;
                    } else {
                        p.selected = YES;
                    }
                    [vp setChecked:p.selected];
                }];
                [Utils setOnClick:vp.vIcon withBlock:^(UIView *sender) {
                    Performer * p = self->group.performers[sender.tag];
                    [self editPerformer:p];
                }];
                [vp setChecked:p.selected];
                [infoView addSubview:vp];
                yPos += 55;
                // Botones
                btnAction1.hidden = NO; [btnAction1 setTitle:@"Continuar" forState:UIControlStateNormal];
                btnAction2.hidden = YES;
                btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
                [self setupButtons];
            }
            FormItemSubnote * subNote = [[FormItemSubnote alloc] initWithFrame:CGRectMake(-10,yPos,infoView.frame.size.width+20, 55)];
            NSDictionary * imgMap = @{
                @"icon_check_ko": [UIImage imageNamed:@"icon_check_ko.png"],
                @"icon_edit": [UIImage imageNamed:@"icon_edit.png"],
            };
            NSString * infoBlock = @"Los miembros indicados con el símbolo <img src='icon_check_ko' width='25' height='25'> no tienen todos sus datos de facturación. Para complementarlos, puedes hacerlo tú mismo <img src='icon_edit' width='25' height='25'> o contactarle para que lo haga";
            subNote.lblLabel.attributedText = [NSAttributedString attributedStringFromHTML:infoBlock normalFont:subNote.lblLabel.font boldFont:subNote.lblLabel.font italicFont:subNote.lblLabel.font imageMap:imgMap];

            [subNote updateSize];
            [infoView addSubview:subNote];
            yPos += subNote.frame.size.height + 10;
            // Ajustamos infoview con scroll...
            CGRect fr = infoView.frame;
            fr.size.height = yPos+10;
            infoView.frame = fr;
            svInfo.contentSize = CGSizeMake(0, infoView.frame.size.height);
            
            break;
        }
        case STEP_DISTRIBUTION_DIST: {
            [self setupModeDistribution1];
            int yPos = 40;
            UILabel * lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(0,0,infoView.frame.size.width, infoView.frame.size.height)];
            lbl2.numberOfLines = 0;
            lbl2.textAlignment = NSTextAlignmentCenter;
            lbl2.font = [UIFont fontWithName:@"Roboto" size:13];
            lbl2.text = @"A continuación puedes decidir como quieres hacer la repartición del caché.\n\nPara modificar lo que aparece por defecto, pulsa y selecciona el nuevo porcentaje para cada usuario.";
            [infoView addSubview:lbl2];
            [Utils adjustUILabelHeight:lbl2];
            yPos += lbl2.frame.size.height + 10;
            
            distribution = [[PerformanceDist alloc] init];
            [distribution fillInDistributionForForm:finalPerformers];
            distributionFM = [[FormBuilder alloc] init];
            FBItem * fbItem;
            fbItem = [[FBItem alloc] init:@"Miembros" fieldType:FIELD_TYPE_SECTION];
            [distributionFM add:fbItem];
            for (int i=0;i<finalPerformers.count;i++) {
                Performer * p = finalPerformers[i];
                fbItem = [[FBItem alloc] init:[NSString stringWithFormat:@"%% %@ %@", p.name, p.surname] fieldType:FIELD_TYPE_PERCENT fieldName:[NSString stringWithFormat:@"percent%d", i]];
                [distributionFM add:fbItem];
            }
            
            yPos = [distributionFM fillInForm:infoView from:yPos withData:distribution];
            // Botones
            btnAction1.hidden = NO; [btnAction1 setTitle:@"Continuar" forState:UIControlStateNormal];
            btnAction2.hidden = YES;
            btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
            [self setupButtons];
            
            // Ajustamos infoview con scroll...
            CGRect fr = infoView.frame;
            fr.size.height = yPos+10;
            infoView.frame = fr;
            svInfo.contentSize = CGSizeMake(0, infoView.frame.size.height);

            break;
        }
        case STEP_DISTRIBUTION_DOCUS: {
            [self setupModeDistribution1];
            int yPos = 40;
            UILabel * lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(0,0,infoView.frame.size.width, infoView.frame.size.height)];
            lbl2.numberOfLines = 0;
            lbl2.textAlignment = NSTextAlignmentCenter;
            lbl2.font = [UIFont fontWithName:@"Roboto" size:13];
            lbl2.text = @"En el caso de que algún miembro necesite cualquiera de los siguientes documentos, selecciónalos a continuación.";
            [infoView addSubview:lbl2];
            [Utils adjustUILabelHeight:lbl2];
            yPos += lbl2.frame.size.height + 10;
            
            distributionFM = [[FormBuilder alloc] init];
            FBItem * fbItem;
            fbItem = [[FBItem alloc] init:@"Document. para miembros" fieldType:FIELD_TYPE_SECTION];
            [distributionFM add:fbItem];
            for (int i=0;i<finalPerformers.count;i++) {
                Performer * p = finalPerformers[i];
                fbItem = [[FBItem alloc] init:[NSString stringWithFormat:@"%@ %@", p.name, p.surname] fieldType:FIELD_TYPE_LONGMULTISELECT fieldName:[NSString stringWithFormat:@"documents%d", i]];
                fbItem.valuesIndex = @"PERFORMANCE_DOCUMENTS_OPTIONS";
                [distributionFM add:fbItem];
            }
            yPos = [distributionFM fillInForm:infoView from:yPos withData:distribution];
            // Botones
            btnAction1.hidden = NO; [btnAction1 setTitle:@"Continuar" forState:UIControlStateNormal];
            btnAction2.hidden = YES;
            btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
            [self setupButtons];
            
            // Ajustamos infoview con scroll...
            CGRect fr = infoView.frame;
            fr.size.height = yPos+10;
            infoView.frame = fr;
            svInfo.contentSize = CGSizeMake(0, infoView.frame.size.height);

            break;
        }
        case STEP_DISTRIBUTION_ADDINFO: {
            [self setupModeDistribution1];
            vAddInfo = [[PerfInfoAddInfo alloc] initWithFrame:CGRectMake(0,0,infoView.frame.size.width, infoView.frame.size.height)];
            [infoView addSubview:vAddInfo];
            btnAction1.hidden = NO; [btnAction1 setTitle:@"Continuar" forState:UIControlStateNormal];
            btnAction2.hidden = YES;
            btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
            [self setupButtons];
            break;
        }
        case STEP_DISTRIBUTION_LOPD: {
            [self setupModeDistribution2];
            vLOPD = [[PerfInfoLOPD alloc] initWithFrame:CGRectMake(0,0,infoView.frame.size.width, infoView.frame.size.height)];
            [infoView addSubview:vLOPD];

            btnAction1.hidden = NO; [btnAction1 setTitle:@"Continuar" forState:UIControlStateNormal];
            btnAction2.hidden = YES;
            btnAction3.hidden = NO; [btnAction3 setTitle:@"Anterior" forState:UIControlStateNormal];
            [self setupButtons];
            break;
        }
        case STEP_DISTRIBUTION_CONFIRM: {
            [self setupModeDistribution1];
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,0,infoView.frame.size.width, infoView.frame.size.height)];
            lbl.numberOfLines = 0;
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.font = [UIFont fontWithName:@"Roboto-Bold" size:13];
            lbl.text = @"¡Enhorabuena!\nTu factura ha sido tramitada.\nY, ¿ahora que?";
            [infoView addSubview:lbl];
            UILabel * lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(0,0,infoView.frame.size.width, infoView.frame.size.height)];
            lbl2.numberOfLines = 0;
            lbl2.textAlignment = NSTextAlignmentCenter;
            lbl2.font = [UIFont fontWithName:@"Roboto" size:13];
            lbl2.text = @"Nuestro equipo de producción esta trabajando para que tengas la mejor experiencia.\n\nUnos días antes del concierto, se te enviará a través de la  aplicación un recordatorio para que no te olvides de nada.\n\nMientras tanto, si tienes alguna duda, puedes contactar con  nosotros a través nuestro chat.";
            [infoView addSubview:lbl2];
            [Utils adjustUILabelHeight:lbl];
            [Utils adjustUILabelHeight:lbl2];
            [Utils setupVerticalRaw:@[lbl, lbl2] sep:10];
            
            btnAction1.hidden = NO; [btnAction1 setTitle:@"Continuar" forState:UIControlStateNormal];
            btnAction2.hidden = YES;
            btnAction3.hidden = YES;
            [self setupButtons];
            break;
        }

    }
}

-(void) setupModeIntro {
    CGRect fr;
    self.lblTitle.text = @"Confirmación";
    self.lblGroup.hidden = NO;
    fr = vInfo.frame;
    fr.origin.y = baseY; fr.size.height = baseHeight;
    vInfo.frame = fr;
    
    self.ivAlert.hidden = NO;
    fr = svInfo.frame;
    fr.origin.y = infoY; fr.size.height = infoHeight;
    svInfo.frame = fr;
}

-(void) setupModeDistribution1 {
    CGRect fr;
    self.lblTitle.text = @"Emite tu factura";
    self.lblGroup.hidden = NO;
    /*
    fr = vInfo.frame;
    fr.origin.y = baseY-30; fr.size.height = baseHeight + 30;
    vInfo.frame = fr;
     */
    
    self.ivAlert.hidden = YES;
    fr = svInfo.frame;
    fr.origin.y = infoY - 50; fr.size.height = infoHeight + 50;
    svInfo.frame = fr;
}

-(void) setupModeDistribution2 {
    CGRect fr;
    self.lblTitle.text = @"Emite tu factura";
    self.lblGroup.hidden = NO;
    /*
    fr = vInfo.frame;
    fr.origin.y = baseY-30; fr.size.height = baseHeight+30;
    vInfo.frame = fr;
     */

    self.ivAlert.hidden = NO;
    fr = svInfo.frame;
    fr.origin.y = infoY; fr.size.height = infoHeight;
    svInfo.frame = fr;
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
    if (icon2) {
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
    if (step < STEP_DISTRIBUTION_INTRO) {
        step++;
        [self setupStep];
    } else if (step == STEP_DISTRIBUTION_INTRO) {
        step++;
        [self setupStep];
    } else if (step == STEP_DISTRIBUTION_CHECKDATOS) {
        [finalPerformers removeAllObjects];
        for (int i=0;i<group.performers.count;i++) {
            Performer * p = group.performers[i];
            if (p.selected) {
                if (![p isReadyForPerformances]) {
                    [theApp MessageBox:@"Los miembros seleccionados deben tener sus datos de facturación completos."];
                    return;
                }
                [finalPerformers addObject:p];
            }
        }
        if (finalPerformers.count == 0) {
            [theApp MessageBox:@"Debes indicar al menos un miembro del grupo"];
            return;
        }
        step++;
        [self setupStep];
    } else if (step == STEP_DISTRIBUTION_DIST) {
        [distributionFM save:distribution];
        // Ahora comprobamos que esté correcto
        if (![distribution checkDistribution]) {
            [theApp MessageBox:@"Parece que hay un problema en las participaciones. Recuerda que en conjunto tienen que sumar el 100%. Por favor revisa los datos."];
            return;
        }
        step++;
        [self setupStep];
    } else if (step == STEP_DISTRIBUTION_DOCUS) {
        [distributionFM save:distribution];
        step++;
        [self setupStep];
    } else if (step == STEP_DISTRIBUTION_ADDINFO) {
        group_notes = vAddInfo.tvMoreInfo.text;
        step++;
        [self setupStep];
    } else if (step == STEP_DISTRIBUTION_LOPD) {
        if (!vLOPD.swConditions.on) {
            [theApp MessageBox:@"Debes aceptar las condiciones uso de la aplicación para continuar"];
            return;
        }
        // Confirmamos
        [theApp showBlockView];
        [WSDataManager performanceConfirmSelected:group_id performance:performance dist:distribution groupNotes:group_notes withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                NSInteger notificationId = [self->_ctx intParamByName:@"notificationId"];
                if (notificationId > 0) {
                    [WSDataManager markNotificationAsDone:notificationId withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
                        self->step++;
                        [self setupStep];
                    }];
                } else {
                    self->step++;
                    [self nextStep];
                }
            } else {
                [theApp stdError:code];
            }
        }];
    } else if (step == STEP_DISTRIBUTION_CONFIRM) {
        step++;
        // Nos vamos a las notificaciones
        [theApp.pages jumpToPage:@"NOTIS" withContext:nil withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:YES]; // NUNCA SE VUELVE AQUÍ
    }
}

-(void) prevStep {
    step--;
    [self setupStep];
}

-(void) onAction1Clicked {
    [self nextStep];
    /*
    if (step < STEP_MOREINFO) {
        [self nextStep];
    } else if (step == STEP_DISTRIBUTION_INTRO) {
        [self nextStep];
    } else if (step == STEP_DISTRIBUTION_CHECKDATOS) {
        [finalPerformers removeAllObjects];
        for (int i=0;i<group.performers.count;i++) {
            Performer * p = group.performers[i];
            if (p.selected) {
                [finalPerformers addObject:p];
            }
        }
        if (finalPerformers.count == 0) {
            [theApp MessageBox:@"Debes indicar al menos un miembro del grupo"];
            return;
        }
        [self nextStep];
    } else if (step == STEP_DISTRIBUTION_DIST) {
        [distributionFM save:distribution];
        // Ahora comprobamos que esté correcto
        if ([distribution checkDistribution]) {
            [theApp MessageBox:@"Parece que hay un problema en las participaciones. Recuerda que en conjunto tienen que sumar el 100%. Por favor revisa los datos."];
            return;
        }
        [self nextStep];
    } else if (step == STEP_DISTRIBUTION_DOCUS) {
        [distributionFM save:distribution];
        [self nextStep];
    } else if (step == STEP_DISTRIBUTION_ADDINFO) {
        group_notes = ((EditText)content.findViewById(R.id.tf_popup_perf_info)).getText().toString();
        [self nextStep];
    } else if (step == STEP_DISTRIBUTION_LOPD) {
        Switch swLOPD = content.findViewById(R.id.il_popup_perf_switch);
        if (!swLOPD.isChecked()) {
            Acqustic.theApp.MessageBox("Debes aceptar las condiciones uso de la aplicación para continuar");
            return;
        }
        // Confirmamos
        [theApp showBlockView];
        // falta distribution y group_notes
        [WSDataManager performanceConfirmSelected:groupId performance:performance dist:distribution withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                NSInteger notificationId = [self->_ctx intParamByName:@"notificationId"];
                if (notificationId > 0) {
                    [theApp showBlockView];
                    [WSDataManager markNotificationAsDone:notificationId withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
                        [theApp hideBlockView];
                        [theApp MessageBox:@"¡Estupendo!\n¡Seguimos!"];
                        [theApp.pages goBack];
                    }];
                }  else {
                   [theApp MessageBox:@"¡Estupendo!\n¡Seguimos!"];
                   [theApp.pages goBack];
                }
            } else {
                [theApp stdError:code];
            }
        }];
    } else if (step == STEP_DISTRIBUTION_CONFIRM) {
        // Nos vamos a las notificaciones
        [theApp.pages jumpToPage:@"NOTIS" withContext:nil];
    }*/
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

-(void) editPerformer:(Performer *)p {
    if ([p hasPermission:@"share"]) {
        PageContext * ctx = [[PageContext alloc] init];
        [ctx addParam:@"performerId" withIntValue:p._id];
        [theApp.pages jumpToPage:@"GROUPMEMBER" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
    } else {
        NSString * msg = [NSString stringWithFormat:@"En este momento no tienes permiso para acceder a los datos de %@. ¿Quieres solicitarle permiso para acceder?", p.name];
        [theApp QueryMessage:msg withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
            if (command == POPUP_CMD_YES) {
                [WSDataManager requestSharePermissionPerformerProfile:p._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                    if (code == WS_SUCCESS) {
                        NSString * msg = [NSString stringWithFormat:@"Hemos enviado la solicitud a %@. Si te da permiso, podrás acceder a sus datos particulares.", p.name];
                        [theApp MessageBox:msg];
                    } else {
                        [theApp stdError:code];
                    }
                }];
            }
        }];
    }
}

@end
