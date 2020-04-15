//
//  PageGroupAlbums.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupAlbums.h"
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

@interface PageGroupAlbums ()

@end

@implementation PageGroupAlbums

@synthesize vHeader, svContent, vHeaderEdit;

-(BOOL)onPreloadPage:(PageContext *)context {
    [theApp showBlockView];
    [WSDataManager getGroupAlbums:theApp.appSession.currentGroup._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            NSArray * items = (NSArray *)result;
            self->items = [[NSMutableArray alloc] init];
            for (int i=0;i<items.count;i++) {
                NSDictionary * evData = items[i];
                [self->items addObject:[[Album alloc] initWithDictionary:evData]];
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

    [self loadNIB:@"PageGroupAlbums"];

    _ctx = context;
    
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Álbums";
    self.vHeaderEdit.btnSave.hidden = YES;
    
    int yPos = 0;
    
    // Añadimos los eventos
    FormItemHeader * hitems = [[FormItemHeader alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    hitems.lblLabel.text = @"Álbums en streaming";
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
        Album * s = items[i];
        FormInvoicereq * item = [[FormInvoicereq alloc] initWithFrame:CGRectMake(0,yPos, self.svContent.frame.size.width, 55)];
        item.lblLabel.text = s.title;
        item.lblDate.text = [Utils formatDateOnly:s.publish_date];
        item.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
        item.tag = i;
        if (s.status != nil && [s.status isEqualToString:@"NEW"]) {
            item.lblStatus.text = @"Pendiente revisión";
            item.lblStatus.backgroundColor = [Utils uicolorFromARGB:0xFF9b9b9b];
            [Utils setOnClick:item withBlock:^(UIView *sender) {
                NSInteger index = sender.tag;
                NSInteger itemId = ((Album *)self->items[index])._id;
                PageContext * ctx = [[PageContext alloc] init];
                [ctx addParam:@"albumId" withIntValue:itemId];
                [theApp.pages jumpToPage:@"GROUPALBUM" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }];
        } else if (s.status != nil && [s.status isEqualToString:@"PUBLISHED"]) {
            item.lblStatus.text = @"Publicado";
            item.lblStatus.backgroundColor = [Utils uicolorFromARGB:0xFF20b2a9];
        } else {
            item.lblStatus.text = @"En proceso";
            item.lblStatus.backgroundColor = [Utils uicolorFromARGB:0xFF9b9b9b];
            item.ivIcon.hidden = YES;
        }
        [self.svContent addSubview:item];
        yPos += 55;
    }
    
    
    FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
    [self.svContent addSubview:sep];
    yPos++;
    yPos += 20;
    FormItemSubnote * subnote = [[FormItemSubnote alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    subnote.lblLabel.text = @"Pulsa el botón + para añadir un nuevo álbum o single y distribuirlo en Spotify, Apple Music y otras más de 30 plataformas. Si vas a subir un single añade como título del álbum el nombre del single.";
    [subnote updateSize];
    [self.svContent addSubview:subnote];
    yPos += subnote.frame.size.height;
    

    self.svContent.contentSize = CGSizeMake(0, yPos+20);
}

-(void) addItem {
    // Ahora creamos el repertorio
    [theApp Prompt:@"Indica un nombre para el nuevo álbum" defaultText:@"" withYes:@"Crear álbum" andNo:@"Cancelar" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            NSString * name = (NSString *)data;
            Album * newAlbum = [[Album alloc] init];
            if (name == nil)
                name = @"";
            name = [name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
            newAlbum.title = name;
            if (![name isEqualToString:@""]) {
                [WSDataManager addGroupAlbum:theApp.appSession.currentGroup._id album:newAlbum withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                    if (code == WS_SUCCESS) {
                        NSInteger repertoireId = [result[@"id"] integerValue];
                        PageContext * pc = [[PageContext alloc] init];
                        [pc addParam:@"albumId" withIntValue:repertoireId];
                        [theApp.pages jumpToPage:@"GROUPALBUM" withContext:pc withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
                    } else {
                        [theApp stdError:code];
                    }
                }];
            }
        }
    }];

}

@end
