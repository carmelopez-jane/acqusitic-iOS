//
//  PageGroupAgendaItem.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupAgendaItem.h"
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

@interface PageGroupAgendaItem ()

@end

@implementation PageGroupAgendaItem

@synthesize vHeader, svContent, vDelete;

-(BOOL)onPreloadPage:(PageContext *)context {
    NSInteger itemId = [context intParamByName:@"agendaitemId"];
    if (itemId == 0) {
        agendaitem = [[Agendaitem alloc] init];
        return NO;
    } else {
        [theApp showBlockView];
        [WSDataManager getAgendaItem:itemId withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                self->agendaitem = [[Agendaitem alloc] initWithDictionary:result];
                [self endPreloading:YES];
            } else {
                [theApp stdError:code];
                [self endPreloading:NO];
            }
        }];
        return YES;
    }
}

-(void)onEnterPage:(PageContext *)context{
    
    [super onEnterPage:context];

    [self loadNIB:@"PageGroupAgendaItem"];

    _ctx = context;
    
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Evento de Agenda";
    
    [Utils setOnClick:self.vHeaderEdit.btnSave withBlock:^(UIView *sender) {
        [self save];
    }];
    
    FBItem * item;
    fm1 = [[FormBuilder alloc] init];
    item = [[FBItem alloc] init:@"Evento propio de agenda" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Descripción" fieldType:FIELD_TYPE_TEXT fieldName:@"description"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Fecha y hora" fieldType:FIELD_TYPE_DATETIME fieldName:@"performance_date"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Tipo" fieldType:FIELD_TYPE_SELECT fieldName:@"type"];
    item.valuesIndex = @"AGENDAITEMTYPE_OPTIONS";
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Nombre local" fieldType:FIELD_TYPE_TEXT fieldName:@"venue"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Dirección" fieldType:FIELD_TYPE_TEXT fieldName:@"address"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Código postal" fieldType:FIELD_TYPE_TEXT fieldName:@"postcode"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Ciudad" fieldType:FIELD_TYPE_TEXT fieldName:@"city"];
    [fm1 add:item];


    int height = [fm1 fillInForm:svContent from:0 withData:agendaitem];
    
    self.svContent.contentSize = CGSizeMake(0, height+20);
    
    // Si es nuevo, no lo podemos eliminar
    if (agendaitem._id == 0) {
        self.vDelete.hidden = YES;
        CGRect fr = self.svContent.frame;
        fr.size.height += self.vDelete.frame.size.height;
        self.svContent.frame = fr;
    } else {
        self.vDelete.lblLabel.text = @"Eliminar evento de agenda";
        [Utils setOnClick:self.vDelete.lblLabel withBlock:^(UIView *sender) {
            [self deleteItem];
        }];
    }
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}

-(void) save {
    NSString * res = [fm1 validate];
    if (res != nil) {
        [theApp MessageBox:res];
        return;
    }
    [fm1 save:agendaitem];
    
    if (agendaitem._id == 0) {
        [theApp showBlockView];
        agendaitem.group_id = theApp.appSession.currentGroup._id;
        [WSDataManager addAgendaitem:agendaitem.group_id agendaitem:agendaitem withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                [theApp.pages goBack];
            } else {
                [theApp stdError:code];
            }
        }];
    } else {
        [theApp showBlockView];
        [WSDataManager updateAgendaitem:agendaitem withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                [theApp.pages goBack];
            } else {
                [theApp stdError:code];
            }
        }];
    }
}

-(void) deleteItem {
    [theApp QueryMessage:@"¿Seguro que quieres eliminar este evento?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            [theApp showBlockView];
            [WSDataManager removeAgendaitem:self->agendaitem withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                [theApp hideBlockView];
                if (code == WS_SUCCESS) {
                    [theApp.pages goBack];
                } else {
                    [theApp stdError:code];
                }
            }];
        }
    }];
}


@end
