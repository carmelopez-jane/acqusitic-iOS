//
//  PageGroupInvoicereqs.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupInvoicereqs.h"
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
#import "FormInvoicereq.h"
#import "FormItemSubnote.h"

@interface PageGroupInvoicereqs ()

@end

@implementation PageGroupInvoicereqs

@synthesize vHeader, svContent, vHeaderEdit;

-(BOOL)onPreloadPage:(PageContext *)context {
    [theApp showBlockView];
    [WSDataManager getInvoicereqs:theApp.appSession.currentGroup._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            NSArray * items = (NSArray *)result;
            self->items = [[NSMutableArray alloc] init];
            for (int i=0;i<items.count;i++) {
                NSDictionary * evData = items[i];
                [self->items addObject:[[Invoicereq alloc] initWithDictionary:evData]];
            }
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

    [self loadNIB:@"PageGroupInvoicereqs"];

    _ctx = context;
    
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Facturas";
    self.vHeaderEdit.btnSave.hidden = YES;
    
    int yPos = 0;
    
    // Añadimos los eventos
    FormItemHeader * hitems = [[FormItemHeader alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    hitems.lblLabel.text = @"Facturas solicitadas";
    [Utils setOnClick:hitems.vIcon withBlock:^(UIView *sender) {
        [self addItem];
    }];
    yPos += 55;
    [self.svContent addSubview:hitems];
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
        Invoicereq * s = items[i];
        FormInvoicereq * item = [[FormInvoicereq alloc] initWithFrame:CGRectMake(0,yPos, self.svContent.frame.size.width, 55)];
        item.lblLabel.text = s.description;
        item.lblDate.text = [Utils formatDateOnly:s.performance_date];
        item.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
        item.tag = i;
        if ([s.status isEqualToString:@"NEW"]) {
            item.lblStatus.text = @"Pendiente revisión";
            item.lblStatus.backgroundColor = [Utils uicolorFromARGB:0xFF9b9b9b];
            [Utils setOnClick:item withBlock:^(UIView *sender) {
                NSInteger index = sender.tag;
                NSInteger itemId = ((Invoicereq *)self->items[index])._id;
                PageContext * ctx = [[PageContext alloc] init];
                [ctx addParam:@"invoicereqId" withIntValue:itemId];
                [theApp.pages jumpToPage:@"GROUPINVOICEREQ" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }];
        } else if ([s.status isEqualToString:@"REVIEWED"] || [s.status isEqualToString:@"SENT"] || [s.status isEqualToString:@"OVERDUE"] || [s.status isEqualToString:@"PAID"]) {
            item.lblStatus.text = @"En proceso";
            item.lblStatus.backgroundColor = [Utils uicolorFromARGB:0xFF9b9b9b];
        } else if ([s.status isEqualToString:@"SETTLED"]) {
            item.lblStatus.text = @"Pagada";
            item.lblStatus.backgroundColor = [Utils uicolorFromARGB:0xFF20b2a9];
        } else if ([s.status isEqualToString:@"CANCELLED"]) {
            item.lblStatus.text = @"Cancelada";
            item.lblStatus.backgroundColor = [Utils uicolorFromARGB:0xFFed7676];
        }
        [self.svContent addSubview:item];
        yPos += 55;
    }
    
    FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
    [self.svContent addSubview:sep];
    yPos++;
    yPos += 20;
    FormItemSubnote * subnote = [[FormItemSubnote alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    subnote.lblLabel.text = @"Pulsa el botón + para solicitar una nueva factura externa a Acqustic. Podrás editar tus solicitudes de factura hasta que éstas sean aprobadas y tramitadas. Pasado ese momento, para hacer cambios deberás ponerte en contacto directamente con Acqustic.";
    [subnote updateSize];
    [self.svContent addSubview:subnote];
    yPos += subnote.frame.size.height;
    
    self.svContent.contentSize = CGSizeMake(0, yPos+20);
}

-(void) addItem {
    PageContext * pc = [[PageContext alloc] init];
    [pc addParam:@"invoicereqId" withIntValue:0];
    [theApp.pages jumpToPage:@"GROUPINVOICEREQ" withContext:pc withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
}

@end
