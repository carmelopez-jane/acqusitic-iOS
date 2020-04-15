//
//  PageUserProfile.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageUserProfile.h"
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

@interface PageUserProfile ()

@end

@implementation PageUserProfile

@synthesize vHeader, svContent;

-(BOOL)onPreloadPage:(PageContext *)context {
    PageUserProfile * refThis = self;
    [theApp showBlockView];
    [WSDataManager getProfile:^(int code, NSDictionary *result, NSDictionary *badges) {
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
}

-(void)onEnterPage:(PageContext *)context{
    
    [super onEnterPage:context];

    [self loadNIB:@"PageUserProfile"];

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
    item = [[FBItem alloc] init:@"Provincia" fieldType:FIELD_TYPE_SELECT fieldName:@"ia_province"];
    item.valuesIndex = @"PROVINCE_OPTIONS";
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Nº seguridad social" fieldType:FIELD_TYPE_TEXT fieldName:@"ia_ssnumber"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Nº de cuenta IBAN" fieldType:FIELD_TYPE_TEXT fieldName:@"ia_IBAN"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"% retención IRPF" fieldType:FIELD_TYPE_PERCENT fieldName:@"ia_IRPF"];
    item.minValue = 2; item.maxValue = 53;
    [fm1 add:item];

    int height = [fm1 fillInForm:svContent from:0 withData:performer];
    
    self.svContent.contentSize = CGSizeMake(0, height+20);
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
    [theApp showBlockView];
    [WSDataManager updatePerformerProfile:performer withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [theApp.pages goBack];
        } else {
            [theApp stdError:code];
        }
    }];
}


@end
