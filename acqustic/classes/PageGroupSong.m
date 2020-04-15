//
//  PageGroupSong.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroupSong.h"
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

@interface PageGroupSong ()

@end

@implementation PageGroupSong

@synthesize vHeader, svContent, vDelete;

-(BOOL)onPreloadPage:(PageContext *)context {
    NSInteger itemId = [context intParamByName:@"songId"];
    if (itemId == 0) {
        song = [[Song alloc] init];
        return NO;
    } else {
        [theApp showBlockView];
        [WSDataManager getSong:theApp.appSession.currentGroup._id itemId:itemId withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                self->song = [[Song alloc] initWithDictionary:result];
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

    [self loadNIB:@"PageGroupSong"];

    _ctx = context;
    
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Contraseña";
    
    [Utils setOnClick:self.vHeaderEdit.btnSave withBlock:^(UIView *sender) {
        [self save];
    }];
    
    FBItem * item;
    fm1 = [[FormBuilder alloc] init];
    item = [[FBItem alloc] init:@"Información de la canción" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Título" fieldType:FIELD_TYPE_SEARCH fieldName:@"title"];
    item.onSearch = ^(FBItem *sender, NSString *search) {
        // Buscamos canciones...
        [self searchSongs:search];
    };
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];

    item = [[FBItem alloc] init:@"Autor/es" fieldType:FIELD_TYPE_TEXT fieldName:@"authors"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Artistas destacados" fieldType:FIELD_TYPE_TEXT fieldName:@"feat_artists"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"IRSC" fieldType:FIELD_TYPE_TEXT fieldName:@"irsc"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Idioma" fieldType:FIELD_TYPE_SELECT fieldName:@"lang"];
    item.valuesIndex = @"SONG_LANGUAGES_OPTIONS";
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Tipo" fieldType:FIELD_TYPE_SELECT fieldName:@"type"];
    item.valuesIndex = @"SONG_TYPE_OPTIONS";
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Contenido explícito" fieldType:FIELD_TYPE_BOOLEAN fieldName:@"explicit_content"];
    [fm1 add:item];

    /*
    item = [[FBItem alloc] init:@"Plataformas digitales" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Soy dueño de los derechos" fieldType:FIELD_TYPE_BOOLEAN fieldName:@"owned"];
    [fm1 add:item];
    */
    item = [[FBItem alloc] init:@"Archivo MP3" fieldType:FIELD_TYPE_AUDIO fieldName:@"audiofile"];
    [fm1 add:item];

    int height = [fm1 fillInForm:svContent from:0 withData:song];
    
    self.svContent.contentSize = CGSizeMake(0, height+20);
    
    // Si es nuevo, no lo podemos eliminar
    if (song._id == 0) {
        self.vDelete.hidden = YES;
        CGRect fr = self.svContent.frame;
        fr.size.height += self.vDelete.frame.size.height;
        self.svContent.frame = fr;
    } else {
        self.vDelete.lblLabel.text = @"Eliminar canción";
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
    [fm1 save:song];
    if (song._id == 0) {
        if ([_ctx intParamByName:@"repertoireId"] > 0) {
            [theApp showBlockView];
            [WSDataManager addGroupRepertoireSong:theApp.appSession.currentGroup._id repertoireId:[_ctx intParamByName:@"repertoireId"] song:song withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                [theApp hideBlockView];
                if (code == WS_SUCCESS) {
                    [theApp.pages goBack];
                } else {
                    [theApp stdError:code];
                }
            }];
        } else {
            [theApp showBlockView];
            [WSDataManager addGroupAlbumSong:theApp.appSession.currentGroup._id albumId:[_ctx intParamByName:@"albumId"] song:song withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                [theApp hideBlockView];
                if (code == WS_SUCCESS) {
                    [theApp.pages goBack];
                } else {
                    [theApp stdError:code];
                }
            }];
        }
    } else {
        [theApp showBlockView];
        [WSDataManager udpateSong:song withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                [theApp.pages goBack];
            } else {
                [theApp stdError:code];
            }
        }];
    }
}

-(void) searchSongs:(NSString *)search {
    PageGroupSong * refThis = self;
    [theApp dismissKeyboard];
    [theApp showBlockView];
    [WSDataManager deezerSearchSongs:search withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        int total = [result[@"total"] intValue];
        if (total > 0) {
            NSArray * items = result[@"data"];
            NSMutableArray * options = [[NSMutableArray alloc] init];
            for (int i=0;i<items.count;i++) {
                NSDictionary * item = items[i];
                NSDictionary * artist = item[@"artist"];
                NSString * title = item[@"title"];
                if (artist) {
                    title = [title stringByAppendingFormat:@" - %@", artist[@"name"]];
                }
                [options addObject:title];
                if (i > 10) // Máximo 10
                    break;
            }
            [theApp Menu:@"Selecciona canción" withOptions:options onCommand:^(Popup *pm, int command, NSObject *data) {
                if (command >= 100) {
                    int index = command - 100;
                    NSDictionary * item = items[index];
                    NSString * songId = item[@"id"];
                    [WSDataManager deezerGetTrack:songId withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                        [refThis fillInSong:result];
                    }];
                }
            }];
        } else {
            [theApp MessageBox:@"No hay coincidencias"];
        }
    }];
}

-(void) fillInSong:(NSDictionary *)songData {
    [fm1 save:song];
    song.irsc = songData[@"isrc"]?songData[@"isrc"]:@"";
    song.title = songData[@"title"]?songData[@"title"]:@"";
    if (songData[@"explicit_content_lyrics"] && [songData[@"explicit_content_lyrics"] boolValue])
        song.explicit_content = YES;
    song.type = @"cover";
    song.lang = @"es";
    NSDictionary * artist = songData[@"artist"];
    if (artist) {
        song.authors = artist[@"name"];
    }
    [fm1 updateForm:song];
}

-(void) deleteItem {
    [theApp QueryMessage:@"¿Seguro que quieres eliminar esta canción?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            [theApp showBlockView];
            if ([self->_ctx intParamByName:@"repertoireId"] > 0) {
                [WSDataManager removeGroupRepertoireSong:theApp.appSession.currentGroup._id repertoireId:[self->_ctx intParamByName:@"repertoireId"] songId:self->song._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                    [theApp hideBlockView];
                    if (code == WS_SUCCESS) {
                        [theApp.pages goBack];
                    } else {
                        [theApp stdError:code];
                    }
                }];
            } else {
                [WSDataManager removeGroupAlbumSong:theApp.appSession.currentGroup._id albumId:[self->_ctx intParamByName:@"albumId"] songId:self->song._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                    [theApp hideBlockView];
                    if (code == WS_SUCCESS) {
                        [theApp.pages goBack];
                    } else {
                        [theApp stdError:code];
                    }
                }];
            }
        }
    }];
}


@end
