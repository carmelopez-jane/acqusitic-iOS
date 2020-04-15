//
//  PageGroupAgenda.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupAgenda.h"
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
#import "FormAgendaitem.h"
#import "FormItemSubnote.h"

@interface PageGroupAgenda ()

@end

@implementation PageGroupAgenda

@synthesize vHeader, svContent, vHeaderEdit;

-(BOOL)onPreloadPage:(PageContext *)context {
    [theApp showBlockView];
    [WSDataManager getGroupAgenda:theApp.appSession.currentGroup._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            NSArray * items = (NSArray *)result;
            self->events = [[NSMutableArray alloc] init];
            for (int i=0;i<items.count;i++) {
                NSDictionary * evData = items[i];
                [self->events addObject:[[Agendaitem alloc] initWithDictionary:evData]];
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

    [self loadNIB:@"PageGroupAgenda"];

    _ctx = context;
    
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Agenda";
    self.vHeaderEdit.btnSave.hidden = YES;
    
    int yPos = 0;
    
    // Añadimos los eventos
    FormItemHeader * hEvents = [[FormItemHeader alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    hEvents.lblLabel.text = @"Próximos eventos de mi agenda";
    [Utils setOnClick:hEvents.vIcon withBlock:^(UIView *sender) {
        [self addItem];
    }];
    [self.svContent addSubview:hEvents];
    yPos += 55;
    FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
    [self.svContent addSubview:sep];
    yPos++;
    eventsYpos = yPos;
    [self fillInEvents];
    
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}

-(void) fillInEvents {
    if (eventsList != nil) {
        for (int i=0;i<eventsList.count;i++) {
            [eventsList[i] removeFromSuperview];
        }
        [eventsList removeAllObjects];
    } else {
        eventsList = [[NSMutableArray alloc] init];
    }

    int yPos = eventsYpos;
    for (int i=0;i<events.count;i++) {
        if (i > 0) {
            FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
            [self.svContent addSubview:sep];
            yPos++;
        }
        Agendaitem * s = events[i];
        FormAgendaitem * item = [[FormAgendaitem alloc] initWithFrame:CGRectMake(0,yPos, self.svContent.frame.size.width, 55)];
        item.lblLabel.text = s.description;
        item.lblDate.text = [Utils formatDate:s.performance_date];
        item.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
        item.tag = i;
        [Utils setOnClick:item withBlock:^(UIView *sender) {
            NSInteger index = sender.tag;
            NSInteger eventId = ((Agendaitem *)self->events[index])._id;
            PageContext * ctx = [[PageContext alloc] init];
            [ctx addParam:@"agendaitemId" withIntValue:eventId];
            [theApp.pages jumpToPage:@"GROUPAGENDAITEM" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
        }];
        [self.svContent addSubview:item];
        yPos += 55;
    }
    
    
    FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
    [self.svContent addSubview:sep];
    yPos++;
    yPos += 20;
    FormItemSubnote * subnote = [[FormItemSubnote alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    subnote.lblLabel.text = @"Pulsa el botón + para añadir un nuevo concierto en tu agenda.";
    [subnote updateSize];
    [self.svContent addSubview:subnote];
    yPos += subnote.frame.size.height;
    

    self.svContent.contentSize = CGSizeMake(0, yPos+20);
}

-(void) addItem {
    PageContext * ctx = [[PageContext alloc] init];
    [ctx addParam:@"agendaitemId" withIntValue:0];
    [theApp.pages jumpToPage:@"GROUPAGENDAITEM" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
}

@end
