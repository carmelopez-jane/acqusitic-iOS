//
//  PageCompleteFreemium.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageCompleteFreemium.h"
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

@interface PageCompleteFreemium ()

@end

@implementation PageCompleteFreemium

@synthesize vHeader, svContent, vDelete;

static PageCompleteFreemium * currentPageCompleteFreemium = nil;

-(BOOL)onPreloadPage:(PageContext *)context {
    // Modo de trabajo
    NSInteger mode = [context intParamByName:@"mode"];
    groups = [[NSMutableArray alloc] init];
    groupFMs = [[NSMutableArray alloc] init];
    
    [WSDataManager getProfile:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            self->performer = [[Performer alloc] initWithDictionary:result];
            if (mode == FREEMIUM_MODE_REGISTERBASICDATA) {
                Group * selGroup = nil;
                for (int i=0;i<self->performer.groups.count;i++) {
                    Group * g = self->performer.groups[i];
                    if ([g hasPermission:@"share"]) {
                        selGroup = g;
                        break;
                    }
                }
                if (selGroup != nil) {
                    [WSDataManager getGroup:selGroup._id withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                        [theApp hideBlockView];
                        if (code == WS_SUCCESS) {
                            Group * g = [[Group alloc] initWithDictionary:result];
                            [self->groups addObject:g];
                            theApp.appSession.currentGroup = g;
                            [self endPreloading:YES];
                        } else {
                            [theApp stdError:code];
                            [self endPreloading:NO];
                        }
                    }];
                } else {
                    selGroup = [[Group alloc] init];
                    [self->groups addObject:selGroup];
                    [self endPreloading:YES];
                }
            } else if (mode == FREEMIUM_MODE_REGISTERFORPERFORMANCE) {
                NSArray * groups = [[context paramByName:@"groups"] componentsSeparatedByString:@","];
                for (int i=0;i<self->performer.groups.count;i++) {
                    Group * g = self->performer.groups[i];
                    for (int j=0;j<groups.count;j++) {
                        if ([groups[j] integerValue] == g._id && [g hasPermission:@"share"] && ![g isReadyForRegister]) {
                            // Lo añadimos
                            [self->groups addObject:g];
                        }
                    }
                }
                [self endPreloading:YES];
            }
        } else {
            [theApp stdError:code];
            [self endPreloading:NO];
        }
    }];
    return YES;
}

-(void)onEnterPage:(PageContext *)context{
    
    [super onEnterPage:context];
    
    NSInteger mode = [context intParamByName:@"mode"];

    [self loadNIB:@"PageCompleteFreemium"];

    _ctx = context;
    
    currentPageCompleteFreemium = self;
    
    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Completar perfil";
    self.vHeaderEdit.btnClose.hidden = YES;
    
    [Utils setOnClick:self.vHeaderEdit.btnSave withBlock:^(UIView *sender) {
        [self save];
    }];

    // PERFIL DEL USUARIO
    FBItem * item;
    perfFM = [[FormBuilder alloc] init];
    if (mode == FREEMIUM_MODE_REGISTERFORPERFORMANCE) {
        item = [[FBItem alloc] init:@"Tienes que completar tu perfil antes de apuntarte a esta oferta. Rellena todos los campos con la información de tu perfil y de tu grupo para poder continuar." fieldType:FIELD_TYPE_NOTE];
        [perfFM add:item];
    }
    item = [[FBItem alloc] init:@"Completa tu información básica" fieldType:FIELD_TYPE_SECTION];
    [perfFM add:item];
    item = [[FBItem alloc] init:@"Nombre" fieldType:FIELD_TYPE_TEXT fieldName:@"name"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [perfFM add:item];
    item = [[FBItem alloc] init:@"Apellidos" fieldType:FIELD_TYPE_TEXT fieldName:@"surname"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [perfFM add:item];
    item = [[FBItem alloc] init:@"Teléfono" fieldType:FIELD_TYPE_TEXT fieldName:@"telephone"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [item addValidator:[[FBTelephoneValidator alloc] init]];
    [perfFM add:item];
    item = [[FBItem alloc] init:@"Email" fieldType:FIELD_TYPE_TEXT fieldName:@"email"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [item addValidator:[[FBEmailValidator alloc] init]];
    [perfFM add:item];
    item = [[FBItem alloc] init:@"Provincia" fieldType:FIELD_TYPE_SELECT fieldName:@"province"];
    item.valuesIndex = @"PROVINCE_OPTIONS";
    [perfFM add:item];

    int yPos = [perfFM fillInForm:svContent from:20 withData:performer];

    // Grupos
    for (int i=0;i<groups.count;i++) {
        Group * group = groups[i];
        FormBuilder * gFM = [self addGroup:group];
        yPos = [gFM fillInForm:svContent from:(yPos + 30) withData:group];
        [groupFMs addObject:gFM];
    }
    
    self.svContent.contentSize = CGSizeMake(0, yPos+20);

    // Saltamos...
    if (mode == FREEMIUM_MODE_REGISTERBASICDATA) {
        self.vDelete.lblLabel.text = @"Completar más tarde";
        [Utils setOnClick:self.vDelete.lblLabel withBlock:^(UIView *sender) {
            [theApp.pages jumpToPage:@"HOME" withContext:[[PageContext alloc] init] withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:YES];
        }];
    } else {
        self.vDelete.lblLabel.text = @"Cancelar";
        [Utils setOnClick:self.vDelete.lblLabel withBlock:^(UIView *sender) {
            [theApp.pages goBack];
        }];
    }
}

-(FormBuilder *)addGroup:(Group *)group {
    FormBuilder * gFM = [[FormBuilder alloc] init];
    FBItem * item = [[FBItem alloc] init:[NSString stringWithFormat:@"Completa la información de %@", group.name] fieldType:FIELD_TYPE_SECTION];
    [gFM add:item];
    item = [[FBItem alloc] init:@"Nombre" fieldType:FIELD_TYPE_TEXT fieldName:@"name"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [gFM add:item];
    item = [[FBItem alloc] init:@"Tipo" fieldType:FIELD_TYPE_SELECT fieldName:@"memberpreference"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    item.valuesIndex = @"OFFER_TYPE_GROUP";
    [gFM add:item];
    item = [[FBItem alloc] init:@"Ciudad" fieldType:FIELD_TYPE_TEXT fieldName:@"location"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [gFM add:item];
    item = [[FBItem alloc] init:@"Provincia" fieldType:FIELD_TYPE_SELECT fieldName:@"province"];
    item.valuesIndex = @"PROVINCE_OPTIONS";
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [gFM add:item];
    item = [[FBItem alloc] init:@"Estilos" fieldType:FIELD_TYPE_LONGMULTISELECT fieldName:@"styles"];
    item.valuesIndex = @"MUSICSTYPES_OPTIONS";
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [gFM add:item];
    item = [[FBItem alloc] init:@"Enlaces de vídeo" fieldType:FIELD_TYPE_CUSTOM];
    item.onCustomGetView = ^UIView *(FBItem *sender, int width, NSString *name) {
        FormItemSubitem * v = [[FormItemSubitem alloc] initWithFrame:CGRectMake(0,0,self.svContent.frame.size.width, 55)];
        v.ivIcon.image = [UIImage imageNamed:@"icon_edit.png"];
        v.lblLabel.text = @"Enlaces de vídeo";
        [v updateSize];
        NSArray * videos = (group.videos && ![group.videos isEqualToString:@""])?([group.videos componentsSeparatedByString:@","]):@[];
        if (videos.count == 0 || (videos.count == 1 && [videos[0] isEqualToString:@""])) {
            v.lblValue.text = @"No hay vídeos";
        } else if (videos.count == 1) {
            v.lblValue.text = @"1 vídeo";
        } else {
            v.lblValue.text = [NSString stringWithFormat:@"%ld vídeos", videos.count];
        }
        [Utils setOnClick:v withBlock:^(UIView *sender) {
            PageContext * pc = [[PageContext alloc] init];
            [pc addParam:@"groupId" withIntValue:group._id];
            [pc addParam:@"sectionTitle" withValue:@"Vídeos"];
            [pc addParam:@"sectionSubtitle" withValue:@"Vídeos del grupo"];
            [pc addParam:@"sectionHint" withValue:@"Pulsa el botón + para añadir un nuevo enlace a tus videos de YouTube, Vimeo o plataformas similares"];
            [pc addParam:@"itemName" withValue:@"enlace a vídeo"];
            [pc addParam:@"content" withValue:group.videos];
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
                group.videos = items;
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
            [gFM save:group]; // Guardamos los cambios que tengamos
            [theApp.pages jumpToPage:@"GROUPURLS" withContext:pc withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
        }];
        return v;
    };
    item.onCustomSetupField = ^(FBItem *sender, NSObject *data, BOOL readOnly) {
    };
    item.onCustomUpdateField = ^(FBItem *sender, NSObject *data) {
        FormItemSubitem * v = (FormItemSubitem * )sender.layout;
        NSArray * videos = (group.videos && ![group.videos isEqualToString:@""])?([group.videos componentsSeparatedByString:@","]):@[];
        if (videos.count == 0) {
            v.lblValue.text = @"No hay vídeos";
        } else if (videos.count == 1) {
            v.lblValue.text = @"1 vídeo";
        } else {
            v.lblValue.text = [NSString stringWithFormat:@"%ld vídeos", videos.count];
        }
    };
    item.onCustomValidate = ^NSString *(FBItem *sender, id value) {
        // Miramos que al menos haya 1...
        NSArray * videos = (group.videos && ![group.videos isEqualToString:@""])?([group.videos componentsSeparatedByString:@","]):@[];
        if (!videos || videos.count == 0) {
            return @"Debes indicar al menos un vídeo del grupo";
        } else {
            return nil;
        }
    };
    [gFM add:item];

    return gFM;
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    PageContext * ret = [_ctx clone];
    ret.cachePage = YES;
    return ret;
}


-(void) onRecyclePage:(PageContext *)context {
    [super onRecyclePage:context];
    for (int i=0;i<groupFMs.count;i++) {
        Group * g = groups[i];
        FormBuilder * gFM = groupFMs[i];
        [gFM updateForm:g];
    }
    /*
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
    */
}

-(void) save {
    NSString * res;

    res = [perfFM validate];
    if (res != nil) {
        [theApp MessageBox:res];
        return;
    }
    [perfFM save:performer];

    // Deberíamos guardar el performer
    for (int i=0;i<groups.count;i++) {
        FormBuilder * gFM = groupFMs[i];
        res = [gFM validate];
        if (res != nil) {
            [theApp MessageBox:res];
            return;
        }
    }
    for (int i=0;i<groups.count;i++) {
        Group * group = groups[i];
        FormBuilder * gFM = groupFMs[i];
        [gFM save:group];
    }
    
    // Guardamos perfil y grupo
    // Perfil
    [theApp showBlockView];
    [WSDataManager updatePerformerProfile:performer withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [self updateServerGroups];
        } else {
            [theApp stdError:code];
        }
    }];
    
}

-(void) updateServerGroups {
    if (self->groups.count == 0) {
        [self endUpdate];
    } else {
        Group * group = self->groups[0];
        [self updateServerGroup:group withBlock:^(int code) {
            if (code == WS_SUCCESS) {
                [self->groups removeObjectAtIndex:0];
                [self updateServerGroups];
            } else {
                [theApp stdError:code];
            }
        }];
    }
}

-(void) updateServerGroup:(Group *)group withBlock:(void(^)(int code))completionHandler {
    // Si el grupo ya existe, lo actualizamos
    if (group._id != 0) {
        [theApp showBlockView];
        [WSDataManager updateGroup:group withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            completionHandler(code);
        }];
    } else {
        // Si el grupo no existe, lo creamos
        [theApp showBlockView];
        [WSDataManager newGroup:group.name withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                // Y lo actualizamos
                group._id = [result[@"id"] integerValue];
                [theApp showBlockView];
                [WSDataManager updateGroup:group withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                    [theApp hideBlockView];
                    completionHandler(code);
                }];
            } else {
                completionHandler(code);
            }
        }];
    }

}


-(void) endUpdate {
    NSInteger mode = [self._context intParamByName:@"mode"];
    if (mode == FREEMIUM_MODE_REGISTERBASICDATA) {
        // Vamos a la home
        [theApp.pages jumpToPage:@"HOME" withContext:[[PageContext alloc] init] withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:YES];

    } else if (mode == FREEMIUM_MODE_REGISTERFORPERFORMANCE) {
        // Miramos de registrar la oferta...
        NSString * groups = [self._context paramByName:@"groups"];
        NSInteger performanceId = [self._context intParamByName:@"performanceId"];
        // Aquí hay que seleccionar los grupos marcados
        [theApp showBlockView];
        [WSDataManager performanceRegisterMultiple:groups performanceId:performanceId withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
            [theApp hideBlockView];
            if (code == WS_SUCCESS) {
                /*
                [theApp MessageBox:@"¡Estupendo! Estudiaremos tu solicitud y te iremos informando de su progreso" onCommand:^(Popup *pm, int command, NSObject *data) {
                    [theApp.pages goBack];
                }];
                */
                [theApp.pages goBack];
            } else {
                [theApp stdError:code];
            }
            
        }];

    }
}

@end
