//
//  PageGroupMember.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupMember.h"
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

@interface PageGroupMember ()

@end

@implementation PageGroupMember

@synthesize vHeader, svContent, vDelete;

-(BOOL)onPreloadPage:(PageContext *)context {
    PageGroupMember * refThis = self;
    NSInteger groupId = theApp.appSession.currentGroup._id;
    NSInteger memberId = [context intParamByName:@"performerId"];
    if (memberId != 0) {
        [theApp showBlockView];
        [WSDataManager getGroupMember:groupId memberId:memberId withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                self->performer = [[Performer alloc] initWithDictionary:result];
                //[refThis setBadges:badges];
                [refThis endPreloading:YES];
            } else {
                [theApp stdError:code];
                [refThis endPreloading:NO];
            }
        }];
        return YES;
    } else {
        self->performer = [[Performer alloc] init];
        self->performer.email = [context paramByName:@"email"];
        return NO;
    }
}

-(void)onEnterPage:(PageContext *)context{
    
    [super onEnterPage:context];

    [self loadNIB:@"PageGroupMember"];

    _ctx = context;

    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Perfil";
    
    [Utils setOnClick:self.vHeaderEdit.btnSave withBlock:^(UIView *sender) {
        [self save];
    }];
    
    FBItem * item;
    fm1 = [[FormBuilder alloc] init];
    item = [[FBItem alloc] init:@"Información básica" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Nombre" fieldType:FIELD_TYPE_TEXT fieldName:@"name"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Apellidos" fieldType:FIELD_TYPE_TEXT fieldName:@"surname"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Teléfono" fieldType:FIELD_TYPE_TEXT fieldName:@"telephone"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [item addValidator:[[FBTelephoneValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Email" fieldType:FIELD_TYPE_TEXT fieldName:@"email"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [item addValidator:[[FBEmailValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Ciudad" fieldType:FIELD_TYPE_TEXT fieldName:@"city"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Provincia" fieldType:FIELD_TYPE_SELECT fieldName:@"province"];
    item.valuesIndex = @"PROVINCE_OPTIONS";
    [fm1 add:item];

    item = [[FBItem alloc] init:@"Datos de facturación" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"DNI" fieldType:FIELD_TYPE_NIF fieldName:@"ia_nif"];
    [item addValidator:[[FBCIFValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Imagen frontal DNI" fieldType:FIELD_TYPE_IMAGE fieldName:@"ia_nif_front_image"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Imagen trasera DNI" fieldType:FIELD_TYPE_IMAGE fieldName:@"ia_nif_back_image"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Fecha de nacimiento" fieldType:FIELD_TYPE_DATE fieldName:@"ia_birthDate"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Dirección" fieldType:FIELD_TYPE_TEXT fieldName:@"ia_address"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Ciudad" fieldType:FIELD_TYPE_TEXT fieldName:@"ia_city"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Código postal" fieldType:FIELD_TYPE_TEXT fieldName:@"ia_postcode"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Nº seguridad social" fieldType:FIELD_TYPE_TEXT fieldName:@"ia_ssnumber"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Nº de cuenta IBAN" fieldType:FIELD_TYPE_TEXT fieldName:@"ia_IBAN"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"% retención IRPF" fieldType:FIELD_TYPE_TEXT fieldName:@"ia_IRPF"];
    item.minValue = 2; item.maxValue = 53;
    [fm1 add:item];

    int height = [fm1 fillInForm:svContent from:0 withData:performer];
    
    self.svContent.contentSize = CGSizeMake(0, height+20);
    
    self.vDelete.lblLabel.text = @"Eliminar miembro del grupo";
    [Utils setOnClick:self.vDelete.lblLabel withBlock:^(UIView *sender) {
        [self deleteItem];
    }];

}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    PageContext * ctx = [_ctx clone];
    ctx.cachePage = YES;
    return ctx;
}

-(void) save {
    NSString * res = [fm1 validate];
    if (res != nil) {
        [theApp MessageBox:res];
        return;
    }
    [fm1 save:performer];
    
    if (performer._id == 0) {
        [theApp showBlockView];
        [WSDataManager createGroupMember:theApp.appSession.currentGroup._id performer:performer withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                [theApp.pages goBack];
            } else {
                [theApp stdError:code];
            }
        }];
    } else {
        [theApp showBlockView];
        [WSDataManager updateGroupMember:theApp.appSession.currentGroup._id performer:performer withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
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
    [theApp QueryMessage:@"¿Seguro que quieres eliminar este miembro del grupo?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            [theApp showBlockView];
            [WSDataManager removeGroupMember:theApp.appSession.currentGroup._id performer:self->performer withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
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
