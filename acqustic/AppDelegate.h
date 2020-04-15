//
//  AppDelegate.h
//  vlexmobile
//
//  Created by Javier Garcés on 21/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageEngine.h"
#import "ViewController.h"
#import "Popup.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AppSession.h"
#import "AppConfig.h"

//@import Firebase;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate> {
    // Vista principal...
    UIView * containerView;
    
    // Motor de páginas
    PageEngine * _pages;
    
    // Bloqueo para conexiones a Internet
    UIView * blockView;
    UIActivityIndicatorView * blockSpinner;
    int blockCount;
    
    // Popup (y bloqueo para los popups)
    NSMutableArray * popups;
    int popupCount;
    
    // Token de Push
    NSData * _pushDeviceTokenData;
    NSString * _pushDeviceToken;
    
    BOOL _gcmDeviceLinked;
    
    
    // Audio
    AVAudioPlayer *player;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, readonly) PageEngine * pages;
@property (nonatomic, readonly) NSString * pushDeviceToken;
@property (nonatomic, readonly) UIImage * backgroundImage;
@property (nonatomic, readonly) NSMutableDictionary * inAppProducts;
@property (strong, nonatomic) AppSession * appSession;
@property (strong, nonatomic) AppConfig * appConfig;
@property int serviceAnyId;
@property (strong, nonatomic) NSString * serviceAnyTelephone;
@property (strong, nonatomic) NSDictionary * categories;
@property (strong, nonatomic) NSArray * services;
@property BOOL soundsEnabled;
@property CGFloat keyboardY;

// Transiciones habituales...
+(PageTransition *) transPushRL;
+(PageTransition *) transPushLR;

// API de popups
-(void)showPopup:(UIView *)popup;
-(void)closePopup:(UIView *)popup;
-(BOOL)popupShown;
-(void)closeAllPopups;

-(void)MessageBox:(NSString *)message;
-(void)MessageBox:(NSString *)message onCommand:(Popup_onCommand)onCommand;
-(void)QueryMessage:(NSString *)message withYes:(NSString *)yes andNo:(NSString *)no onCommand:(Popup_onCommand)onCommand;
-(void)Prompt:(NSString *)message defaultText:(NSString *)defaultText withYes:(NSString *)yes andNo:(NSString *)no onCommand:(Popup_onCommand)onCommand;
-(void)Prompt:(NSString *)message defaultText:(NSString *)defaultText withYes:(NSString *)yes andNo:(NSString *)no andExtraButton:(NSString *)extra onCommand:(Popup_onCommand)onCommand;
-(void)Menu:(NSString *)message withOptions:(NSArray *)options onCommand:(Popup_onCommand)onCommand;

-(void) showNotification:(NSString *)message;
-(void) showNotification:(NSString *)message withTitle:(NSString *)title;

-(BOOL)stdError:(int)code;
-(BOOL) isNetworkAvailable;
-(BOOL) hasNotch;

// Bloqueo visual para conexiones a Internet
-(void) initBlockView;
-(void) showBlockView;
-(void) hideBlockView;

// Teclado
-(void) dismissKeyboard;

// OS y App Version
+(NSString *)getAppVersion;
+(NSString *)getDeviceModel;
+(NSString *)getSOVersion;


// API
//-----------------------------------------------------
// LOGIN, LOGOUT Y REDES SOCIALES
//-----------------------------------------------------
-(void) logout;

//-----------------------------------------------------
// SHARE
//-----------------------------------------------------
-(void) shareFacebook:(NSString *)id type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL;
-(void) shareTwitter:(NSString *)id type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL;
-(void) shareGoogle:(NSString *)id type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL;
-(void) shareMail:(NSString *)id type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL;
-(void) shareURL:(NSString *)id type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL;
-(void) shareAll:(NSString *)id type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL;

//-----------------------------------------------------
// AUDIO
//-----------------------------------------------------
-(void) playAudio:(NSString *)audio;

//-----------------------------------------------------
// NAVEGACION GLOBAL
//-----------------------------------------------------
// Saltar al comienzo de la aplicaciÃ³n una vez revisado el proceso
// de login/registro, sea Ã©ste nuevo o bien se acabe de loginar/registrar
// el usuario.
// La rutina mira si el usuario tiene todavÃ­a algun paso de inicializaciÃ³n
// pendiente y en caso contrario, pasa al Stream.
-(void) jumpToStart:(BOOL)completeProfile;
-(void) jumpToPrivacy;
-(void) jumpToTerms;
-(void) jumpToFAQs;
-(void) jumpToInvite;

-(NSDictionary *)findService:(int)serviceId;
-(NSArray *)filteredServices:(NSArray *)allItems withText:(NSString *)text;
-(NSString *)findCatName:(int)catId;
-(NSString *)findCatNameForService:(NSDictionary *)service;

-(void) updateBadge:(int) numBadges;

//-----------------------------------------------------
// TRACKING
//-----------------------------------------------------
-(void) sendTrackingEvent:(NSString *)event withParams:(NSDictionary *)params;

@end

