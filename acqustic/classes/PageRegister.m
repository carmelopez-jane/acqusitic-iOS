//
//  PageRegister.m
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageRegister.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "WSDataManager.h"
#import "NSAttributedString+DDHTML.h"
#import "DownOptionsPicker.h"



@interface PageRegister ()

@end

@implementation PageRegister {
    DownOptionsPicker * provPicker;
}

@synthesize seName, seSurname, seLogin, seProvince, pePassword, seGroup, btnRegister, btnLogin;

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

    [self loadNIB:@"PageRegister"];
    
    self.pageView.backgroundColor = [Utils uicolorFromARGB:0xFF2b2b35];
    
    
    NSArray * provOptions = @[
        @"Albacete",
        @"Alicante/Alacant",
        @"Almería",
        @"Araba/Álava",
        @"Asturias",
        @"Ávila",
        @"Badajoz",
        @"Balears, Illes",
        @"Barcelona",
        @"Bizkaia",
        @"Burgos",
        @"Cáceres",
        @"Cádiz",
        @"Cantabria",
        @"Castellón/Castelló",
        @"Ciudad Real",
        @"Córdoba",
        @"Coruña, A",
        @"Cuenca",
        @"Gipuzkoa",
        @"Girona",
        @"Granada",
        @"Guadalajara",
        @"Huelva",
        @"Huesca",
        @"Jaén",
        @"León",
        @"Lleida",
        @"Lugo",
        @"Madrid",
        @"Málaga",
        @"Murcia",
        @"Navarra",
        @"Ourense",
        @"Palencia",
        @"Palmas, Las",
        @"Pontevedra",
        @"Rioja, La",
        @"Salamanca",
        @"Santa Cruz de Tenerife",
        @"Segovia",
        @"Sevilla",
        @"Soria",
        @"Tarragona",
        @"Teruel",
        @"Toledo",
        @"Valencia/València",
        @"Valladolid",
        @"Zamora",
        @"Zaragoza",
        @"Ceuta",
        @"Melilla",
    ];

    NSArray * provValues = @[
        @"02",
        @"03",
        @"04",
        @"01",
        @"33",
        @"05",
        @"06",
        @"07",
        @"08",
        @"48",
        @"09",
        @"10",
        @"11",
        @"39",
        @"12",
        @"13",
        @"14",
        @"15",
        @"16",
        @"20",
        @"17",
        @"18",
        @"19",
        @"21",
        @"22",
        @"23",
        @"24",
        @"25",
        @"27",
        @"28",
        @"29",
        @"30",
        @"31",
        @"32",
        @"34",
        @"35",
        @"36",
        @"26",
        @"37",
        @"38",
        @"40",
        @"41",
        @"42",
        @"43",
        @"44",
        @"45",
        @"46",
        @"47",
        @"49",
        @"50",
        @"51",
        @"52",
    ];

    
    

    self.seName.tfText.placeholder = NSLocalizedString(@"pageregister_name", nil);
    self.seSurname.tfText.placeholder = NSLocalizedString(@"pageregister_surname", nil);
    self.seLogin.tfText.placeholder = NSLocalizedString(@"pageregister_email", nil);
    self.seProvince.tfText.placeholder = @"Provincia";
    self.pePassword.tfText.placeholder = NSLocalizedString(@"pageregister_password", nil);
    self.seGroup.tfText.placeholder = NSLocalizedString(@"pageregister_group", nil);
    self.lblTerms.text = NSLocalizedString(@"pageregister_lopd", nil);
    [self.btnRegister setTitle:NSLocalizedString(@"pageregister_btnregister", nil) forState:UIControlStateNormal];
    [self.btnLogin setTitle:NSLocalizedString(@"pageregister_login", nil) forState:UIControlStateNormal];
    
    self.seLogin.tfText.keyboardType = UIKeyboardTypeEmailAddress;
    
    // Texto con links
    NSString * baseText = self.tvTerms.text;
    baseText = [baseText stringByReplacingOccurrencesOfString:@"política de privacidad" withString:@"<a href='http://privacy'>política de privacidad</a> "];
    baseText = [baseText stringByReplacingOccurrencesOfString:@"términos de uso" withString:@"<a href='http://terms'>términos de uso</a> "];
    baseText = [NSString stringWithFormat:@"<font color='#ffffff'>%@</font> ", baseText];
    self.tvTerms.delegate = self;
    self.tvTerms.attributedText = [NSAttributedString attributedStringFromHTML:baseText normalFont:self.tvTerms.font boldFont:self.tvTerms.font italicFont:self.tvTerms.font];
    self.tvTerms.linkTextAttributes = @{
        NSForegroundColorAttributeName: ACQUSTIC_GREEN,
    };

    //self.swTerms.onTintColor = RACC_YELLOW;
    
    self.seName.tfText.returnKeyType = UIReturnKeyNext;
    self.seName.tfText.delegate = self;
    self.seSurname.tfText.returnKeyType = UIReturnKeyNext;
    self.seSurname.tfText.delegate = self;
    self.seLogin.tfText.returnKeyType = UIReturnKeyNext;
    self.seLogin.tfText.delegate = self;
    self.pePassword.tfText.returnKeyType = UIReturnKeyNext;
    self.pePassword.tfText.delegate = self;
    
    provPicker = [[DownOptionsPicker alloc] initWithTextField:self.seProvince.tfText withData:provOptions andValues:provValues];
    self.seProvince.tfText.placeholder = @"Provincia";
    
    
    [Utils setOnClick:self.btnLogin withBlock:^(UIView *sender) {
        [theApp.pages goBack];
    }];
    
    [Utils setOnClick:self.lblTerms withBlock:^(UIView *sender) {
        [theApp jumpToTerms];
    }];
    
    [self.btnRegister addTarget:self action:@selector(onRegister:) forControlEvents:UIControlEventTouchUpInside];

    
    if (self.vContent.frame.size.height > self.vAll.frame.size.height) {
        CGRect fr = self.vAll.frame;
        fr.origin.y = (self.vContent.frame.size.height - self.vAll.frame.size.height)/2;
        self.vAll.frame = fr;
    }
    self.vContent.contentSize = CGSizeMake(0, self.vAll.frame.origin.y + self.vAll.frame.size.height);
    
}

-(PageContext *)onLeavePage:(NSString *)destPage {
    PageContext * pc = [[PageContext alloc] init];
    pc.cachePage = YES;
    return pc;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.seName.tfText) {
        [textField resignFirstResponder];
        [self.seSurname.tfText becomeFirstResponder];
    }
    else if (textField == self.seSurname.tfText) {
        [textField resignFirstResponder];
        [self.seLogin.tfText becomeFirstResponder];
    }
    else if (textField == self.seLogin.tfText) {
        [textField resignFirstResponder];
        [self.pePassword.tfText becomeFirstResponder];
    }
    else if (textField == self.pePassword.tfText) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    if ([URL.absoluteString isEqualToString:@"http://privacy"]) {
        // Do something
        PageContext * ctx = [[PageContext alloc] init];
        [ctx addParam:@"title" withValue:@"Política de privacidad"];
        [ctx addParam:@"content" withValue:@"privacy"];
        [theApp.pages jumpToPage:@"WEB" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
    } else if ([URL.absoluteString isEqualToString:@"http://terms"]) {
        PageContext * ctx = [[PageContext alloc] init];
        [ctx addParam:@"title" withValue:@"Términnos de uso"];
        [ctx addParam:@"content" withValue:@"legal"];
        [theApp.pages jumpToPage:@"WEB" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
    }
    return NO;
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


-(void) onRegister:(UIButton *)sender {
    NSLog(@"Register");
    
    NSString * name = [self.seName.tfText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * surname = [self.seSurname.tfText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * email = [self.seLogin.tfText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * province = [provPicker getSelectedValue];//[self.seCity.tfText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * group = [self.seGroup.tfText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * pwd = self.pePassword.tfText.text;
    BOOL terms = self.swTerms.on;
    
    if ([name isEqualToString:@""]) {
        [theApp MessageBox:NSLocalizedString(@"pageregister_error_name", nil)];
        return;
    }
    if ([surname isEqualToString:@""]) {
        [theApp MessageBox:NSLocalizedString(@"pageregister_error_surname", nil)];
        return;
    }
    if ([email isEqualToString:@""] || ![self validateEmailWithString:email]) {
        [theApp MessageBox:NSLocalizedString(@"pageregister_error_validemail", nil)];
        return;
    }
    if (province == nil || [province isEqualToString:@""]) {
        [theApp MessageBox:@"Debes indicar en qué provincia sueles trabajar como músico"];
        return;
    }
    if ([pwd isEqualToString:@""]) {
        [theApp MessageBox:NSLocalizedString(@"pageregister_error_password", nil)];
        return;
    }
    if (pwd.length < 8) {
        [theApp MessageBox:@"La contraseña debe tener al menos 8 caracteres"];
        return;
    }
    if (!terms) {
        [theApp MessageBox:NSLocalizedString(@"pageregister_error_lopd", nil)];
        return;
    }
    
    UserInfo * ui = [[UserInfo alloc] init];
    ui.name = name;
    ui.surname = surname;
    ui.email = email;
    ui.province = province;
    ui.group = group;

    [theApp showBlockView];
    [WSDataManager register:ui withPassword:pwd withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            if (theApp.pushDeviceToken) {
                [WSDataManager linkDevice:theApp.appSession.deviceId token:theApp.pushDeviceToken lang:@"es" withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                    if (code == WS_SUCCESS) {
                    }
                    [theApp jumpToStart:YES];
                }];
            } else {
                [theApp jumpToStart:YES];
            }
        } else if (code == WS_ERROR_NOTLOGGEDIN) {
            [theApp MessageBox:NSLocalizedString(@"pageregister_error_invalid", nil)];
        } else if (code == WS_ERROR_ALREADYREGISTERED) {
            [theApp MessageBox:NSLocalizedString(@"pageregister_error_registered", nil)];
        } else if (code == WS_ERROR_WAITINGREGISTRY) {
            [theApp MessageBox:NSLocalizedString(@"pageregister_error_notregistered", nil) onCommand:^(Popup *pm, int command, NSObject *data) {
                if (theApp.pages.historyCount > 0) {
                    [theApp.pages goBack];
                } else {
                    PageContext * ctx = [[PageContext alloc] init];
                    [theApp.pages jumpToPage:@"LOGIN" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:YES];
                }
            }];
        } else if (code == WS_ERROR_NOTACTIVATED) {
            [theApp MessageBox:NSLocalizedString(@"pageregister_error_notactivated", nil) onCommand:^(Popup *pm, int command, NSObject *data) {
                if (theApp.pages.historyCount > 0) {
                    [theApp.pages goBack];
                } else {
                    PageContext * ctx = [[PageContext alloc] init];
                    [theApp.pages jumpToPage:@"LOGIN" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:YES];
                }
            }];
        } else {
            [theApp stdError:code];
        }
    }];

}

@end
