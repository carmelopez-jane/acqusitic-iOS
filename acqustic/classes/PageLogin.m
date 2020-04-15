//
//  PageLogin.m
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageLogin.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "WSDataManager.h"

@interface PageLogin ()

@end

@implementation PageLogin

@synthesize ivLogo, lblLogo, vContent, seLogin, pePassword, btnLogin, lblExplore, btnRegister, lblRecover;

-(UIView *) loadNIB:(NSString *)nibName {
    // Ponemos la vista con el contenido, ajustando tamaño, fondo y demás...
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    UIView * myView = nibViews[0];
    myView.backgroundColor = [UIColor clearColor];
    myView.frame = screenRect;
    [self.pageView addSubview:myView];
    return myView;
}


-(void)onEnterPage:(PageContext *)context{
    
    [super onEnterPage:context];
    //[super setTopColor:RACC_YELLOW];
    [self loadNIB:@"PageLogin"];
    
    self.pageView.backgroundColor = [Utils uicolorFromARGB:0xFF2b2b35];
    
    /*
    self.lblLogo.text = NSLocalizedString(@"pagelogin_title", nil);
     */
    self.seLogin.tfText.placeholder = NSLocalizedString(@"pagelogin_email", nil);
    self.pePassword.tfText.placeholder = NSLocalizedString(@"pagelogin_password", nil);
    /*
    [self.btnLogin setTitle:NSLocalizedString(@"pagelogin_btnlogin", nil) forState:UIControlStateNormal];
    [self.btnRegister setTitle:NSLocalizedString(@"pagelogin_btnregister", nil) forState:UIControlStateNormal];
    self.lblRecover.text = NSLocalizedString(@"pagelogin_recover", nil);
    self.lblExplore.text = NSLocalizedString(@"pagelogin_lblexplore", nil);
    */

    self.seLogin.tfText.keyboardType = UIKeyboardTypeEmailAddress;
    
    self.seLogin.tfText.returnKeyType = UIReturnKeyNext;
    self.seLogin.tfText.delegate = self;
    self.pePassword.tfText.returnKeyType = UIReturnKeyGo;
    self.pePassword.tfText.delegate = self;
    

    [Utils setOnClick:self.lblRecover withBlock:^(UIView *sender) {
        [theApp.pages jumpToPage:@"RECOVER" withContext:[self._context clone]];
    }];
    [Utils setOnClick:self.lblExplore withBlock:^(UIView *sender) {
        [self onExplore:nil];
    }];
    
    [self.btnLogin addTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnRegister addTarget:self action:@selector(onRegister:) forControlEvents:UIControlEventTouchUpInside];
    
    /*self.btnRegister.backgroundColor = [UIColor colorWithRed:73.0/255.0 green:176.0/255.0 blue:110.0/255.0 alpha:1.0];
    [self.btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     */
    
    vContent.contentSize = CGSizeMake(0, 418+249);
}

-(PageContext *)onLeavePage:(NSString *)destPage {
    return [self._context clone];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.seLogin.tfText) {
        [textField resignFirstResponder];
        [self.pePassword.tfText becomeFirstResponder];
    }
    else if (textField == self.pePassword.tfText) {
        [textField resignFirstResponder];
        [self onLogin:nil];
    }
    return YES;
}

- (BOOL)validateEmailWithString:(NSString*)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(void) onLogin:(UIView *)sender {
    NSLog(@"Login");
    NSString * email = [self.seLogin.tfText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * pwd = self.pePassword.tfText.text;
    
    if ([email isEqualToString:@""] || ![self validateEmailWithString:email]) {
        [theApp MessageBox:NSLocalizedString(@"pagelogin_error_validemail", nil)];
        return;
    }
    if ([pwd isEqualToString:@""]) {
        [theApp MessageBox:NSLocalizedString(@"pagelogin_error_password", nil)];
    }
    
    [theApp showBlockView];
    [WSDataManager loginWithEmail:email andPassword:pwd withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            // miramos de enviar el device token al servidor, si no se había hecho ya...
            [WSDataManager linkDevice:theApp.appSession.deviceId token:theApp.pushDeviceToken lang:NSLocalizedString(@"lang", nil) withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
            }];
            // Saltamos a la HOME
            PageContext * ctx = [[PageContext alloc] init];
            [theApp.pages jumpToPage:@"HOME" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:YES];
        } else if (code == WS_ERROR_NOTLOGGEDIN) {
            [theApp MessageBox:NSLocalizedString(@"pagelogin_error_invalid", nil)];
        } else if (code == WS_ERROR_WAITINGREGISTRY) {
            [theApp MessageBox:NSLocalizedString(@"pagelogin_error_notregistered", nil)];
        } else if (code == WS_ERROR_NOTACTIVATED) {
            [theApp MessageBox:NSLocalizedString(@"pagelogin_error_notactivated", nil)];
        } else {
            [theApp stdError:code];
        }
    }];
    
}

-(void) onExplore:(UIView *)sender {
    // Saltamos a la HOME
    PageContext * ctx = [[PageContext alloc] init];
    [theApp.pages jumpToPage:@"HOME" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:YES];
}

-(void) onRegister:(UIView *)sender {
    [theApp.pages jumpToPage:@"REGISTER" withContext:[self._context clone]];
}

@end
