//
//  PageGroupRepertoire.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupRepertoire.h"
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
#import "FormItemSubnote.h"

@interface PageGroupRepertoire ()

@end

@implementation PageGroupRepertoire

@synthesize vHeader, svContent, vHeaderEdit, vDelete;

-(BOOL)onPreloadPage:(PageContext *)context {
    NSInteger repertoireId = [context intParamByName:@"repertoireId"];
    if (repertoireId == 0) {
        repertoire = [[Repertoire alloc] init];
        return NO;
    } else {
        [theApp showBlockView];
        [WSDataManager getGroupRepertoire:theApp.appSession.currentGroup._id repertoireId:repertoireId withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                self->repertoire = [[Repertoire alloc] initWithDictionary:result];
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

    [self loadNIB:@"PageGroupRepertoire"];

    _ctx = context;
    
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Contraseña";
    
    [Utils setOnClick:self.vHeaderEdit.btnSave withBlock:^(UIView *sender) {
        [self save];
    }];
    
    FBItem * item;
    fm1 = [[FormBuilder alloc] init];
    item = [[FBItem alloc] init:@"Información del repertorio" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Título" fieldType:FIELD_TYPE_TEXT fieldName:@"title"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];

    int yPos = [fm1 fillInForm:svContent from:0 withData:repertoire];
    
    // Añadimos las canciones
    FormItemHeader * hCanciones = [[FormItemHeader alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    hCanciones.lblLabel.text = @"Canciones de mi repertorio";
    [Utils setOnClick:hCanciones.vIcon withBlock:^(UIView *sender) {
        [theApp Menu:@"Canciones" withOptions:@[@"Añadir una canción de otro repertorio/álbum", @"Crear canción nueva"] onCommand:^(Popup *pm, int command, NSObject *data) {
            if (command == 100) {
                NSMutableArray * options = [[NSMutableArray alloc] init];
                NSArray * songs = theApp.appSession.currentGroup.songs;
                for (int i=0;i<songs.count;i++) {
                    Song * s = songs[i];
                    [options addObject:[NSString stringWithFormat:@"%@ - %@",s.title, s.authors]];
                }
                [theApp Menu:@"Añadir canción" withOptions:options onCommand:^(Popup *pm, int command, NSObject *data) {
                    if (command >= 100) {
                        Song * selSong = songs[command-100];
                        [theApp showBlockView];
                        [WSDataManager attachGroupRepertoireSong:theApp.appSession.currentGroup._id repertoireId:self->repertoire._id songId:selSong._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                            [theApp hideBlockView];
                            if (code == WS_SUCCESS) {
                                [self->repertoire.songs addObject:selSong];
                                //[self fillInSongs];
                                [theApp.pages jumpToPage:@"GROUPREPERTOIRE" withContext:self._context];
                            } else {
                                [theApp stdError:code];
                            }
                        }];
                    }
                }];
            } else if (command == 101) {
                PageContext * ctx = [[PageContext alloc] init];
                [ctx addParam:@"repertoireId" withIntValue:self->repertoire._id];
                [ctx addParam:@"songId" withIntValue:0];
                [theApp.pages jumpToPage:@"GROUPSONG" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }
        }];
    }];
    [svContent addSubview:hCanciones];
    yPos += 55;
    FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 1)];
    [svContent addSubview:sep];
    yPos++;

    songsYpos = yPos;
    [self fillInSongs];
    

    // Eliminar repertoire
    // Si es nuevo, no lo podemos eliminar
    if (repertoire._id == 0) {
        self.vDelete.hidden = YES;
        CGRect fr = self.svContent.frame;
        fr.size.height += self.vDelete.frame.size.height;
        self.svContent.frame = fr;
    } else {
        self.vDelete.lblLabel.text = @"Eliminar repertorio";
        [Utils setOnClick:self.vDelete.lblLabel withBlock:^(UIView *sender) {
            [self deleteItem];
        }];
    }
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}

-(void) fillInSongs {
    if (songList != nil) {
        for (int i=0;i<songList.count;i++) {
            [songList[i] removeFromSuperview];
        }
        [songList removeAllObjects];
    } else {
        songList = [[NSMutableArray alloc] init];
    }

    int yPos = songsYpos;
    for (int i=0;i<repertoire.songs.count;i++) {
        if (i > 0) {
            FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
            [self.svContent addSubview:sep];
            yPos++;
        }
        Song * s = repertoire.songs[i];
        FormItemSubitem * item = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,yPos, self.svContent.frame.size.width, 55)];
        item.lblLabel.text = s.title;
        item.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
        [item updateSize];
        item.tag = i;
        [Utils setOnClick:item withBlock:^(UIView *sender) {
            NSInteger index = sender.tag;
            NSInteger songId = ((Song *)self->repertoire.songs[index])._id;
            PageContext * ctx = [[PageContext alloc] init];
            [ctx addParam:@"repertoireId" withIntValue:self->repertoire._id];
            [ctx addParam:@"songId" withIntValue:songId];
            [theApp.pages jumpToPage:@"GROUPSONG" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
        }];
        [self.svContent addSubview:item];
        yPos += 55;
    }
    
    yPos += 10;
    FormItemSubnote * sn = [[FormItemSubnote alloc] initWithFrame:CGRectMake(0,yPos, self.svContent.frame.size.width, 55)];
    sn.lblLabel.text = @"Pulsa el botón + para añadir una nueva canción a este repertorio. Recuerda que puedes añadir tanto temas propios como covers.";
    [sn updateSize];
    [svContent addSubview:sn];
    yPos += sn.frame.size.height;
    
    self.svContent.contentSize = CGSizeMake(0, yPos+20);
}

-(void) save {
    NSString * res = [fm1 validate];
    if (res != nil) {
        [theApp MessageBox:res];
        return;
    }
    [fm1 save:repertoire];
    
    [theApp showBlockView];
    [WSDataManager updateGroupRepertoire:theApp.appSession.currentGroup._id repertoire:repertoire withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [theApp.pages goBack];
        } else {
            [theApp stdError:code];
        }
    }];
}

-(void) deleteItem {
    if (repertoire.songs.count > 0) {
        [theApp MessageBox:@"Primero debes vaciar el repertorio para poderlo eliminar"];
        return;
    }
    [theApp QueryMessage:@"¿Seguro que quieres eliminar este repertorio?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            [theApp showBlockView];
            [WSDataManager removeGroupRepertoire:theApp.appSession.currentGroup._id repertoire:self->repertoire withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
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
