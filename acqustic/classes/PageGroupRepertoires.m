//
//  PageGroupRepertoires.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupRepertoires.h"
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
#import "Repertoire.h"
#import "AppDelegate.h"
#import "FormItemSubnote.h"

@interface PageGroupRepertoires ()

@end

@implementation PageGroupRepertoires

@synthesize vHeader, svContent, vHeaderEdit;

-(BOOL)onPreloadPage:(PageContext *)context {
    [theApp showBlockView];
    [WSDataManager getGroupRepertoires:theApp.appSession.currentGroup._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            NSArray * items = (NSArray *)result;
            self->items = [[NSMutableArray alloc] init];
            for (int i=0;i<items.count;i++) {
                NSDictionary * evData = items[i];
                [self->items addObject:[[Repertoire alloc] initWithDictionary:evData]];
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

    [self loadNIB:@"PageGroupRepertoires"];

    _ctx = context;
    
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Repertorios";
    self.vHeaderEdit.btnSave.hidden = YES;
    
    int yPos = 0;
    
    // Añadimos los eventos
    FormItemHeader * hitems = [[FormItemHeader alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    hitems.lblLabel.text = @"Repertorios";
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
        Repertoire * s = items[i];
        FormItemSubitem * item = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,yPos, self.svContent.frame.size.width, 55)];
        item.lblLabel.text = s.title;
        item.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
        [item updateSize];
        item.tag = i;
        [Utils setOnClick:item withBlock:^(UIView *sender) {
            NSInteger index = sender.tag;
            NSInteger itemId = ((Repertoire *)self->items[index])._id;
            PageContext * ctx = [[PageContext alloc] init];
            [ctx addParam:@"repertoireId" withIntValue:itemId];
            [theApp.pages jumpToPage:@"GROUPREPERTOIRE" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
        }];
        [self.svContent addSubview:item];
        yPos += 55;
    }
    
    
    FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
    [self.svContent addSubview:sep];
    yPos++;
    yPos += 20;
    FormItemSubnote * subnote = [[FormItemSubnote alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    subnote.lblLabel.text = @"Pulsa el botón + para añadir un nuevo repertorio en este grupo. Ejemplo: Repertorio acústico";
    [subnote updateSize];
    [self.svContent addSubview:subnote];
    yPos += subnote.frame.size.height;
    

    self.svContent.contentSize = CGSizeMake(0, yPos+20);
}

-(void) addItem {
    // Ahora creamos el repertorio
    [theApp Prompt:@"Indica un nombre para el nuevo repertorio" defaultText:@"" withYes:@"Crear repertorio" andNo:@"Cancelar" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            NSString * name = (NSString *)data;
            Repertoire * newRep = [[Repertoire alloc] init];
            if (name == nil)
                name = @"";
            name = [name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
            newRep.title = name;
            if (![name isEqualToString:@""]) {
                [WSDataManager addGroupRepertoire:theApp.appSession.currentGroup._id repertoire:newRep withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                    if (code == WS_SUCCESS) {
                        NSInteger repertoireId = [result[@"id"] integerValue];
                        PageContext * pc = [[PageContext alloc] init];
                        [pc addParam:@"repertoireId" withIntValue:repertoireId];
                        [theApp.pages jumpToPage:@"GROUPREPERTOIRE" withContext:pc withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
                    } else {
                        [theApp stdError:code];
                    }
                }];
            }
        }
    }];
}

@end
