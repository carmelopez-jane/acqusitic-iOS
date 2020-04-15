//
//  PagePerfRegister.m
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PagePerfRegister.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "HeaderEdit.h"
#import "WSDataManager.h"
#import "NSAttributedString+DDHTML.h"
#import "PageCompleteFreemium.h"

@interface PagePerfRegister ()

@end

@implementation PagePerfRegister

@synthesize svContent, lblTitle, lblDescription, lblDetail, lblSubscribe, btnSubscribe, btnBack;

-(BOOL)onPreloadPage:(PageContext *)context {
    [theApp showBlockView];
    
    [self setTopColor:[Utils uicolorFromARGB:0xFF333333]];
    [self setBottomColor:[Utils uicolorFromARGB:0xFF333333]];

    performanceId = [context intParamByName:@"performanceId"];
    
    PagePerfRegister * refThis = self;
    [WSDataManager getPerformance:performanceId withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            refThis->performance = [[Performance alloc] initWithDictionary:result];
            [WSDataManager getProfile:^(int code, NSDictionary *result, NSDictionary *badges) {
                if (code == WS_SUCCESS) {
                    theApp.appSession.performerProfile = [[Performer alloc] initWithDictionary:result];
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
    
    return YES;
}

-(void)onEnterPage:(PageContext *)context {
    
    [super onEnterPage:context];

    [self loadNIB:@"PagePerfRegister"];
    //[super setTopColor:RACC_YELLOW];

    _ctx = context;
    
    self.lblTitle.text = performance.name;
    /*
    self.lblDescription.text = performance.description;
    
    // Montamos el bloque de información
    NSString * date = [Utils formatDate:performance.performance_date withFormat:@"EEEE d MMM"];
    NSString * hour = [Utils formatTime:performance.performance_date];
    if (performance.performance_enddate != 0 && performance.performance_enddate != performance.performance_date) {
        hour = [hour stringByAppendingFormat:@" - %@", [Utils formatTime:performance.performance_enddate]];
    }
    NSString * location = performance.provisional_location;
    NSString * type = [performance getTypologyAsText];
    NSString * equipment = performance.group_equipment;
    NSString * memberCount = [performance getMemberCountFormatted];
    NSString * cache = [performance getCacheFormatted];
    NSString * info = performance.group_info;
    NSDictionary * imgMap = @{
        @"icon_card_date": [UIImage imageNamed:@"icon_card_date_white.png"],
        @"icon_card_hour": [UIImage imageNamed:@"icon_card_hour_white.png"],
        @"icon_card_location": [UIImage imageNamed:@"icon_card_location_white.png"],
        @"icon_card_type": [UIImage imageNamed:@"icon_card_type_white.png"],
        @"icon_card_equipment": [UIImage imageNamed:@"icon_card_equipment_white.png"],
        @"icon_card_membercount": [UIImage imageNamed:@"icon_card_membercount_white.png"],
        @"icon_card_cache": [UIImage imageNamed:@"icon_card_cache_white.png"],
        @"icon_card_info": [UIImage imageNamed:@"icon_card_info_white.png"],
    };
    NSString * infoBlock = @"";
    if (date && ![date isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p><img src='icon_card_date' width='30' height='30'> %@</p> ", date];
    }
    if (hour && ![hour isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p><img src='icon_card_hour' width='30' height='30'> %@</p> ", hour];
    }
    if (location && ![location isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p><img src='icon_card_location' width='30' height='30'> %@</p> ", location];
    }
    if (type && ![type isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p><img src='icon_card_type' width='30' height='30'> %@</p> ", type];
    }
    if (equipment && ![equipment isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p><img src='icon_card_equipment' width='30' height='30'> %@</p> ", equipment];
    }
    if (memberCount && ![memberCount isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p><img src='icon_card_membercount' width='30' height='30'> %@</p> ", memberCount];
    }
    if (cache && ![cache isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p><img src='icon_card_cache' width='30' height='30'> %@</p> ", cache];
    }
    if (info && ![info isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p><img src='icon_card_info' width='30' height='30'> %@</p> ", info];
    }
    infoBlock = [infoBlock stringByAppendingString:@"<p></p>"]; // Centinela, si no se come el último
    lblDetail.attributedText = [NSAttributedString attributedStringFromHTML:infoBlock normalFont:lblDetail.font boldFont:lblDetail.font italicFont:lblDetail.font imageMap:imgMap];
    */
    
    NSMutableArray * ids = [[NSMutableArray alloc] init];
    NSMutableArray * names = [[NSMutableArray alloc] init];
    for (int i=0;i<theApp.appSession.performerProfile.groups.count;i++) {
        Group * g = theApp.appSession.performerProfile.groups[i];
        if ([g hasPermission:@"share"]) {
            [ids addObject:[NSString stringWithFormat:@"%ld", g._id]];
            [names addObject: g.name];
        }
    }
    
    // No tenemos grupos administrados...
    if (ids.count == 0) {
        [theApp MessageBox:@"Para poder registrarte has de tener algún grupo con acceso como administrador. Puedes crear un nuevo grupo desde tu perfil, o pedir permiso al administrador de tu grupo para que te dé acceso de administrador."];
        self.lblSubscribe.hidden = YES;
        self.tfSubscribe.hidden = YES;
        self.btnSubscribe.hidden = YES;
        [btnBack addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
        return;
    }
    
    
    picker = [[DownMOptionsPicker alloc] initWithTextField:self.tfSubscribe withData:names andValues:ids];
    [picker setSelectedValues:[NSString stringWithFormat:@"%ld", ((Group *)theApp.appSession.performerProfile.groups[0])._id]];
    
    [btnSubscribe addTarget:self action:@selector(onSubscribe:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnBack addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}

-(void) onSubscribe:(UIButton *)btn {
    NSString * groups = [picker getSelectedValues];
    if (groups == nil || [groups isEqualToString:@""]) {
        [theApp MessageBox:@"Debes seleccionar al menos un grupo con el que registrarte"];
        return;
    }
    // Miramos si todos los grupos escogidos son válidos
    NSArray * gs = [groups componentsSeparatedByString:@","];
    int freemiumCount = 0;
    for (int i=0;i<gs.count;i++) {
        NSInteger gid = [gs[i] integerValue];
        for (int j=0;j<theApp.appSession.performerProfile.groups.count;j++) {
            Group * g = theApp.appSession.performerProfile.groups[j];
            if (g._id == gid) {
                if ([g isReadyForRegister])
                    freemiumCount++;
                break;
            }
        }
    }
    
    // Si todos tienen los datos básicos y el perfil del usuario está completo...
    if (freemiumCount == gs.count && [theApp.appSession.performerProfile isReadyForRegister]) {
        // Aquí hay que seleccionar los grupos marcados
        [theApp showBlockView];
        [WSDataManager performanceRegisterMultiple:groups performance:performance withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                /*
                [theApp MessageBox:@"¡Estupendo! Estudiaremos tu solicitud y te iremos informando de su progreso" onCommand:^(Popup *pm, int command, NSObject *data) {
                    [theApp.pages goBack];
                }];
                */
                [theApp.pages goBack];
            } else {
                [theApp stdError:code];
            }
            
        }];
    } else { // Hay algunos que no está completos...
        PageContext * ctx = [self._context clone];
        [ctx addParam:@"groups" withValue:groups];
        [ctx addParam:@"mode" withIntValue:FREEMIUM_MODE_REGISTERFORPERFORMANCE];
        [theApp.pages jumpToPage:@"COMPLETEFREEMIUM" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:YES];
    }
}

-(void) onBack:(UIButton *)btn {
    [theApp.pages goBack];
}

@end
