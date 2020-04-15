//
//  PageGroupInvoicereq.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupInvoicereq.h"
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

@interface PageGroupInvoicereq ()

@end

@implementation PageGroupInvoicereq

@synthesize vHeader, svContent, vDelete;

-(BOOL)onPreloadPage:(PageContext *)context {
    NSInteger invoicereqId = [context intParamByName:@"invoicereqId"];
    if (invoicereqId == 0) {
        invoicereq = [[Invoicereq alloc] init];
        return NO;
    } else {
        [theApp showBlockView];
        [WSDataManager getInvoicereq:invoicereqId withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
           [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                self->invoicereq = [[Invoicereq alloc] initWithDictionary:result];
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

    [self loadNIB:@"PageGroupInvoicereq"];

    _ctx = context;
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Facturas";
    
    [Utils setOnClick:self.vHeaderEdit.btnSave withBlock:^(UIView *sender) {
        [self save];
    }];
    
    FBItem * item;
    fm1 = [[FormBuilder alloc] init];
    item = [[FBItem alloc] init:@"Solicitud de factura" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    
    item = [[FBItem alloc] init:@"Descripción" fieldType:FIELD_TYPE_TEXT fieldName:@"description"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Ciudad actuación" fieldType:FIELD_TYPE_TEXT fieldName:@"performance_city"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Fecha actuación" fieldType:FIELD_TYPE_DATE fieldName:@"performance_date"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];

    item = [[FBItem alloc] init:@"Datos facturación de tu cliente" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Persona contacto" fieldType:FIELD_TYPE_TEXT fieldName:@"contact_name"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Email contacto" fieldType:FIELD_TYPE_TEXT fieldName:@"contact_email"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"CIF/NIF" fieldType:FIELD_TYPE_TEXT fieldName:@"nif"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Dirección" fieldType:FIELD_TYPE_TEXT fieldName:@"address"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Cód. postal" fieldType:FIELD_TYPE_TEXT fieldName:@"postcode"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Ciudad" fieldType:FIELD_TYPE_TEXT fieldName:@"city"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Caché (sin IVA)" fieldType:FIELD_TYPE_DOUBLE fieldName:@"netamount"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    
    Group * curGroup = theApp.appSession.currentGroup;
    // % miembros
    [invoicereq fillInDistributionForForm:curGroup.performers];
    item = [[FBItem alloc] init:@"Distribución entre los miembros (%)" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    //int part = 100 / curGroup.performers.size();
    //int last = part + (100-part*curGroup.performers.size());
    for (int i=0;i<curGroup.performers.count;i++) {
        Performer * p = curGroup.performers[i];
        /*
        if (i == (curGroup.performers.size()-1)) {
            setObjectValue(invoicereq, "percent" + i, (Integer)last);
        } else {
            setObjectValue(invoicereq, "percent" + i, (Integer)part);
        }*/
        item = [[FBItem alloc] init:[NSString stringWithFormat:@"%% %@ %@", p.name, p.surname] fieldType:FIELD_TYPE_PERCENT fieldName:[NSString stringWithFormat:@"percent%d", i]];
        item.minValueText = @"Sin participación";
        [fm1 add:item];
    }
    // Documentación miembros
    item = [[FBItem alloc] init:@"Documentación para los miembros" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    for (int i=0;i<curGroup.performers.count;i++) {
        Performer * p = curGroup.performers[i];
        
        item = [[FBItem alloc] init:[NSString stringWithFormat:@"%@ %@", p.name, p.surname] fieldType:FIELD_TYPE_LONGMULTISELECT fieldName:[NSString stringWithFormat:@"documents%d", i]];
        item.valuesIndex = @"PERFORMANCE_DOCUMENTS_OPTIONS";
        [fm1 add:item];
    }

    int height = [fm1 fillInForm:svContent from:0 withData:invoicereq];
    
    self.svContent.contentSize = CGSizeMake(0, height+20);
    
    // Eliminar invoicereq
    // Si es nuevo, no lo podemos eliminar
    if (invoicereq._id == 0 || ![invoicereq.status isEqualToString:@"NEW"]) {
        self.vDelete.hidden = YES;
        CGRect fr = self.svContent.frame;
        fr.size.height += self.vDelete.frame.size.height;
        self.svContent.frame = fr;
    } else {
        self.vDelete.lblLabel.text = @"Eliminar factura";
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
    [fm1 save:invoicereq];
    
    
    // Miramos que sumen el 100%
    double percent = invoicereq.percent0 + invoicereq.percent1 + invoicereq.percent2 + invoicereq.percent3 + invoicereq.percent4 +
            invoicereq.percent5 + invoicereq.percent6 + invoicereq.percent7 + invoicereq.percent8 + invoicereq.percent9;
    if (percent != 100) {
        [theApp MessageBox:@"La distribución entre miembros deben sumar el 100%"];
        return;
    }
    if (invoicereq._id == 0) {
        [theApp showBlockView];
        invoicereq.group_id = theApp.appSession.currentGroup._id;
        [WSDataManager addInvoicereq:invoicereq.group_id invoicereq:invoicereq withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                [theApp.pages goBack];
            } else {
                [theApp stdError:code];
            }
        }];
    } else {
        [theApp showBlockView];
        [WSDataManager updateInvoicereq:invoicereq withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
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
    [theApp QueryMessage:@"¿Seguro que quieres eliminar esta factura?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            [theApp showBlockView];
            [WSDataManager removeInvoicereq:self->invoicereq withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
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
