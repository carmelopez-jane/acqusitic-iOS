//
//  PageRecover.m
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageRecover.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "WSDataManager.h"

@interface PageRecover ()

@end

@implementation PageRecover

@synthesize seLogin, btnRecover, btnLogin;

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

    [self loadNIB:@"PageRecover"];
    
    self.seLogin.view.backgroundColor = [Utils uicolorFromARGB:0xFFe5e5e5];
    
    self.seLogin.tfText.placeholder = NSLocalizedString(@"pagerecover_email", nil);
    /*
    [self.btnRecover setTitle:NSLocalizedString(@"pagerecover_btnrecover", nil) forState:UIControlStateNormal];
    [self.btnLogin setTitle:NSLocalizedString(@"pagerecover_login", nil) forState:UIControlStateNormal];
     */
    
    self.seLogin.tfText.keyboardType = UIKeyboardTypeEmailAddress;
    self.seLogin.tfText.returnKeyType = UIReturnKeyGo;
    self.seLogin.tfText.delegate = self;
    
    [Utils setOnClick:self.btnLogin withBlock:^(UIView *sender) {
        [theApp.pages goBack];
    }];
    
    [self.btnRecover addTarget:self action:@selector(onRecover:) forControlEvents:UIControlEventTouchUpInside];

}

-(PageContext *)onLeavePage:(NSString *)destPage {
    return PAGE_HISTORY_NOHISTORY;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.seLogin.tfText) {
        [textField resignFirstResponder];
        [self onRecover:nil];
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

-(void) onRecover:(UIView *)sender {
    NSLog(@"Login");
    NSString * email = [self.seLogin.tfText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([email isEqualToString:@""] || ![self validateEmailWithString:email]) {
        [theApp MessageBox:NSLocalizedString(@"pagerecover_error_validemail", nil)];
        return;
    }
    [theApp showBlockView];
    [WSDataManager recoverPassword:email withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [theApp MessageBox:NSLocalizedString(@"pagerecover_success", nil)];
        } else if (code == WS_ERROR_NOTLOGGEDIN) {
            [theApp MessageBox:NSLocalizedString(@"pagerecover_error_invalid", nil)];
        } else if (code == WS_ERROR_WAITINGREGISTRY) {
            [theApp MessageBox:NSLocalizedString(@"pagerecover_error_notregistered", nil)];
        } else if (code == WS_ERROR_NOTACTIVATED) {
            [theApp MessageBox:NSLocalizedString(@"pagerecover_error_notactivated", nil)];
        } else {
            [theApp stdError:code];
        }
    }];
    
}


@end
