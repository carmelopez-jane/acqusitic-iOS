//
//  PageGroup.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageGroup.h"
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
#import "PageGroupUrls.h"
#import "PageGroupImages.h"

@interface PageGroup ()

@end

@implementation PageGroup

@synthesize vHeader, svContent, vDelete;

static PageGroup * currentPageGroup = nil;

-(BOOL)onPreloadPage:(PageContext *)context {
    groupId = [context intParamByName:@"groupId"];
    if (groupId == 0) {
        group = [[Group alloc] init];
        return NO;
    } else {
        [theApp showBlockView];
        [WSDataManager getGroup:groupId withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                self->group = [[Group alloc] initWithDictionary:result];
                theApp.appSession.currentGroup = self->group;
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

    [self loadNIB:@"PageGroup"];

    _ctx = context;
    
    currentPageGroup = self;
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Grupos";
    
    [Utils setOnClick:self.vHeaderEdit.btnSave withBlock:^(UIView *sender) {
        [self save];
    }];
    
    fm1.readOnly = ![group hasPermission:@"share"];
    
    FBItem * item;
    fm1 = [[FormBuilder alloc] init];
    item = [[FBItem alloc] init:@"Información del Grupo" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Nombre" fieldType:FIELD_TYPE_TEXT fieldName:@"name"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Descripción" fieldType:FIELD_TYPE_FULLTEXT fieldName:@"description"];
    //[item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Tipo" fieldType:FIELD_TYPE_SELECT fieldName:@"memberpreference"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    item.valuesIndex = @"OFFER_TYPE_GROUP";
    [fm1 add:item];
    /*
    item = [[FBItem alloc] init:@"Tipo" fieldType:FIELD_TYPE_SELECT fieldName:@"type"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    item.valuesIndex = @"GROUP_TYPE_OPTIONS";
    [fm1 add:item];
    */
    item = [[FBItem alloc] init:@"Miembros" fieldType:FIELD_TYPE_CUSTOM];
    item.onCustomGetView = ^UIView *(FBItem *sender, int width, NSString *name) {
        FormItemSubitem * v = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,0,self.svContent.frame.size.width, 55)];
        v.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
        v.lblLabel.text = @"Miembros";
        [v updateSize];
        if (self->group.performers.count == 0) {
            v.lblValue.text = @"No hay miembros";
        } else if (self->group.performers.count == 1) {
            v.lblValue.text = @"1 miembro";
        } else {
            v.lblValue.text = [NSString stringWithFormat:@"%ld miembros", self->group.performers.count];
        }
        [Utils setOnClick:v withBlock:^(UIView *sender) {
            // Vamos a group members
            [self->fm1 save:self->group]; // Guardamos los cambios que tengamos
            [theApp.pages jumpToPage:@"GROUPMEMBERS" withContext:nil withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
        }];
        return v;
    };
    item.onCustomSetupField = ^(FBItem *sender, NSObject *data, BOOL readOnly) {
    };
    item.onCustomUpdateField = ^(FBItem *sender, NSObject *data) {
        FormItemSubitem * v = (FormItemSubitem * )sender.layout;
        if (self->group.performers.count == 0) {
            v.lblValue.text = @"No hay miembros";
        } else if (self->group.performers.count == 1) {
            v.lblValue.text = @"1 miembro";
        } else {
            v.lblValue.text = [NSString stringWithFormat:@"%ld miembros", self->group.performers.count];
        }
    };
    item.onCustomValidate = ^NSString *(FBItem *sender, id value) {
        return nil;
    };
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Ciudad" fieldType:FIELD_TYPE_TEXT fieldName:@"location"];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Provincia" fieldType:FIELD_TYPE_SELECT fieldName:@"province"];
    item.valuesIndex = @"PROVINCE_OPTIONS";
    [fm1 add:item];
    /*
    item = [[FBItem alloc] init:@"Form. habitual" fieldType:FIELD_TYPE_SELECT fieldName:@"memberpreference"];
    item.valuesIndex = @"OFFER_TYPE_GROUP";
    [fm1 add:item];
    */
    item = [[FBItem alloc] init:@"Estilos" fieldType:FIELD_TYPE_LONGMULTISELECT fieldName:@"styles"];
    item.valuesIndex = @"MUSICSTYPES_OPTIONS";
    [fm1 add:item];
    
    if (![group hasPermission:@"share"]) {
        item = [[FBItem alloc] init:@"Para poder modificar los datos del grupo, así como gestionar multimedia, agenda, repertorio, álbums en streaming o facturación, debes ser administrador." fieldType:FIELD_TYPE_SUBNOTE];
        [fm1 add:item];
    } else {
        item = [[FBItem alloc] init:@"Material promocional" fieldType:FIELD_TYPE_SECTION];
        [fm1 add:item];
        item = [[FBItem alloc] init:@"Imágenes" fieldType:FIELD_TYPE_CUSTOM];
        item.onCustomGetView = ^UIView *(FBItem *sender, int width, NSString *name) {
            FormItemSubitem * v = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,0,self.svContent.frame.size.width, 55)];
            v.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
            v.lblLabel.text = @"Imágenes";
            [v updateSize];
            NSArray * images = (self->group.images && ![self->group.images isEqualToString:@""])?([self->group.images componentsSeparatedByString:@","]):@[];
            if (images.count == 0 || (images.count == 1 && [images[0] isEqualToString:@""])) {
                v.lblValue.text = @"No hay imágenes";
            } else if (images.count == 1) {
                v.lblValue.text = @"1 imagen";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld imágenes", images.count];
            }
            [Utils setOnClick:v withBlock:^(UIView *sender) {
                if (self->groupId == 0) {
                    [theApp MessageBox:@"Para poder añadir imágenes primero debes guardar el nuevo grupo."];
                    return;
                }
                PageContext * ctx = [[PageContext alloc] init];
                [ctx addParam:@"sectionTitle" withValue:@"Imágenes"];
                [ctx addParam:@"sectionSubtitle" withValue:@"Imágenes del grupo"];
                [ctx addParam:@"uploadMessage" withValue:@"Puedes añadir fotos de tu grupo para tu perfil."];
                [ctx addParam:@"sectionHint" withValue:@"Pulsa el botón + para subir una nueva imagen"];
                [ctx addParam:@"imageSources" withValue:self->group.images];
                 PageGroupImagesChanged = ^(NSArray * values) {
                     NSString * items = @"";
                     if (values.count > 0) {
                         for (int i=0;i<values.count;i++) {
                             if (![items isEqualToString:@""]) {
                                 items = [items stringByAppendingString:@","];
                             }
                             items = [items stringByAppendingString:values[i]];
                         }
                     }
                     currentPageGroup->group.images = items;
                     PageGroupImagesChanged = nil;
                     FormItemSubitem * v = (FormItemSubitem * )sender;
                     if (values.count == 0) {
                         v.lblValue.text = @"No hay imágenes";
                     } else if (values.count == 1) {
                         v.lblValue.text = @"1 imagen";
                     } else {
                         v.lblValue.text = [NSString stringWithFormat:@"%ld imágenes", values.count];
                     }
                 };
                [self->fm1 save:self->group]; // Guardamos los cambios que tengamos
                [theApp.pages jumpToPage:@"GROUPIMAGES" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }];
            return v;
        };
        item.onCustomSetupField = ^(FBItem *sender, NSObject *data, BOOL readOnly) {
        };
        item.onCustomUpdateField = ^(FBItem *sender, NSObject *data) {
            FormItemSubitem * v = (FormItemSubitem * )sender.layout;
            NSArray * images = (self->group.images && ![self->group.images isEqualToString:@""])?([self->group.images componentsSeparatedByString:@","]):@[];
            if (images.count == 0) {
                v.lblValue.text = @"No hay imágenes";
            } else if (images.count == 1) {
                v.lblValue.text = @"1 imagen";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld imágenes", images.count];
            }
        };
        item.onCustomValidate = ^NSString *(FBItem *sender, id value) {
            return nil;
        };
        [fm1 add:item];
        item = [[FBItem alloc] init:@"Enlaces de vídeo" fieldType:FIELD_TYPE_CUSTOM];
        item.onCustomGetView = ^UIView *(FBItem *sender, int width, NSString *name) {
            FormItemSubitem * v = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,0,self.svContent.frame.size.width, 55)];
            v.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
            v.lblLabel.text = @"Enlaces de vídeo";
            [v updateSize];
            NSArray * videos = (self->group.videos && ![self->group.videos isEqualToString:@""])?([self->group.videos componentsSeparatedByString:@","]):@[];
            if (videos.count == 0 || (videos.count == 1 && [videos[0] isEqualToString:@""])) {
                v.lblValue.text = @"No hay vídeos";
            } else if (videos.count == 1) {
                v.lblValue.text = @"1 vídeo";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld vídeos", videos.count];
            }
            [Utils setOnClick:v withBlock:^(UIView *sender) {
                PageContext * pc = [[PageContext alloc] init];
                [pc addParam:@"groupId" withIntValue:self->groupId];
                [pc addParam:@"sectionTitle" withValue:@"Vídeos"];
                [pc addParam:@"sectionSubtitle" withValue:@"Vídeos del grupo"];
                [pc addParam:@"sectionHint" withValue:@"Pulsa el botón + para añadir un nuevo enlace a tus videos de YouTube, Vimeo o plataformas similares"];
                [pc addParam:@"itemName" withValue:@"enlace a vídeo"];
                [pc addParam:@"content" withValue:self->group.videos];
                PageGroupUrlsChanged = ^(NSArray * values) {
                    NSString * items = @"";
                    if (values.count > 0) {
                        for (int i=0;i<values.count;i++) {
                            if (![items isEqualToString:@""]) {
                                items = [items stringByAppendingString:@","];
                            }
                            items = [items stringByAppendingString:values[i]];
                        }
                    }
                    currentPageGroup->group.videos = items;
                    PageGroupUrlsChanged = nil;
                    FormItemSubitem * v = (FormItemSubitem * )sender;
                    if (values.count == 0) {
                        v.lblValue.text = @"No hay vídeos";
                    } else if (values.count == 1) {
                        v.lblValue.text = @"1 vídeo";
                    } else {
                        v.lblValue.text = [NSString stringWithFormat:@"%ld vídeos", values.count];
                    }
                };
                [self->fm1 save:self->group]; // Guardamos los cambios que tengamos
                [theApp.pages jumpToPage:@"GROUPURLS" withContext:pc withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }];
            return v;
        };
        item.onCustomSetupField = ^(FBItem *sender, NSObject *data, BOOL readOnly) {
        };
        item.onCustomUpdateField = ^(FBItem *sender, NSObject *data) {
            FormItemSubitem * v = (FormItemSubitem * )sender.layout;
            NSArray * videos = (self->group.videos && ![self->group.videos isEqualToString:@""])?([self->group.videos componentsSeparatedByString:@","]):@[];
            if (videos.count == 0) {
                v.lblValue.text = @"No hay vídeos";
            } else if (videos.count == 1) {
                v.lblValue.text = @"1 vídeo";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld vídeos", videos.count];
            }
        };
        item.onCustomValidate = ^NSString *(FBItem *sender, id value) {
            return nil;
        };
        [fm1 add:item];
        item = [[FBItem alloc] init:@"Redes sociales" fieldType:FIELD_TYPE_CUSTOM];
        item.onCustomGetView = ^UIView *(FBItem *sender, int width, NSString *name) {
            FormItemSubitem * v = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,0,self.svContent.frame.size.width, 55)];
            v.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
            v.lblLabel.text = @"Redes sociales";
            [v updateSize];
            NSArray * urls = (self->group.social && ![self->group.social isEqualToString:@""])?([self->group.social componentsSeparatedByString:@","]):@[];
            if (urls.count == 0 || (urls.count == 1 && [urls[0] isEqualToString:@""])) {
                v.lblValue.text = @"No hay redes";
            } else if (urls.count == 1) {
                v.lblValue.text = @"1 red";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld redes", urls.count];
            }
            [Utils setOnClick:v withBlock:^(UIView *sender) {
                PageContext * pc = [[PageContext alloc] init];
                [pc addParam:@"groupId" withIntValue:self->groupId];
                [pc addParam:@"sectionTitle" withValue:@"Redes"];
                [pc addParam:@"sectionSubtitle" withValue:@"Redes sociales del grupo"];
                [pc addParam:@"sectionHint" withValue:@"Pulsa el botón + para añadir un nuevo enlace a tus redes sociales como Facebook, Instagram o Twitter"];
                [pc addParam:@"itemName" withValue:@"enlace a redes sociales"];
                [pc addParam:@"content" withValue:self->group.social];
                PageGroupUrlsChanged = ^(NSArray * values) {
                    NSString * items = @"";
                    if (values.count > 0) {
                        for (int i=0;i<values.count;i++) {
                            if (![items isEqualToString:@""]) {
                                items = [items stringByAppendingString:@","];
                            }
                            items = [items stringByAppendingString:values[i]];
                        }
                    }
                    currentPageGroup->group.social = items;
                    PageGroupUrlsChanged = nil;
                    FormItemSubitem * v = (FormItemSubitem * )sender;
                    if (values.count == 0) {
                        v.lblValue.text = @"No hay redes";
                    } else if (values.count == 1) {
                        v.lblValue.text = @"1 red";
                    } else {
                        v.lblValue.text = [NSString stringWithFormat:@"%ld redes", values.count];
                    }
                };
                [self->fm1 save:self->group]; // Guardamos los cambios que tengamos
                [theApp.pages jumpToPage:@"GROUPURLS" withContext:pc withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }];
            return v;
        };
        item.onCustomSetupField = ^(FBItem *sender, NSObject *data, BOOL readOnly) {
        };
        item.onCustomUpdateField = ^(FBItem *sender, NSObject *data) {
            FormItemSubitem * v = (FormItemSubitem * )sender.layout;
            NSArray * urls = (self->group.social && ![self->group.social isEqualToString:@""])?([self->group.social componentsSeparatedByString:@","]):@[];
            if (urls.count == 0) {
                v.lblValue.text = @"No hay redes";
            } else if (urls.count == 1) {
                v.lblValue.text = @"1 red";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld redes", urls.count];
            }
        };
        item.onCustomValidate = ^NSString *(FBItem *sender, id value) {
            return nil;
        };
        [fm1 add:item];

        item = [[FBItem alloc] init:@"Gestión del grupo" fieldType:FIELD_TYPE_SECTION];
        [fm1 add:item];
        item = [[FBItem alloc] init:@"Repertorio" fieldType:FIELD_TYPE_CUSTOM];
        item.onCustomGetView = ^UIView *(FBItem *sender, int width, NSString *name) {
            FormItemSubitem * v = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,0,self.svContent.frame.size.width, 55)];
            v.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
            v.lblLabel.text = @"Repertorio";
            [v updateSize];
            if (self->group.repertoire.count == 0) {
                v.lblValue.text = @"No hay repertorios";
            } else if (self->group.repertoire.count == 1) {
                v.lblValue.text = @"1 repertorio";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld repertorios", self->group.repertoire.count];
            }
            [Utils setOnClick:v withBlock:^(UIView *sender) {
                if (self->groupId == 0) {
                    [theApp MessageBox:@"Para poder añadir repertorios primero debes guardar el nuevo grupo."];
                    return;
                }
                [self->fm1 save:self->group]; // Guardamos los cambios que tengamos
                PageContext * pc = [[PageContext alloc] init];
                [pc addParam:@"groupId" withIntValue:self->groupId];
                [theApp.pages jumpToPage:@"GROUPREPERTOIRES" withContext:pc withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }];
            return v;
        };
        item.onCustomSetupField = ^(FBItem *sender, NSObject *data, BOOL readOnly) {
        };
        item.onCustomUpdateField = ^(FBItem *sender, NSObject *data) {
            FormItemSubitem * v = (FormItemSubitem * )sender.layout;
            if (self->group.repertoire.count == 0) {
                v.lblValue.text = @"No hay repertorios";
            } else if (self->group.repertoire.count == 1) {
                v.lblValue.text = @"1 repertorio";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld repertorios", self->group.repertoire.count];
            }
        };
        item.onCustomValidate = ^NSString *(FBItem *sender, id value) {
            return nil;
        };
        [fm1 add:item];
        item = [[FBItem alloc] init:@"Agenda" fieldType:FIELD_TYPE_CUSTOM];
        item.onCustomGetView = ^UIView *(FBItem *sender, int width, NSString *name) {
            FormItemSubitem * v = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,0,self.svContent.frame.size.width, 55)];
            v.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
            v.lblLabel.text = @"Agenda";
            [v updateSize];
            if (self->group.agenda.count == 0) {
                v.lblValue.text = @"No hay eventos próximamente";
            } else if (self->group.agenda.count == 1) {
                v.lblValue.text = @"1 evento próximamente";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld eventos próximamente", self->group.agenda.count];
            }
            [Utils setOnClick:v withBlock:^(UIView *sender) {
                if (self->groupId == 0) {
                    [theApp MessageBox:@"Para poder añadir eventos primero debes guardar el nuevo grupo."];
                    return;
                }
                [self->fm1 save:self->group]; // Guardamos los cambios que tengamos
                PageContext * pc = [[PageContext alloc] init];
                [pc addParam:@"groupId" withIntValue:self->groupId];
                [theApp.pages jumpToPage:@"GROUPAGENDA" withContext:pc withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }];
            return v;
        };
        item.onCustomSetupField = ^(FBItem *sender, NSObject *data, BOOL readOnly) {
        };
        item.onCustomUpdateField = ^(FBItem *sender, NSObject *data) {
            FormItemSubitem * v = (FormItemSubitem * )sender.layout;
            if (self->group.agenda.count == 0) {
                v.lblValue.text = @"No hay eventos próximamente";
            } else if (self->group.agenda.count == 1) {
                v.lblValue.text = @"1 evento próximamente";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld eventos próximamente", self->group.agenda.count];
            }
        };
        item.onCustomValidate = ^NSString *(FBItem *sender, id value) {
            return nil;
        };
        [fm1 add:item];
        item = [[FBItem alloc] init:@"Facturas" fieldType:FIELD_TYPE_CUSTOM];
        item.onCustomGetView = ^UIView *(FBItem *sender, int width, NSString *name) {
            FormItemSubitem * v = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,0,self.svContent.frame.size.width, 55)];
            v.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
            v.lblLabel.text = @"Facturas";
            [v updateSize];
            if (self->group.invoicereqs.count == 0) {
                v.lblValue.text = @"No hay facturas";
            } else if (self->group.invoicereqs.count == 1) {
                v.lblValue.text = @"1 factura";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld facturas", self->group.invoicereqs.count];
            }
            [Utils setOnClick:v withBlock:^(UIView *sender) {
                if (self->groupId == 0) {
                    [theApp MessageBox:@"Para poder solicitar facturas primero debes guardar el nuevo grupo."];
                    return;
                }
                [self->fm1 save:self->group]; // Guardamos los cambios que tengamos
                PageContext * pc = [[PageContext alloc] init];
                [pc addParam:@"groupId" withIntValue:self->groupId];
                [theApp.pages jumpToPage:@"GROUPINVOICEREQS" withContext:pc withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }];
            return v;
        };
        item.onCustomSetupField = ^(FBItem *sender, NSObject *data, BOOL readOnly) {
        };
        item.onCustomUpdateField = ^(FBItem *sender, NSObject *data) {
            FormItemSubitem * v = (FormItemSubitem * )sender.layout;
            if (self->group.invoicereqs.count == 0) {
                v.lblValue.text = @"No hay facturas";
            } else if (self->group.invoicereqs.count == 1) {
                v.lblValue.text = @"1 factura";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld facturas", self->group.invoicereqs.count];
            }
        };
        item.onCustomValidate = ^NSString *(FBItem *sender, id value) {
            return nil;
        };
        [fm1 add:item];
        
        /*
        item = [[FBItem alloc] init:@"Distribución digital" fieldType:FIELD_TYPE_SECTION];
        [fm1 add:item];
        item = [[FBItem alloc] init:@"Álbums en streaming" fieldType:FIELD_TYPE_CUSTOM];
        item.onCustomGetView = ^UIView *(FBItem *sender, int width, NSString *name) {
            FormItemSubitem * v = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,0,self.svContent.frame.size.width, 55)];
            v.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
            v.lblLabel.text = @"Álbums en streaming";
            [v updateSize];
            if (self->group.albums.count == 0) {
                v.lblValue.text = @"No hay álbums";
            } else if (self->group.albums.count == 1) {
                v.lblValue.text = @"1 álbum";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld álbums", self->group.albums.count];
            }
            [Utils setOnClick:v withBlock:^(UIView *sender) {
                if (self->groupId == 0) {
                    [theApp MessageBox:@"Para poder añadir álbums primero debes guardar el nuevo grupo."];
                    return;
                }
                [self->fm1 save:self->group]; // Guardamos los cambios que tengamos
                PageContext * pc = [[PageContext alloc] init];
                [pc addParam:@"groupId" withIntValue:self->groupId];
                [theApp.pages jumpToPage:@"GROUPALBUMS" withContext:pc withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }];
            return v;
        };
        item.onCustomSetupField = ^(FBItem *sender, NSObject *data, BOOL readOnly) {
        };
        item.onCustomUpdateField = ^(FBItem *sender, NSObject *data) {
            FormItemSubitem * v = (FormItemSubitem * )sender.layout;
            if (self->group.albums.count == 0) {
                v.lblValue.text = @"No hay álbums";
            } else if (self->group.albums.count == 1) {
                v.lblValue.text = @"1 álbum";
            } else {
                v.lblValue.text = [NSString stringWithFormat:@"%ld álbums", self->group.albums.count];
            }
        };
        item.onCustomValidate = ^NSString *(FBItem *sender, id value) {
            return nil;
        };
        [fm1 add:item];
        */
    }
    
    int height = [fm1 fillInForm:svContent from:0 withData:group];
    
    self.svContent.contentSize = CGSizeMake(0, height+20);
    
    // Si es nuevo, no lo podemos eliminar
    if ([group hasPermission:@"share"]) {
        self.vDelete.hidden = YES;
        CGRect fr = self.svContent.frame;
        fr.size.height += self.vDelete.frame.size.height;
        self.svContent.frame = fr;
    } else {
        self.vDelete.lblLabel.text = @"Salir del grupo";
        [Utils setOnClick:self.vDelete.lblLabel withBlock:^(UIView *sender) {
            [self removeMember];
        }];
    }
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    PageContext * ret = [_ctx clone];
    ret.cachePage = YES;
    return ret;
}

-(void) onRecyclePage:(PageContext *)context {
    [super onRecyclePage:context];
    [theApp showBlockView];
    [WSDataManager getGroup:groupId withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            Group * ng = [[Group alloc] initWithDictionary:result];
            self->group.invoicereqs = ng.invoicereqs;
            self->group.performers = ng.performers;
            self->group.agenda = ng.agenda;
            self->group.repertoire = ng.repertoire;
            self->group.albums = ng.albums;
            self->group.songs = ng.songs;
            [self->fm1 updateForm:self->group];
        } else {
            [theApp stdError:code];
        }
    }];
}

-(void) save {
    NSString * res = [fm1 validate];
    if (res != nil) {
        [theApp MessageBox:res];
        return;
    }
    [fm1 save:group];
    // Ajustamos el tipo de grupo en función de las preferencias de grupo
    if ([group.memberpreference isEqualToString:@"dj"]) {
        group.type = @"DJ";
    } else {
        group.type = @"performer";
    }
    
    [theApp showBlockView];
    [WSDataManager updateGroup:group withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [theApp.pages goBack];
        } else {
            [theApp stdError:code];
        }
    }];
}

-(void) removeMember {
    [theApp QueryMessage:@"¿Seguro que quieres salir del grupo?" withYes:@"Sí" andNo:@"No" onCommand:^(Popup *pm, int command, NSObject *data) {
        if (command == POPUP_CMD_YES) {
            [theApp showBlockView];
            [WSDataManager removeGroupMember:self->group._id performer:theApp.appSession.performerProfile withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
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
