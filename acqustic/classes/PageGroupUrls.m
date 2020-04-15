//
//  PageGroupUrls.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupUrls.h"
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
#import "FormItemSubnote.h"

void (^PageGroupUrlsChanged)(NSArray * items) = nil;


@interface PageGroupUrls ()

@end

@implementation PageGroupUrls

@synthesize vHeader, svContent, vHeaderEdit;

-(void)onEnterPage:(PageContext *)context{
    
    [super onEnterPage:context];

    [self loadNIB:@"PageGroupUrls"];

    _ctx = context;
    
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = [context paramByName:@"sectionTitle"];
    
    int yPos = 0;
    
    groupId = [context intParamByName:@"groupId"];
    NSString * content = [context paramByName:@"content" withDefault:@""];

    if (content == nil || [content isEqualToString:@""]) {
        items = [[NSMutableArray alloc] init];
    } else {
        items = [NSMutableArray arrayWithArray:[content componentsSeparatedByString:@","]];
    }
    
    /*
    [pc addParam:@"sectionTitle" withValue:@"Redes"];
    [pc addParam:@"sectionSubtitle" withValue:@"Redes sociales del grupo"];
    [pc addParam:@"sectionHint" withValue:@"Pulsa el botón + para añadir un nuevo enlace a tus redes sociales como Facebook, Instagram o Twitter"];
    [pc addParam:@"itemName" withValue:@"enlace a redes sociales"];
    [pc addParam:@"content" withValue:self->group.social];
     */
    
    // Añadimos los eventos
    FormItemHeader * hitems = [[FormItemHeader alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    hitems.lblLabel.text = [context paramByName:@"sectionSubtitle"];
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

    [Utils setOnClick:vHeaderEdit.btnSave withBlock:^(UIView *sender) {
        // Guardamos los cambios...
        if (PageGroupUrlsChanged)
            PageGroupUrlsChanged(self->items);
        [theApp.pages goBack];
    }];
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
    if (footerSep)
        [footerSep removeFromSuperview];
    if (footerSubnote)
        [footerSubnote removeFromSuperview];

    int yPos = itemsYpos;
    for (int i=0;i<items.count;i++) {
        if (i > 0) {
            FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
            [self.svContent addSubview:sep];
            yPos++;
        }
        NSString * s = items[i];
        FormItemSubitem * item = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,yPos, self.svContent.frame.size.width, 55)];
        item.lblLabel.text = s;
        item.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
        item.tag = i;
        [item updateSize];
        [itemsList addObject:item];
        [Utils setOnClick:item withBlock:^(UIView *sender) {
            NSInteger index = sender.tag;
            NSString * val = self->items[index];
            [theApp Prompt:[NSString stringWithFormat:@"Nuevo %@", [_ctx paramByName:@"itemName" withDefault:@"elemento"]] defaultText:val withYes:@"Aceptar" andNo:@"Cancelar" andExtraButton:@"Eliminar" onCommand:^(Popup *pm, int command, NSObject *data) {
                if (command == POPUP_CMD_YES) {
                    self->items[index] = (NSString *)data;
                } else if (command == POPUP_CMD_LAST) { // Eliminar
                    [self->items removeObjectAtIndex:index];
                }
                [self fillInItems];
            }];
        }];
        [self.svContent addSubview:item];
        yPos += 55;
    }
    
    
    footerSep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
    [self.svContent addSubview:footerSep];
    yPos++;
    yPos += 20;
    footerSubnote = [[FormItemSubnote alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    footerSubnote.lblLabel.text = [_ctx paramByName:@"sectionHint"];
    [footerSubnote updateSize];
    [self.svContent addSubview:footerSubnote];
    yPos += footerSubnote.frame.size.height;
    
    self.svContent.contentSize = CGSizeMake(0, yPos+20);
}

-(void) addItem {
    // Ahora creamos el repertorio
    [theApp Prompt:[NSString stringWithFormat:@"Nuevo %@", [_ctx paramByName:@"itemName" withDefault:@"elemento"]] defaultText:@"" withYes:@"Añadir" andNo:@"Cancelar" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            NSString * name = (NSString *)data;
            Album * newAlbum = [[Album alloc] init];
            if (name == nil)
                name = @"";
            name = [name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
            newAlbum.title = name;
            if (![name isEqualToString:@""]) {
                [self->items addObject:name];
                [self fillInItems];
            }
        }
    }];

}

@end
