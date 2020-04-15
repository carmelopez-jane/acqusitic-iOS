//
//  PageUserPassword.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageUserPassword.h"
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

@interface PageUserPassword ()

@end

@implementation PageUserPassword

@synthesize vHeader, svContent;

-(void)onEnterPage:(PageContext *)context{
    
    [super onEnterPage:context];

    [self loadNIB:@"PageUserPassword"];

    _ctx = context;
    
    
    account = [[Account alloc] init];

    [self.vHeader setActiveSection:HEADER_SECTION_USER];
    
    self.vHeaderEdit.lblTitle.text = @"Contraseña";
    
    [Utils setOnClick:self.vHeaderEdit.btnSave withBlock:^(UIView *sender) {
        [self save];
    }];
    
    FBItem * item;
    fm1 = [[FormBuilder alloc] init];
    item = [[FBItem alloc] init:@"Indica la contraseña actual" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Contraseña" fieldType:FIELD_TYPE_PASSWORD fieldName:@"oldPassword"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];

    item = [[FBItem alloc] init:@"Indica la nueva contraseña" fieldType:FIELD_TYPE_SECTION];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Nueva Contraseña" fieldType:FIELD_TYPE_PASSWORD fieldName:@"password"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];
    item = [[FBItem alloc] init:@"Repetir Contraseña" fieldType:FIELD_TYPE_PASSWORD fieldName:@"password2"];
    [item addValidator:[[FBRequiredValidator alloc] init]];
    [fm1 add:item];


    int height = [fm1 fillInForm:svContent from:0 withData:account];
    
    self.svContent.contentSize = CGSizeMake(0, height+20);
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
    [fm1 save:account];
    
    if (![account.password isEqualToString:account.password2]) {
        [theApp MessageBox:@"Ambas contraseñas deben ser iguales"];
        return;
    }
    
    [theApp showBlockView];
    [WSDataManager updateProfilePassword:account withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [theApp.pages goBack];
        } else {
            [theApp stdError:code];
        }
    }];
}


@end
