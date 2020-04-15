//
//  PageChats.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageChats.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "WSDataManager.h"
#import "FormItemHeader.h"
#import "FormItemSepfull.h"
#import "formItemSep.h"
#import "ChatItem.h"

@interface PageChats ()

@end

@implementation PageChats

@synthesize vHeader, svContent;

-(BOOL)onPreloadPage:(PageContext *)context {
    PageChats * refThis = self;
    [theApp showBlockView];
    [WSDataManager getChats:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [self setBadges:badges];
            refThis->chats = (NSArray *)result;
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

    [self loadNIB:@"PageChats"];
    [self.vHeader setActiveSection:HEADER_SECTION_CHATS];
    [self setupBadges:vHeader];
    
    _ctx = context;

    
    [self fillInInChats];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor blackColor];
    refreshControl.attributedTitle = nil;
    [refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [svContent addSubview:refreshControl];
    svContent.alwaysBounceVertical = YES;

}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}

- (void)onRefresh:(UIRefreshControl *)refreshControl {
    PageChats * refThis = self;
    //[theApp showBlockView];
    [WSDataManager getChats:^(int code, NSDictionary *result, NSDictionary *badges) {
        //[theApp hideBlockView];
        [refreshControl endRefreshing];
        if (code == WS_SUCCESS) {
            [self setBadges:badges];
            [self setupBadges:self.vHeader];
            refThis->chats = (NSArray *)result;
            [refThis endPreloading:YES];
        } else {
            [theApp stdError:code];
            [refThis endPreloading:NO];
        }
    }];
}

-(void) fillInInChats {
    [Utils cleanUpScrollView:self.svContent];
    int yTop = 0;
    // Añadimos la cabecera
    FormItemHeader * header = [[FormItemHeader alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.width, 55)];
    header.ivIcon.hidden = YES; header.vIcon.hidden = YES;
    header.lblLabel.text = @"Historial de conversación";
    [svContent addSubview:header];
    yTop += header.frame.size.height;
    FormItemSepFull * sep = [[FormItemSepFull alloc] initWithFrame:CGRectMake(15,yTop,self.svContent.frame.size.width-30, 1)];
    [svContent addSubview:sep];
    yTop++;
    // Añadimos las conversaciones
    PageChats * refThis = self;
    for (int i=0;i<chats.count;i++) {
        NSDictionary * data = chats[i];
        ChatItem * item = [[ChatItem alloc] initWithFrame:CGRectMake(0,yTop, self.svContent.frame.size.width, 55)];
        item.lblLabel.text = data[@"title"];
        item.lblDate.text = [Utils formatDateRelative:[data[@"activity_at"] integerValue]];
        if (data[@"activity_text"] && ((NSNull *)data[@"activity_text"]) != NSNull.null) {
            item.lblLine.text = data[@"activity_text"];
        } else {
            item.lblLine.text = @"";
        }
        item.tag = i;
        NSInteger pending = [data[@"pending"] integerValue];
        if (pending == 0) {
            item.lblBadge.hidden = YES;
        } else {
            item.lblBadge.text = [NSString stringWithFormat:@"%ld", pending];
        }
        yTop += item.frame.size.height;
        [svContent addSubview:item];
        FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yTop,self.svContent.frame.size.width, 1)];
        [svContent addSubview:sep];
        yTop++;
        
        [Utils setOnClick:item withBlock:^(UIView *sender) {
            NSInteger index = sender.tag;
            NSDictionary * data = refThis->chats[index];
            NSInteger chatId = [data[@"id"] integerValue];
            PageContext * ctx = [[PageContext alloc] init];
            [ctx addParam:@"chatId" withIntValue:chatId];
            [theApp.pages jumpToPage:@"CHAT" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
        }];

    }
    svContent.contentSize = CGSizeMake(0, yTop+20);
}

// Faltaría implementar el refresh...
-(void)refresh {
    // Badges
    PageChats * refThis = self;
    [theApp showBlockView];
    [WSDataManager getChats:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [self setBadges:badges];
            [self setupBadges:self.vHeader];
            refThis->chats = (NSArray *)result;
            [refThis endPreloading:YES];
        } else {
            [theApp stdError:code];
            [refThis endPreloading:NO];
        }
    }];

}


@end
