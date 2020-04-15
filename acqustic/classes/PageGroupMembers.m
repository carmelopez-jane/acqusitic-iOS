//
//  PageGroupMembers.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupMembers.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "Performer.h"
#import "Group.h"
#import "WSDataManager.h"
#import "MenuItem.h"
#import "FormItemSubitem.h"
#import "UIImageView+AFNetworking.h"
#import "FormBuilder.h"
#import "FormItemHeader.h"
#import "FormItemSubitem.h"
#import "Performer.h"
#import "FormItemSubnote.h"

@interface PageGroupMembers ()

@end

@implementation PageGroupMembers

@synthesize vHeader, svContent, vHeaderEdit;

-(BOOL)onPreloadPage:(PageContext *)context {
    [theApp showBlockView];
    NSInteger groupId = theApp.appSession.currentGroup._id;
    [WSDataManager getGroup:groupId withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            Group * group = [[Group alloc] initWithDictionary:result];
            theApp.appSession.currentGroup = group;
            [self endPreloading:YES];
        } else {
            [theApp stdError:code];
            [self endPreloading:NO];
        }
    }];
    return YES;
}



-(void)onEnterPage:(PageContext *)context{
    
    [super onEnterPage:context];

    [self loadNIB:@"PageGroupMembers"];

    _ctx = context;
    
    
    items = [[NSMutableArray alloc] init];
    for (int i=0;i<theApp.appSession.currentGroup.performers.count;i++) {
        [items addObject:theApp.appSession.currentGroup.performers[i]];
    }
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Miembros";
    self.vHeaderEdit.btnSave.hidden = YES;
    
    int yPos = 0;
    
    // Añadimos los eventos
    FormItemHeader * hitems = [[FormItemHeader alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    hitems.lblLabel.text = @"Miembros";
    [Utils setOnClick:hitems.vIcon withBlock:^(UIView *sender) {
        [self addItem];
    }];
    [self.svContent addSubview:hitems];
    yPos += 55;
    FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
    [self.svContent addSubview:sep];
    yPos++;
    itemsYpos = yPos;
    [self fillInItems];
    
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}

-(void) fillInItems {
    if (itemsList != nil) {
        for (int i=0;i<itemsList.count;i++) {
            [itemsList[i] removeFromSuperview];
        }
        [itemsList removeAllObjects];
    } else {
        itemsList = [[NSMutableArray alloc] init];
    }

    int yPos = itemsYpos;
    for (int i=0;i<items.count;i++) {
        if (i > 0) {
            FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
            [self.svContent addSubview:sep];
            yPos++;
        }
        Performer * s = items[i];
        FormItemSubitem * item = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,yPos, self.svContent.frame.size.width, 55)];
        item.lblLabel.text = [NSString stringWithFormat:@"%@ %@", s.name, s.surname];
        [item updateSize];
        item.tag = i;
        if ([s hasPermission:@"share"]) {
            item.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
            [Utils setOnClick:item withBlock:^(UIView *sender) {
                NSInteger index = sender.tag;
                NSInteger itemId = ((Performer *)self->items[index])._id;
                PageContext * ctx = [[PageContext alloc] init];
                [ctx addParam:@"performerId" withIntValue:itemId];
                [theApp.pages jumpToPage:@"GROUPMEMBER" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }];
        } else {
            item.ivIcon.image = [UIImage imageNamed:@"icon_permission.png"];
            [Utils setOnClick:item withBlock:^(UIView *sender) {
                NSInteger index = sender.tag;
                //NSInteger itemId = ((Performer *)self->items[index])._id;
                [self askForPermission:index];
            }];
        }
        [self.svContent addSubview:item];
        yPos += 55;
    }
    
    
    FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
    [self.svContent addSubview:sep];
    yPos++;
    yPos += 20;
    FormItemSubnote * subnote = [[FormItemSubnote alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    subnote.lblLabel.text = @"Pulsa el botón + para añadir un nuevo miembro a la formación.";
    [subnote updateSize];
    [self.svContent addSubview:subnote];
    yPos += subnote.frame.size.height;
    

    self.svContent.contentSize = CGSizeMake(0, yPos+20);
}

-(void) addItem {
    [theApp Prompt:@"Indica el email del nuevo miembro" defaultText:@"" withYes:@"Añadir miembro" andNo:@"Cancelar" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            NSString * email = (NSString *)data;
            if (!email)
                email = @"";
            email = [email stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
            if (![email isEqualToString:@""] && [Utils isValidEmail:email]) {
                [WSDataManager addGroupMemberByMail:theApp.appSession.currentGroup._id email:email withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                    if (code == WS_SUCCESS) {
                        theApp.appSession.currentGroup = [[Group alloc] initWithDictionary:result];
                        // Recargamos la página
                        [theApp.pages jumpToPage:@"GROUPMEMBERS" withContext:[self->_ctx clone]];
                    } else if (code == WS_ERROR_USERNOTFOUND) {
                        [theApp QueryMessage:@"Este email no está registrado como usuario de Acqustic. ¿Quieres darlo de alta tú mismo?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
                            if (command == POPUP_CMD_YES) {
                                // Ahora creamos el miembro...
                                PageContext * pc = [[PageContext alloc] init];
                                [pc addParam:@"performerId" withIntValue:0];
                                [pc addParam:@"email" withValue:email];
                                [theApp.pages jumpToPage:@"GROUPMEMBER" withContext:pc withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
                            }
                        }];
                    } else {
                        [theApp stdError:code];
                    }
                }];
            } else {
                [theApp MessageBox:@"Por favor, introduce un email válido"];
            }
        }
    }];
}

-(void) askForPermission:(int)index {
    Performer * p = (Performer *)self->items[index];
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
@end
