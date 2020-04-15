//
//  PageUser.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageUser.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "Performer.h"
#import "Group.h"
#import "WSDataManager.h"
#import "MenuItem.h"
#import "FormItemSubitem.h"
#import "UIImageView+AFNetworking.h"

@interface PageUser ()

@end

@implementation PageUser

@synthesize vHeader, svContent;

-(BOOL)onPreloadPage:(PageContext *)context {
    PageUser * refThis = self;
    [theApp showBlockView];
    [WSDataManager getProfile:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [self setBadges:badges];
            theApp.appSession.performerProfile = [[Performer alloc] initWithDictionary:result];
            //[refThis setBadges:badges];
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

    [self loadNIB:@"PageUser"];

    _ctx = context;

    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    [self setupBadges:vHeader];
    
    self.lblName.text = theApp.appSession.performerProfile.name;
    Group * firstGroup = theApp.appSession.performerProfile.groups[0];
    self.lblGroup.text = firstGroup.name;
    // FALTA AVATAR...
    
    self.hGroups.lblLabel.text = @"Grupos";
    [Utils setOnClick:self.hGroups.vIcon withBlock:^(UIView *sender) {
        [self newGroup];
    }];
    
    self.vDelete.lblLabel.text = @"Cerrar sesión";
    [Utils setOnClick:self.vDelete.lblLabel withBlock:^(UIView *sender) {
        [theApp QueryMessage:@"¿Seguro que quieres cerrar la sesión?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
            if (command == POPUP_CMD_YES) {
                [theApp.appSession loggedOut];
                [theApp jumpToStart:NO];
            }
        }];
    }];
    
    [self fillInGroupsAndMenu];
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}

-(void) fillInGroupsAndMenu {
    int yTop = self.sepGroups.frame.origin.y+2;
    // Grupos
    for (int i=0;i<theApp.appSession.performerProfile.groups.count;i++) {
        Group * g = theApp.appSession.performerProfile.groups[i];
        FormItemSubitem * item = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,yTop, self.svContent.frame.size.width, 55)];
        item.lblLabel.text = g.name;
        [item updateSize];
        item.tag = i;
        if ([g hasPermission:@"share"]) {
            item.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
            [Utils setOnClick:item withBlock:^(UIView *sender) {
                [self goToGroup:sender.tag];
            }];
        } else {
            item.ivIcon.image = [UIImage imageNamed:@"icon_permission.png"];
            [Utils setOnClick:item withBlock:^(UIView *sender) {
                [self askPermissionForGroup:sender.tag];
            }];
        }
        [self.svContent addSubview:item];
        yTop += 55;
        FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.width, 1)];
        [self.svContent addSubview:sep];
        yTop++;
    }
    // Opciones de menú
    MenuItem * mi;
    yTop += 20;
    // Información básica
    mi = [[MenuItem alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.height, 55)];
    mi.lblLabel.text = @"Información básica";
    [Utils setOnClick:mi withBlock:^(UIView *sender) {
        [theApp.pages jumpToPage:@"USERPROFILE" withContext:nil withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
    }];
    [self.svContent addSubview:mi];
    yTop += 55;
    // Contacta con Acqustic
    mi = [[MenuItem alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.height, 55)];
    mi.lblLabel.text = @"Contacta con Acqustic";
    [Utils setOnClick:mi withBlock:^(UIView *sender) {
        [theApp.pages jumpToPage:@"CHATS" withContext:nil withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
    }];
    [self.svContent addSubview:mi];
    yTop += 55;
    // Subir canción a Spotify y otros
    mi = [[MenuItem alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.height, 55)];
    mi.lblLabel.text = @"Subir canción a Spotify y otros";
    [Utils setOnClick:mi withBlock:^(UIView *sender) {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://acqustic.typeform.com/to/npXTRR"]];
    }];
    [self.svContent addSubview:mi];
    yTop += 55;
    //Cambiar contraseña
    mi = [[MenuItem alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.height, 55)];
    mi.lblLabel.text = @"Cambiar contraseña";
    [Utils setOnClick:mi withBlock:^(UIView *sender) {
        [theApp.pages jumpToPage:@"USERPASSWORD" withContext:nil withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
    }];
    [self.svContent addSubview:mi];
    yTop += 55;
    // Gestionar suscripción
    mi = [[MenuItem alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.height, 55)];
    mi.lblLabel.text = @"Gestionar suscripción";
    [Utils setOnClick:mi withBlock:^(UIView *sender) {
        [theApp.pages jumpToPage:@"USERSUBSCRIPTION" withContext:nil withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
    }];
    [self.svContent addSubview:mi];
    yTop += 55;
    // Términos y condiciones
    mi = [[MenuItem alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.height, 55)];
    mi.lblLabel.text = @"Términos y condiciones";
    [Utils setOnClick:mi withBlock:^(UIView *sender) {
        PageContext * ctx = [[PageContext alloc] init];
        [ctx addParam:@"title" withValue:@"Términos y condiciones"];
        [ctx addParam:@"content" withValue:@"legal"];
        [theApp.pages jumpToPage:@"WEB" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
    }];
    [self.svContent addSubview:mi];
    yTop += 55;
    // Política de privacidad
    mi = [[MenuItem alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.height, 55)];
    mi.lblLabel.text = @"Política de privacidad";
    [Utils setOnClick:mi withBlock:^(UIView *sender) {
        PageContext * ctx = [[PageContext alloc] init];
        [ctx addParam:@"title" withValue:@"Política de privacidad"];
        [ctx addParam:@"content" withValue:@"privacy"];
        [theApp.pages jumpToPage:@"WEB" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
    }];
    [self.svContent addSubview:mi];
    yTop += 55;

    
    
    // Añadimos la versión
    yTop += 20;
    CGRect fr = self.lblVersion.frame;
    fr.origin.y = yTop;
    self.lblVersion.frame = fr;
    NSString * version = [AppDelegate getAppVersion];
    self.lblVersion.text = version;


    // Actualizamos el scroll...
    self.svContent.contentSize = CGSizeMake(0, yTop+20);
}

-(void) newGroup {
    [theApp Prompt:@"Indica un nombre para el nuevo grupo" defaultText:@"" withYes:@"Crear grupo" andNo:@"Cancelar" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            NSString * name = (NSString *)data;
            name = [name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            if (![name isEqualToString:@""]) {
                [theApp showBlockView];
                [WSDataManager newGroup:name withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                    [theApp hideBlockView];
                    if (code == WS_SUCCESS) {
                        NSInteger groupId = [result[@"id"] integerValue];
                        PageContext * ctx = [[PageContext alloc] init];
                        [ctx addParam:@"groupId" withIntValue:groupId];
                        [theApp.pages jumpToPage:@"GROUP" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
                    } else {
                        [theApp stdError:code];
                    }
                }];
            }
        }
    }];
}

-(void) goToGroup:(NSInteger)index {
    Group * g = theApp.appSession.performerProfile.groups[index];
    PageContext * ctx = [[PageContext alloc] init];
    [ctx addParam:@"groupId" withIntValue:g._id];
    [theApp.pages jumpToPage:@"GROUP" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
}

-(void) askPermissionForGroup:(NSInteger)index {
    Group * g = theApp.appSession.performerProfile.groups[index];
    NSString * msg = [NSString stringWithFormat:@"En este momento no tienes permiso para acceder a los datos de %@. ¿Quieres solicitar al gestor del grupo permiso para acceder?", g.name];
    [theApp QueryMessage:msg withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            [WSDataManager requestSharePermissionGroupProfile:g._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                if (code == WS_SUCCESS) {
                    NSString * msg = [NSString stringWithFormat:@"Hemos enviado la solicitud al gestor de %@. Si te da permiso, podrás acceder a sus datos.", g.name];
                    [theApp MessageBox:msg];
                } else {
                    [theApp stdError:code];
                }
            }];
        }
    }];
}
@end
