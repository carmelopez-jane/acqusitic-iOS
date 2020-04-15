//
//  PageGroupAlbum.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupAlbum.h"
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

@interface PageGroupAlbum ()

@end

@implementation PageGroupAlbum

@synthesize vHeader, svContent, vHeaderEdit, vDelete;

-(BOOL)onPreloadPage:(PageContext *)context {
    NSInteger albumId = [context intParamByName:@"albumId"];
    if (albumId == 0) {
        album = [[Album alloc] init];
        return NO;
    } else {
        [theApp showBlockView];
        [WSDataManager getGroupAlbum:theApp.appSession.currentGroup._id albumId:albumId withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                self->album = [[Album alloc] initWithDictionary:result];
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

    [self loadNIB:@"PageGroupAlbum"];

    _ctx = context;
    
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Álbum";
    
    [Utils setOnClick:self.vHeaderEdit.btnSave withBlock:^(UIView *sender) {
        [self save];
    }];
    
    FBItem * item;
    fm1 = [[FormBuilder alloc] init];
    item = [[FBItem alloc] init:@"Información del álbum" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Título" fieldType:FIELD_TYPE_TEXT fieldName:@"title"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Estilo principal" fieldType:FIELD_TYPE_SELECT fieldName:@"primary_style"];
    item.valuesIndex = @"ALBUM_MUSICSTYLE_OPTIONS";
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Estilo secundario" fieldType:FIELD_TYPE_SELECT fieldName:@"secondary_style"];
    item.valuesIndex = @"ALBUM_MUSICSTYLE_OPTIONS";
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Código UPC" fieldType:FIELD_TYPE_TEXT fieldName:@"upc_code"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"F. publicación" fieldType:FIELD_TYPE_DATE fieldName:@"original_publish_date"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"F. pub. streaming" fieldType:FIELD_TYPE_DATE fieldName:@"publish_date"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Portada" fieldType:FIELD_TYPE_IMAGE fieldName:@"cover"];
    item.fieldDescription = @"A continuación necesitamos que nos facilites una imagen de portada para el álbum.\n\nLa imagen debe ser cuadrada y tener entre 3000x3000 pixels y 5000x5000 pixels.";
    [fm1 add:item];

    int yPos = [fm1 fillInForm:svContent from:0 withData:album];
    
    // Añadimos las canciones
    FormItemHeader * hCanciones = [[FormItemHeader alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 55)];
    hCanciones.lblLabel.text = @"Canciones de mi álbum";
    [svContent addSubview:hCanciones];
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
                    Song * selSong = songs[command];
                    [theApp showBlockView];
                    [WSDataManager attachGroupAlbumSong:theApp.appSession.currentGroup._id albumId:self->album._id songId:selSong._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                        [theApp hideBlockView];
                        if (code == WS_SUCCESS) {
                            [self->album.songs addObject:selSong];
                            [self fillInSongs];
                        } else {
                            [theApp stdError:code];
                        }
                    }];
                }];
            } else if (command == 101) {
                PageContext * ctx = [[PageContext alloc] init];
                [ctx addParam:@"albumId" withIntValue:self->album._id];
                [ctx addParam:@"songId" withIntValue:0];
                [theApp.pages jumpToPage:@"GROUPSONG" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }
        }];
    }];
    yPos += 55;
    FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0, yPos, self.svContent.frame.size.width, 1)];
    [svContent addSubview:sep];
    yPos++;
    
    songsYpos = yPos;
    
    [self fillInSongs];
    

    // Eliminar album
    // Si es nuevo, no lo podemos eliminar
    if (album._id == 0) {
        self.vDelete.hidden = YES;
        CGRect fr = self.svContent.frame;
        fr.size.height += self.vDelete.frame.size.height;
        self.svContent.frame = fr;
        self.btnPublish.hidden = YES;
    } else {
        self.vDelete.lblLabel.text = @"Eliminar álbum";
        [Utils setOnClick:self.vDelete.lblLabel withBlock:^(UIView *sender) {
            [self deleteItem];
        }];
        [self.btnPublish addTarget:self action:@selector(publishAlbum) forControlEvents:UIControlEventTouchUpInside];
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
    for (int i=0;i<album.songs.count;i++) {
        if (i > 0) {
            FormItemSep * sep = [[FormItemSep alloc] initWithFrame:CGRectMake(0,yPos,self.svContent.frame.size.width, 1)];
            [self.svContent addSubview:sep];
            yPos++;
        }
        Song * s = album.songs[i];
        FormItemSubitem * item = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,yPos, self.svContent.frame.size.width, 55)];
        item.lblLabel.text = s.title;
        item.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
        [item updateSize];
        item.tag = i;
        [Utils setOnClick:item withBlock:^(UIView *sender) {
            NSInteger index = sender.tag;
            NSInteger songId = ((Song *)self->album.songs[index])._id;
            PageContext * ctx = [[PageContext alloc] init];
            [ctx addParam:@"albumId" withIntValue:self->album._id];
            [ctx addParam:@"songId" withIntValue:songId];
            [theApp.pages jumpToPage:@"GROUPSONG" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
        }];
        [self.svContent addSubview:item];
        yPos += 55;
    }
    
    yPos += 10;
    FormItemSubnote * sn = [[FormItemSubnote alloc] initWithFrame:CGRectMake(0,yPos, self.svContent.frame.size.width, 55)];
    sn.lblLabel.text = @"Introduce las canciones que componen el álbum. Debes completar toda la información obligatoria del álbum y las canciones antes de solicitar su publicación. En el caso de código UPC si no lo tienes puedes dejarlo en blanco y te asignaremos uno nosotros automáticamente.";
    [sn updateSize];
    [svContent addSubview:sn];
    yPos += sn.frame.size.height;
    
    yPos += 20;
    CGRect fr = self.btnPublish.frame;
    fr.origin.y = yPos;
    self.btnPublish.frame = fr;
    yPos += self.btnPublish.frame.size.height;
    
    if (![album.status isEqualToString:@"NEW"]) {
        self.btnPublish.hidden = YES;
    }

    
    self.svContent.contentSize = CGSizeMake(0, yPos+20);
}

-(void) save {
    NSString * res = [fm1 validate];
    if (res != nil) {
        [theApp MessageBox:res];
        return;
    }
    [fm1 save:album];
    
    [theApp showBlockView];
    [WSDataManager updateGroupAlbum:theApp.appSession.currentGroup._id album:album withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [theApp.pages goBack];
        } else {
            [theApp stdError:code];
        }
    }];
}

-(void) deleteItem {
    /*
    if (album.songs.count > 0) {
        [theApp MessageBox:@"Para poder eliminar un álbum, éste debe estar vacío."];
        return;
    }
    */
    [theApp QueryMessage:@"¿Seguro que quieres eliminar este álbum?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            [theApp showBlockView];
            [WSDataManager removeGroupAlbum:theApp.appSession.currentGroup._id album:self->album withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
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

-(void) publishAlbum {
    // Debemos checkear el álbum para poder publicarlo
    
    // Solicitamos la publicación...
    [WSDataManager publishGroupAlbum:theApp.appSession.currentGroup._id albumId:album._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        // A ver qué nos piden
        if (code == WS_SUCCESS) {
            [theApp MessageBox:@"Revisamos el álbum y si todo es correcto lo publicamos en streaming. Puedes hacer un seguimiento del álbum a través de la sección de Álbums en streaming de tu grupo"];
            [theApp.pages goBack];
        } else {
            [theApp stdError:code];
        }
    }];
}


@end
