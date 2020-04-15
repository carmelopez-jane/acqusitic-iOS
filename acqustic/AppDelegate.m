//
//  AppDelegate.m
//  vlexmobile
//
//  Created by Javier Garcés on 21/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "Acqustic.h"
#import "IQKeyboardManager.h"
#import "AppDelegate.h"
#import "PageEngine.h"
#import "PageTransitionPushFromTo.h"
#import "Popup.h"
#import "Reachability.h"
#import "AppSession.h"
#import "AppConfig.h"
#import "Utils.h"
#import "WSDataManager.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import <sys/utsname.h> // import it in your header or implementation file.

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

// VER https://stackoverflow.com/questions/39854929/firebase-cloud-messaging-appdelegate-error
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif
@import Firebase;
//@import FirebaseInstanceID;
#import <Toast/UIView+Toast.h>

#import "PagePortada.h"
#import "PageLogin.h"
#import "PageRecover.h"
#import "PageRegister.h"
#import "PageWeb.h"
#import "PageHome.h"
#import "PageNotis.h"
#import "PageChats.h"
#import "PageChat.h"
#import "PageUser.h"
#import "PageUserProfile.h"
#import "PageUserPassword.h"
#import "PageUserSubscription.h"
#import "PagePerfRegister.h"
#import "PagePerfResume.h"
#import "PagePerfConfirmCandidate.h"
#import "PagePerfConfirmSelected.h"
#import "PageGroup.h"
#import "PageGroupMembers.h"
#import "PageGroupMember.h"
#import "PageGroupAlbums.h"
#import "PageGroupAlbum.h"
#import "PageGroupInvoicereqs.h"
#import "PageGroupInvoicereq.h"
#import "PageGroupRepertoires.h"
#import "PageGroupRepertoire.h"
#import "PageGroupRepertoires.h"
#import "PageGroupRepertoire.h"
#import "PageGroupAgenda.h"
#import "PageGroupAgendaItem.h"
#import "PageGroupSong.h"
#import "PageGroupUrls.h"
#import "PageUploadImage.h"
#import "PageGroupImages.h"
#import "PageRegisterFreemium.h"
#import "PageCompleteFreemium.h"


// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above. Implement FIRMessagingDelegate to receive data message via FCM for
// devices running iOS 10 and above.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>
@end
#endif

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif


@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize pages = _pages;
@synthesize pushDeviceToken = _pushDeviceToken;
@synthesize backgroundImage = _backgroundImage;
@synthesize inAppProducts = inAppProducts;
@synthesize appSession;
@synthesize appConfig;
@synthesize serviceAnyId, categories, services;
@synthesize soundsEnabled;



static PageTransitionPushFromTo * tPushRL;
static PageTransitionPushFromTo * tPushLR;

AppDelegate * theApp = NULL;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Quitamos la status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    theApp = self;
    
    self.soundsEnabled = YES;
    
    self.appSession = [[AppSession alloc] init];
    self.appConfig = [[AppConfig alloc] init];
    
    self.services = nil;
    
    // Inicializamos el WSDataManager
    [WSDataManager init];
    
    // Inicializamos KeyboardManager y info general del keyboard
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.keyboardY = screenRect.size.height;
    
    /* Fuentes (debug) */
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
    /**/
    
    /* Pager (genérico)
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [Utils uicolorFromARGB:0xFF2DC8FD];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.backgroundColor = [UIColor clearColor];
     */
    
    [AppSession init];
    _gcmDeviceLinked = NO;
    
    
    // Inicializamos algunas variables
    popups = [[NSMutableArray alloc] init];
    popupCount = 0;
    
    // Nos registramos para mensajes Push
    _pushDeviceToken = @"null-device";

    // Register for remote notifications
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [application registerForRemoteNotificationTypes:allNotificationTypes];
#pragma clang diagnostic pop
    } else {
        // iOS 8 or later
        // [START register_for_notifications]
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            UNAuthorizationOptions authOptions =
            UNAuthorizationOptionAlert
            | UNAuthorizationOptionSound
            | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter]
             requestAuthorizationWithOptions:authOptions
             completionHandler:^(BOOL granted, NSError * _Nullable error) {
             }
             ];
            
            // For iOS 10 display notification (sent via APNS)
            [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
            // For iOS 10 data message (sent via FCM)
            //REVISAR [[FIRMessaging messaging] setRemoteMessageDelegate:self];
#endif
        }
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        // [END register_for_notifications]
    }
    
    // [START configure_firebase]
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                        NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching remote instance ID: %@", error);
        } else {
            NSLog(@"Remote instance ID token: %@", result.token);
            // La enviamos al servidor...
            if (theApp.appSession.isLoggedIn) {
                [WSDataManager linkDevice:theApp.appSession.deviceId token:result.token lang:NSLocalizedString(@"lang", nil) withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
                    
                }];
            }
        }
    }];
    
    // [END configure_firebase]
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];

    
    [application registerForRemoteNotifications];

    // Notificaciones remotas
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    // Notificaciones locales, para el badge
    [application registerUserNotificationSettings:settings];
    
    
    self.viewController = (ViewController *)self.window.rootViewController;
    
    NSLog(@"SCREEN SIZE: %f, %f", [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    if (@available(iOS 13, *)) {
        self.viewController.view.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

    // Creamos las transiciones por defecto
    tPushRL = [[PageTransitionPushFromTo alloc] init];
    tPushRL.duration = [NSNumber numberWithDouble:0.2];
    tPushLR = [[PageTransitionPushFromTo alloc] init];
    tPushLR.type = pftLeftToRight;
    tPushLR.duration = [NSNumber numberWithDouble:0.2];
    
    
    // Aquí creamos el sistema de páginas...
    containerView = self.viewController.view;
    [containerView setBackgroundColor:[Utils uicolorFromARGB:0xFFFFFFFF]];
    // Forzamos el tamaño REAL de la pantalla, pues no tenemos banda...
    // MIRAR XIB IDIOMAS
    containerView.frame = screenRect;
    
    NSLog(@"POSICIONANDO CONTAINERVIEW: %f %f %f %f", containerView.frame.origin.x, containerView.frame.origin.y, containerView.frame.size.width, containerView.frame.size.height);
    
    UIView * pagesView = [[UIView alloc] initWithFrame:containerView.frame];
    [containerView addSubview:pagesView];
    _pages = [[PageEngine alloc] initWithView:/*containerView*/pagesView];

    // Añadimos las páginas
    [_pages addPage:[[PagePortada alloc] init] withName:@"PORTADA"];
    [_pages addPage:[[PageLogin alloc] init] withName:@"LOGIN"];
    [_pages addPage:[[PageRecover alloc] init] withName:@"RECOVER"];
    [_pages addPage:[[PageRegister alloc] init] withName:@"REGISTER"];
    [_pages addPage:[[PageRegisterFreemium alloc] init] withName:@"REGISTERFREEMIUM"];
    [_pages addPage:[[PageHome alloc] init] withName:@"HOME"];
    [_pages addPage:[[PageNotis alloc] init] withName:@"NOTIS"];
    [_pages addPage:[[PageChats alloc] init] withName:@"CHATS"];
    [_pages addPage:[[PageChat alloc] init] withName:@"CHAT"];
    [_pages addPage:[[PageUser alloc] init] withName:@"USER"];
    [_pages addPage:[[PageUserProfile alloc] init] withName:@"USERPROFILE"];
    [_pages addPage:[[PageUserPassword alloc] init] withName:@"USERPASSWORD"];
    [_pages addPage:[[PageUserSubscription alloc] init] withName:@"USERSUBSCRIPTION"];
    [_pages addPage:[[PagePerfRegister alloc] init] withName:@"PERFORMANCEREGISTER"];
    [_pages addPage:[[PagePerfResume alloc] init] withName:@"PERFORMANCERESUME"];
    [_pages addPage:[[PagePerfConfirmCandidate alloc] init] withName:@"PERFORMANCECONFIRMCANDIDATE"];
    [_pages addPage:[[PagePerfConfirmSelected alloc] init] withName:@"PERFORMANCECONFIRMSELECTED"];
    [_pages addPage:[[PageWeb alloc] init] withName:@"WEB"];

    [_pages addPage:[[PageGroup alloc] init] withName:@"GROUP"];
    [_pages addPage:[[PageGroupMembers alloc] init] withName:@"GROUPMEMBERS"];
    [_pages addPage:[[PageGroupMember alloc] init] withName:@"GROUPMEMBER"];
    [_pages addPage:[[PageGroupAlbums alloc] init] withName:@"GROUPALBUMS"];
    [_pages addPage:[[PageGroupAlbum alloc] init] withName:@"GROUPALBUM"];
    [_pages addPage:[[PageGroupInvoicereqs alloc] init] withName:@"GROUPINVOICEREQS"];
    [_pages addPage:[[PageGroupInvoicereq alloc] init] withName:@"GROUPINVOICEREQ"];
    [_pages addPage:[[PageGroupRepertoires alloc] init] withName:@"GROUPREPERTOIRES"];
    [_pages addPage:[[PageGroupRepertoire alloc] init] withName:@"GROUPREPERTOIRE"];
    [_pages addPage:[[PageGroupAgenda alloc] init] withName:@"GROUPAGENDA"];
    [_pages addPage:[[PageGroupAgendaItem alloc] init] withName:@"GROUPAGENDAITEM"];
    [_pages addPage:[[PageGroupSong alloc] init] withName:@"GROUPSONG"];
    [_pages addPage:[[PageGroupUrls alloc] init] withName:@"GROUPURLS"];
    [_pages addPage:[[PageGroupImages alloc] init] withName:@"GROUPIMAGES"];
    [_pages addPage:[[PageUploadImage alloc] init] withName:@"UPLOADIMAGE"];
    [_pages addPage:[[PageCompleteFreemium alloc] init] withName:@"COMPLETEFREEMIUM"];


    // Saltamos a la primera página
    [_pages jumpToPage:@"PORTADA" withContext: nil];
    
    // Creamos el spinner (bloqueo) - por encima de TODO lo demás
    [self initBlockView];
    
    //[self addPTPVCard:@"4539232076648253" expirityDate:@"0520" cvv:@"123"];
    
    // Facebook
    [FBSDKApplicationDelegate.sharedInstance application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}


- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
    // La enviamos al servidor...
    _pushDeviceToken = fcmToken;
    if (theApp.appSession.isLoggedIn) {
        [WSDataManager linkDevice:theApp.appSession.deviceId token:fcmToken lang:NSLocalizedString(@"lang", nil) withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
            
        }];
    }
    
}

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Print full message.
    NSLog(@"%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Let FCM know about the message for analytics etc.
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    [self processNotificationMessage:userInfo];
    
    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Print full message.
    NSLog(@"%@", userInfo);
}
// [END receive_message]

-(void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    NSDictionary * userInfo = remoteMessage.appData;
    
    // Let FCM know about the message for analytics etc.
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    [self processNotificationMessage:userInfo];
    
    NSLog(@"FIR MESSAGING: %@", userInfo);
}

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Print message ID.
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Let FCM know about the message for analytics etc.
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    [self processNotificationMessage:userInfo];
    

    // Print full message.
    NSLog(@"%@", userInfo);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
    // Let FCM know about the message for analytics etc.
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    [self processNotificationMessage:userInfo];
    

    NSLog(@"%@", userInfo);
}
#endif
// [END ios_10_message_handling]

// [START ios_10_data_message_handling]
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Receive data message on iOS 10 devices while app is in the foreground.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    NSDictionary * userInfo = remoteMessage.appData;
    
    // Let FCM know about the message for analytics etc.
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    [self processNotificationMessage:userInfo];

    NSLog(@"%@", [remoteMessage appData]);
}
#endif
// [END ios_10_data_message_handling]


-(void)processNotificationMessage:(NSDictionary *)userInfo {
    int chatId = 0;
    if (userInfo[@"chatId"] && userInfo[@"chatId"] != NSNull.null) {
        chatId = [((NSNumber *)userInfo[@"chatId"]) intValue];
    }
    int notiId = 0;
    if (userInfo[@"notiId"] && userInfo[@"notiId"] != NSNull.null) {
        notiId = [((NSNumber *)userInfo[@"notiId"]) intValue];
    }
    
    Page * curPage = [self.pages getCurPage];
    
    if (chatId != 0) { // CHAT
        if ([curPage isKindOfClass:PageChats.class]) {
            [((PageChats *)curPage) refresh];
        } else if ([curPage isKindOfClass:PageChat.class]) {
            [((PageChat *)curPage) refresh];
        }
    } else if (notiId != 0) { // NOTIFICACIONES
        if ([curPage isKindOfClass:PageNotis.class])
            [((PageNotis *)curPage) refresh];
    }
    // Actualizamos cualquiera que tenga badges
    if ([curPage isKindOfClass:PageBase.class]) {
        [((PageBase *)curPage) refreshBadges];
    }
    /*
    BOOL showPush = YES;
    if (taskId != 0 && curPage != nil) {
        if ([curPage.pageName isEqualToString:@"TASKCHAT"]) {
            PageTaskChat *pc = (PageTaskChat *)curPage;
            if (pc.taskId == taskId) {
                [pc pushReceived:userInfo];
                showPush = NO;
            }
        } else if ([curPage.pageName isEqualToString:@"TASKS"]) {
            PageTasks *pc = (PageTasks *)curPage;
            [pc pushReceived:userInfo];
        }
    }*/
    
    /*
    NSNumber *badge = nil;
    NSString * message = nil;
    NSString * title = nil;

    if (userInfo[@"notification"]) {
        message = userInfo[@"notification"][@"body"];
        title = userInfo[@"taskName"];
        badge = userInfo[@"notification"][@"badge"];
        if ((NSObject *)badge == NSNull.null) {
            badge = nil;
        }
    } else if (userInfo[@"aps"]) {
        NSDictionary * aps = userInfo[@"aps"];
        badge = aps[@"badge"];
        if ((NSObject *)badge == NSNull.null) {
            badge = nil;
        }
        NSDictionary * alert = aps[@"alert"];
        if (alert) {
            title = alert[@"title"];
            message = alert[@"body"];
        }
    }

    if (badge) {
        [self updateBadge:[badge intValue]];
    }

    if (showPush && message) {
        if (title && ((NSObject *)title) != NSNull.null) {
            [self showNotification:message withTitle:title];
        } else {
            [self showNotification:message];
        }
    }
     */
}


// [START refresh_token]
- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    //NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
        if (result != nil) {
            NSString * refreshedToken = result.token;
            NSLog(@"InstanceID token: %@", refreshedToken);
            
            // Connect to FCM since connection may have failed when attempted before having a token.
            [self connectToFcm];
            
            // TODO: If necessary send token to application server.
            // La enviamos al servidor...
            theApp->_pushDeviceToken = refreshedToken;
            if (theApp.appSession.isLoggedIn) {
                [WSDataManager linkDevice:theApp.appSession.deviceId token:refreshedToken lang:NSLocalizedString(@"lang", nil) withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
                    
                }];
            }
            
        }
    }];
}
// [END refresh_token]

// [START connect_to_fcm]
- (void)connectToFcm {
    /*
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
     */
}
// [END connect_to_fcm]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
// the InstanceID token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs token retrieved: %@", deviceToken);
    
    // With swizzling disabled you must set the APNs token here.
    //[[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
    [FIRMessaging messaging].APNSToken = deviceToken;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /*
    [[FIRMessaging messaging] disconnect];
     */
    
    if (_pages != nil)
        [_pages onDeactivate];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (_pages != nil)
        [_pages onActivate];
    // Actualizamos el perfil del usuario
    [theApp updateUserProfile:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
        // your other code here.... }
    [self connectToFcm];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //[FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *str = [NSString stringWithFormat:@"%@",deviceToken];
    NSString *newString = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@">" withString:@""];
    //[[NSUserDefaults standardUserDefaults] setObject:newString forKey:@"deviceToken"];
    NSLog(@"Your deviceToken ---> %@",newString);
    
    // Nos guardamos el deviceToken para mandarlo a nuestro servidor
    _pushDeviceTokenData = deviceToken;
    _pushDeviceToken = newString;
    
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"REGISTER DEVICE TOKEN ERROR: %@", error);
    _pushDeviceTokenData = nil;
    _pushDeviceToken = [AppSession_instance getRandomDeviceId];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // NOS LLEGA TANTO SI SE ABRE LA NOTIFICACION FUERA COMO SI NO
    UIApplicationState state = [application applicationState];
    // Si la aplicación estaba funcionando
    if (state == UIApplicationStateActive) {
    } else { // Si estaba en background y ha pasado a foreground
    }
}
*/


- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {
    return [self application:app
                     openURL:url
           sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                  annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    
    
    if (dynamicLink) {
        [theApp handleDynamicLink:dynamicLink.url];
        return YES;
    }
    
    BOOL handled = [FBSDKApplicationDelegate.sharedInstance application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    if (handled) {
        return YES;
    }
    return NO;
}


/*
-(BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler {
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        // Si no estamos loginados realmente, saltamos al login
        UserInfo * inf = AppSession_instance.userInfo;
        if (inf == nil || inf.loggedIn == LOGGED_NOTLOGGEDIN) {
            [theApp MessageBox:@"Por favor, regístrate para poder ver este contenido."];
            return YES;
        }
        //NSURL * url = userActivity.webpageURL;
        //NSLog(@"RECIBIDA URL: %@", url);
        //[theApp jumpToLink:[url absoluteString]];
    }
    return YES;
}
 */


#if defined(__IPHONE_12_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_12_0)
- (BOOL)application:(UIApplication *)application
continueUserActivity:(nonnull NSUserActivity *)userActivity
 restorationHandler:
(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
    BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                            completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                                                         NSError * _Nullable error) {
                                                                if (dynamicLink) {
                                                                    [theApp handleDynamicLink:dynamicLink.url];
                                                                }
                                                            }];
    return handled;
}
#else
- (BOOL)application:(UIApplication *)application
continueUserActivity:(nonnull NSUserActivity *)userActivity
restorationHandler:
    (nonnull void (^)(NSArray *_Nullable))restorationHandler {
        BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                                completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                                                             NSError * _Nullable error) {
                                                                    if (dynamicLink) {
                                                                        [theApp handleDynamicLink:dynamicLink.url];
                                                                    }
                                                                }];
        return handled;
    }
#endif  // __IPHONE_12_0


-(void) handleDynamicLink:(NSURL *)url {
    
    if (url) {
        // Miramos a ver...
        PageContext * ctx = [[PageContext alloc] init];
        NSString * urlString = url.absoluteString;
        if ([urlString containsString:@"/home"]) {
            [theApp.pages jumpToPage:@"HOME" withContext:ctx];
        } else if ([urlString containsString:@"/hogar"]) {
            [self jumpToSection:@"tareas_hogar"];
        } else if ([urlString containsString:@"/movilidad"]) {
            [self jumpToSection:@"movilidad"];
        } else if ([urlString containsString:@"/mascotas"]) {
            [self jumpToSection:@"mascotas"];
        } else if ([urlString containsString:@"/ocio"]) {
            [self jumpToSection:@"ocio_viajes"];
        } else if ([urlString containsString:@"/recados"]) {
            [self jumpToSection:@"recados"];
        } else if ([urlString containsString:@"/familia"]) {
            [self jumpToSection:@"familia_salud"];
        } else if ([urlString containsString:@"/reparaciones"]) {
            [self jumpToSection:@"reparaciones"];
        } else if ([urlString containsString:@"/tramites"]) {
            [self jumpToSection:@"tramites"];
        } else if ([urlString containsString:@"/pago"]) {
            [self jumpToProfileBilling];
        }
    } else {
        // NO HACEMOS NADA...
        // Dynamic link has empty deep link. This situation will happens if
        // Firebase Dynamic Links iOS SDK tried to retrieve pending dynamic link,
        // but pending link is not available for this device/App combination.
        // At this point you may display default onboarding view.
    }
}
    
-(void) jumpToSection:(NSString *)section {
    /*
    [WSDataManager getServices:^(int code, NSDictionary *result) {
        if (code == WS_SUCCESS) {
            theApp.categories = result[@"categories"];
            theApp.services = result[@"services"];
            theApp.serviceAnyId = [result[@"anyService"] intValue];
            theApp.serviceAnyTelephone = result[@"anyTelephone"];
            PageContext * ctx = [[PageContext alloc] init];
            [ctx addParam:@"cat" withValue:section];
            [theApp.pages jumpToPage:@"SERVICES" withContext:ctx];
        } else {
            [theApp stdError:code];
        }
    }];
    */
}
    
-(void) jumpToProfileBilling {
    if (!theApp.appSession.isLoggedIn) {
        PageContext * ctx = [[PageContext alloc] init];
        [theApp.pages jumpToPage:@"LOGIN" withContext:ctx];
    } else {
        PageContext * ctx = [[PageContext alloc] init];
        [theApp.pages jumpToPage:@"PROFILEBILLING" withContext:ctx];
    }
}
                        
                        
                        
- (void)keyboardWillHide:(NSNotification *)notification
{
    NSLog(@"KEYBOARD HIDE");
    PageBase * pg = (PageBase *)[self.pages getCurPage];
    if ([pg isKindOfClass:PageBase.class]) {
        [pg onHideKeyboard];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    // keyboard frame is in window coordinates
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardY = keyboardFrame.origin.y;
    NSLog(@"KEYBOARD FRAME: %f, %f, %f, %f", keyboardFrame.origin.x, keyboardFrame.origin.y, keyboardFrame.size.width, keyboardFrame.size.height);
    PageBase * pg = (PageBase *)[self.pages getCurPage];
    if ([pg isKindOfClass:PageBase.class]) {
        [pg onShowKeyboard:keyboardFrame];
    }
}


// Transiciones habituales...
+(PageTransition *) transPushRL
{
    return tPushRL;
}

+(PageTransition *) transPushLR
{
    return tPushLR;
}

-(void) initBlockView
{
    CGRect allRect = [[UIScreen mainScreen] bounds];
    // Creamos la vista general del bloqueo (con spinner)
    blockView = [[UIView alloc] initWithFrame:containerView.frame];
    // Creamos el fondo
    UIView * fondo = [[UIView alloc] initWithFrame:containerView.frame];
    fondo.backgroundColor = [UIColor blackColor];
    fondo.alpha = 0.4;
    [blockView addSubview:fondo];
    // Creamos el spinner
    blockSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    /*
     blockSpinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
     | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
     blockSpinner.frame = containerView.frame;
     */
    [blockView addSubview:blockSpinner];
    
    UILabel * label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"Helvetica" size:20];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(2,2);
    label.text = @"Cargando...";
    //[Utils adjustUILabelSize:label];
    [blockView addSubview:label];
    
    int TotalWidth = blockSpinner.frame.size.width + 10 + label.frame.size.width;
    
    NSLog(@"SPINNER: %f,%f %fx%f %d", blockSpinner.frame.origin.x, blockSpinner.frame.origin.y, blockSpinner.frame.size.width, blockSpinner.frame.size.height, TotalWidth);
    
    
    blockSpinner.frame = CGRectMake((allRect.size.width-TotalWidth)/2, (allRect.size.height-blockSpinner.frame.size.height)/2, blockSpinner.frame.size.width, blockSpinner.frame.size.height);
    label.frame = CGRectMake(blockSpinner.frame.origin.x + blockSpinner.frame.size.width+10, (allRect.size.height-label.frame.size.height)/2, label.frame.size.width, label.frame.size.height);
    
    NSLog(@"SPINNER: %f,%f %fx%f", blockSpinner.frame.origin.x, blockSpinner.frame.origin.y, blockSpinner.frame.size.width, blockSpinner.frame.size.height);
    
    blockView.hidden = YES;
}

-(void) showBlockView
{
    blockCount++;
    if (blockView.hidden == YES)
    {
        //[blockSpinner sizeToFit];
        [blockSpinner startAnimating];
        //blockSpinner.center = containerView.center;
        
        [containerView addSubview:blockView];
        blockView.hidden = NO;
    }
}

-(void) hideBlockView
{
    blockCount--;
    
    if (blockCount <= 0)
    {
        [blockSpinner stopAnimating];
        blockView.hidden = YES;
        [blockView removeFromSuperview];
    }
}

-(void) dismissKeyboard
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];    
}

+(NSString *)getAppVersion {
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    NSString * vText = [NSString stringWithFormat:@"v. %@.%@", version, build];
    return vText;
}

+(NSString *)getDeviceModel {
    // Ver: http://stackoverflow.com/questions/11197509/ios-how-to-get-device-make-and-model
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString  * deviceType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString  * deviceModel;
    if ([deviceType isEqualToString:@"i386"]) {
        deviceModel = @"(simulador)";
    } else if ([deviceType isEqualToString:@"x86_64"]) {
        deviceModel = @"(simulador 64 bits)";
    } else if ([deviceType isEqualToString:@"iPhone3,1"]) {
        deviceModel = @"(iPhone 4)";
    } else if ([deviceType isEqualToString:@"iPhone4,1"]) {
        deviceModel = @"(iPhone 4S)";
    } else if ([deviceType isEqualToString:@"iPhone5,1"]) {
        deviceModel = @"(iPhone 5 - AT&T/Canada)";
    } else if ([deviceType isEqualToString:@"iPhone5,2"]) {
        deviceModel = @"(iPhone 5)";
    } else if ([deviceType isEqualToString:@"iPhone5,3"]) {
        deviceModel = @"(iPhone 5C)";
    } else if ([deviceType isEqualToString:@"iPhone5,4"]) {
        deviceModel = @"(iPhone 5C)";
    } else if ([deviceType isEqualToString:@"iPhone6,1"]) {
        deviceModel = @"(iPhone 5S)";
    } else if ([deviceType isEqualToString:@"iPhone6,2"]) {
        deviceModel = @"(iPhone 5S)";
    } else if ([deviceType isEqualToString:@"iPhone7,1"]) {
        deviceModel = @"(iPhone 6 Plus)";
    } else if ([deviceType isEqualToString:@"iPhone7,2"]) {
        deviceModel = @"(iPhone 6)";
    } else if ([deviceType isEqualToString:@"iPhone8,1"]) {
        deviceModel = @"(iPhone 6S)";
    } else if ([deviceType isEqualToString:@"iPhone8,2"]) {
        deviceModel = @"(iPhone 6S Plus)";
    } else if ([deviceType isEqualToString:@"iPhone8,4"]) {
        deviceModel = @"(iPhone SE)";
    } else if ([deviceType isEqualToString:@"iPhone9,1"]) {
        deviceModel = @"(iPhone 7 CDMA)";
    } else if ([deviceType isEqualToString:@"iPhone9,2"]) {
        deviceModel = @"(iPhone 7 Plus CDMA)";
    } else if ([deviceType isEqualToString:@"iPhone9,3"]) {
        deviceModel = @"(iPhone 7 GSM)";
    } else if ([deviceType isEqualToString:@"iPhone9,4"]) {
        deviceModel = @"(iPhone 7 Plus GSM)";
    } else if ([deviceType isEqualToString:@"iPhone10,1"]) {
        deviceModel = @"(iPhone 8 CDMA)";
    } else if ([deviceType isEqualToString:@"iPhone10,4"]) {
        deviceModel = @"(iPhone 8 GSM)";
    } else if ([deviceType isEqualToString:@"iPhone10,2"]) {
        deviceModel = @"(iPhone 8 Plus CDMA)";
    } else if ([deviceType isEqualToString:@"iPhone10,5"]) {
        deviceModel = @"(iPhone 8 Plus GSM)";
    } else if ([deviceType isEqualToString:@"iPhone10,3"]) {
        deviceModel = @"(iPhone X CDMA)";
    } else if ([deviceType isEqualToString:@"iPhone10,6"]) {
        deviceModel = @"(iPhone X GSM)";
    } else if ([deviceType isEqualToString:@"iPhone11,2"]) {
        deviceModel = @"(iPhone XS GSM)";
    } else if ([deviceType isEqualToString:@"iPhone11,4"]) {
        deviceModel = @"(iPhone XS Max)";
    } else if ([deviceType isEqualToString:@"iPhone11,6"]) {
        deviceModel = @"(iPhone XS Max China)";
    } else if ([deviceType isEqualToString:@"iPhone11,8"]) {
        deviceModel = @"(iPhone XR)";
    } else {
        deviceModel = @"";
    }
    
    return [NSString stringWithFormat:@"%@ %@", deviceType, deviceModel];
}

+(NSString *)getSOVersion {
    NSString * osVersion = [[UIDevice currentDevice] systemVersion];
    return osVersion;
}


-(void)showPopup:(UIView *)popup
{
    popupCount++;
    NSLog(@"showPopup %@", popup);
    popup.alpha = 0;
    [containerView addSubview:popup];
    [popups addObject:popup];
    // Hacemos la animación...
    [UIView beginAnimations:@"popupAlpha" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    popup.alpha = 1;
    [UIView commitAnimations];
    
}

-(void)closePopup:(UIView *)popup
{
    NSLog(@"closePopup %@", popup);
    [popups removeObject:popup];
    [popup removeFromSuperview];
    popupCount--;
}

-(BOOL)popupShown
{
    if (popupCount > 0)
        return YES;
    else
        return FALSE;
}

-(void)closeAllPopups
{
    NSLog(@"closeAllPopups");
    for (Popup * popup in popups) {
        [popup removeFromSuperview];
    }
    [popups removeAllObjects];
    popupCount = 0;
}

-(void)MessageBox:(NSString *)message;
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app_name_dialogs", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"btn_aceptar", nil) style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

-(void)MessageBox:(NSString *)message onCommand:(Popup_onCommand)onCommand
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app_name_dialogs", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"btn_aceptar", nil) style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              onCommand(nil, POPUP_CMD_OK, nil);
                                                          }];
    
    [alert addAction:defaultAction];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

-(void)QueryMessage:(NSString *)message withYes:(NSString *)yes andNo:(NSString *)no onCommand:(Popup_onCommand)onCommand
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app_name_dialogs", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:yes style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              onCommand(nil, POPUP_CMD_YES, nil);
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:no style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              onCommand(nil, POPUP_CMD_NO, nil);
                                                          }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self.viewController presentViewController:alert animated:YES completion:nil];

}

-(void)Prompt:(NSString *)message defaultText:(NSString *)defaultText withYes:(NSString *)yes andNo:(NSString *)no onCommand:(Popup_onCommand)onCommand
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app_name_dialogs", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"";
         textField.text = defaultText;
     }];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:yes style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         UITextField * tf = alert.textFields[0];
                                                         onCommand(nil, POPUP_CMD_YES, tf.text);
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:no style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             onCommand(nil, POPUP_CMD_NO, nil);
                                                         }];

    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self.viewController presentViewController:alert animated:YES completion:nil];
    
}

-(void)Prompt:(NSString *)message defaultText:(NSString *)defaultText withYes:(NSString *)yes andNo:(NSString *)no andExtraButton:(NSString *)extra onCommand:(Popup_onCommand)onCommand
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app_name_dialogs", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"";
         textField.text = defaultText;
     }];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:yes style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         UITextField * tf = alert.textFields[0];
                                                         onCommand(nil, POPUP_CMD_YES, tf.text);
                                                     }];
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:extra style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             onCommand(nil, POPUP_CMD_OTHER, nil);
                                                         }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:no style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             onCommand(nil, POPUP_CMD_NO, nil);
                                                         }];

    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [alert addAction:deleteAction];
    [self.viewController presentViewController:alert animated:YES completion:nil];
    
}


-(void)Menu:(NSString *)message withOptions:(NSArray *)options onCommand:(Popup_onCommand)onCommand
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app_name_dialogs", nil) message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"btn_cancelar", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             onCommand(nil, POPUP_CMD_NO, nil);
                                                         }];
    for (int i=0;i<options.count;i++) {
        NSString * option = options[i];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:option style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             onCommand(nil, i+100, nil);
                                                         }];
        [alert addAction:okAction];
    }
    [alert addAction:cancelAction];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}


-(void) showNotification:(NSString *)message {
    if (message) {
        [self showNotification:message withTitle:@"Nestor"];
    }
}

-(void) showNotification:(NSString *)message withTitle:(NSString *)title {
    if (message) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        style.shadowColor = [UIColor blackColor];
        style.shadowOffset = CGSizeMake(2,2);
        style.shadowOpacity = 0.6;
        style.shadowRadius = 5;
        style.shadowRadius = 5;
        style.displayShadow = YES;
        style.messageColor = [UIColor blackColor];
        style.messageFont = [UIFont fontWithName:@"ArialRoundedMTBold" size:13];
        style.titleColor = [UIColor blackColor];
        style.titleFont = [UIFont fontWithName:@"ArialRoundedMTBold" size:15];
        // Miramos la posición
        CGPoint pos = CGPointMake(UIScreen.mainScreen.bounds.size.width/2, 80);
        if (title == nil) {
            [containerView makeToast:message duration:3 position:[NSValue valueWithCGPoint:pos] style:style];
        } else {
            [containerView makeToast:message duration:3 position:[NSValue valueWithCGPoint:pos] title:title image:nil style:style completion:^(BOOL didTap) {
                if (didTap) {
                }
            }];
        }
    }
}

-(BOOL)stdError:(int)code {
    if (code == WS_ERROR_NONETWORKAVAIABLE) {
        [theApp MessageBox:NSLocalizedString(@"server_error_networknotavailable", nil)];
        return YES;
    } else {
        [theApp MessageBox:NSLocalizedString(@"server_error_generico", nil)];
        return YES;
    }
    return NO;
}

-(BOOL) isNetworkAvailable
{
    // Comprobamos si tenemos acceso a Internet
    Reachability * reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus st = [reach currentReachabilityStatus];
    if (st == NotReachable)
        return NO;
    else
        return YES;
}

-(BOOL) hasNotch {
    UIWindow * mainWindow = UIApplication.sharedApplication.keyWindow;
    if ([mainWindow respondsToSelector:@selector(safeAreaInsets)]) {
        NSLog(@"SAFE AREAS: %f %f", mainWindow.safeAreaInsets.top, mainWindow.safeAreaInsets.bottom);
        return (mainWindow.safeAreaInsets.bottom > 0)?YES:NO;
    }
    return NO;
}

// API
//-----------------------------------------------------
// LOGIN, LOGOUT Y REDES SOCIALES
//-----------------------------------------------------

-(void) logout {
    // Hacemos el logout de plataformas sociales
    /* POR AHORA NO LO PONEMOS
    switch (AppSession_instance.userInfo.loggedIn) {
        case LOGGED_FACEBOOK: {
            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
            [login logOut];   //ESSENTIAL LINE OF CODE
            break;
        }
        case LOGGED_TWITTER: {
            //[[[Twitter sharedInstance] sessionStore] logOutUserID:AppSession_instance.userInfo.socialId];
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"];
            NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
            for (NSHTTPCookie *cookie in cookies)
            {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
            break;
        }
        case LOGGED_GOOGLE: {
            break;
        }
        case LOGGED_LINKEDIN: {
            // NO IMPLEMENTADO
            break;
        }
    }
    */
    // Hacemos el logout
    [AppSession_instance loggedOut];
    // Lo notificamos al servidor
    /*
    [Server logOut:_pushDeviceToken onSuccess:^(ServerObject *response) {
        _gcmDeviceLinked = false;
        [_pages jumpToPage:@"PORTADA" withContext:nil];
    } onError:^(NSArray *errors) {
        _gcmDeviceLinked = false;
        [_pages jumpToPage:@"PORTADA" withContext:nil];
    }];
     */
    _gcmDeviceLinked = false;
    [_pages jumpToPage:@"PORTADA" withContext:nil];

     
}


//-----------------------------------------------------
// SHARE
//-----------------------------------------------------
typedef NSString * (^ShareGetPlatform)(void);
typedef void (^ShareOnShare)(NSString * ident, NSString * type, NSString * label, NSString * publicURL);

-(void) share:(NSString *)ident type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL getPlatform:(ShareGetPlatform) getPlatform onShare:(ShareOnShare)onShare {

    onShare(ident, type, label, publicURL);
    
}

-(void) shareFacebook:(NSString *)id type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL {
    /*
    [self share:id type:type label:label publicURL:publicURL getPlatform:^NSString *{
        return @"facebook";
    } onShare:^(NSString *ident, NSString *type, NSString *label, NSString *publicURL) {
        // Código de share de la plataforma
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:publicURL];
        [FBSDKShareDialog showFromViewController:theApp.viewController withContent:content delegate:nil];
    }];
     */
}
-(void) shareTwitter:(NSString *)id type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL {
    /*
    [self share:id type:type label:label publicURL:publicURL getPlatform:^NSString *{
        return @"twitter";
    } onShare:^(NSString *ident, NSString *type, NSString *label, NSString *publicURL) {
        // Código de share de la plataforma
        if (label.length > 110) {
            label = [NSString stringWithFormat:@"%@...",[label substringToIndex:110]];
        }
        TWTRComposer *composer = [[TWTRComposer alloc] init];
        [composer setText:label];
        [composer setURL:[NSURL URLWithString:publicURL]];
        
        // Called from a UIViewController
        [composer showFromViewController:theApp.viewController completion:^(TWTRComposerResult result) {
            if (result == TWTRComposerResultCancelled) {
                NSLog(@"Tweet composition cancelled");
            }
            else {
                NSLog(@"Sending Tweet!");
            }
        }];
    }];
     */
    
}
-(void) shareGoogle:(NSString *)id type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL {
    /*
    [self share:id type:type label:label publicURL:publicURL getPlatform:^NSString *{
        return @"google_plus";
    } onShare:^(NSString *ident, NSString *type, NSString *label, NSString *publicURL) {
        // Construct the Google+ share URL
        NSURLComponents* urlComponents = [[NSURLComponents alloc]
                                          initWithString:@"https://plus.google.com/share"];
        urlComponents.queryItems = @[[[NSURLQueryItem alloc] initWithName:@"url" value:publicURL]];
        NSURL* url = [urlComponents URL];
        // Open the URL in the device's browser
        [[UIApplication sharedApplication] openURL:url];
    }];
     */
    
}

-(void) shareMail:(NSString *)id type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL {
    
    [self share:id type:type label:label publicURL:publicURL getPlatform:^NSString *{
        return @"email";
    } onShare:^(NSString *ident, NSString *type, NSString *label, NSString *publicURL) {
        // Código de share de la plataforma
        if([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
            mailCont.mailComposeDelegate = theApp;        // Required to invoke mailComposeController when send
            NSString * body = [NSString stringWithFormat:@"<html>"
                               "<head>"
                               "<meta name='viewport' />"
                               "</head>"
                               "<body >"
                               "%@" // label
                               "<br/>"
                               "<a href='%@'>%@</a>" // publicURL (2 veces)
                               "</body>"
                               "</html>", label, publicURL, publicURL];
            
            [mailCont setSubject:NSLocalizedString(@"app_email_subject", nil)];
            //[mailCont setToRecipients:[NSArray arrayWithObject:@"myFriends@email.com"]];
            [mailCont setMessageBody:body isHTML:YES];
            
            [theApp.viewController presentViewController:mailCont animated:YES completion:nil];
        }
    }];
    
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}
-(void) shareURL:(NSString *)id type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL {
    
    [self share:id type:type label:label publicURL:publicURL getPlatform:^NSString *{
        return nil; // No guardamos registro para share
    } onShare:^(NSString *ident, NSString *type, NSString *label, NSString *publicURL) {
        // Código de share de la plataforma
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = publicURL;
        [theApp MessageBox:NSLocalizedString(@"app_share_sharedurl_message", nil)];
    }];
    
}
-(void) shareAll:(NSString *)id type:(NSString *)type label:(NSString *)label publicURL:(NSString*) publicURL {
    /*
    CustomIOSAlertView * popup = [[CustomIOSAlertView alloc] init];
    PopupShareView * share = [[PopupShareView alloc] initWithPopup:popup onShare:^(CustomIOSAlertView *popup, int SocialType) {
        switch (SocialType) {
            case SOCIAL_FACEBOOK:
                [self shareFacebook:id type:type label:label publicURL:publicURL];
                break;
            case SOCIAL_TWITTER:
                [self shareTwitter:id type:type label:label publicURL:publicURL];
                break;
            case SOCIAL_GOOGLE:
                [self shareGoogle:id type:type label:label publicURL:publicURL];
                break;
            case SOCIAL_EMAIL:
                [self shareMail:id type:type label:label publicURL:publicURL];
                break;
            case SOCIAL_URL:
                [self shareURL:id type:type label:label publicURL:publicURL];
                break;
        }
    }];
    CGRect shareFrame = share.frame;
    [popup setContainerView:share];
    [popup setButtonTitles:@[NSLocalizedString(@"btn_cancelar", nil)]];
    [popup show];
     */
    
}

//-----------------------------------------------------
// SONIDOS
//-----------------------------------------------------
-(void) playAudio:(NSString *)audio {
    if (!soundsEnabled)
        return;
    
    /* Use this code to play an audio file */
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:audio  ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    player.numberOfLoops = 0; // Once
    [player play];
}

//-----------------------------------------------------
// NAVEGACION GLOBAL
//-----------------------------------------------------
-(void) jumpToStart:(BOOL)completeProfile {
    
    NSLog(@"JUMP TO START");
    
    NSString * destPage;
    PageContext * ctx = [[PageContext alloc] init];
    if (self.appSession && [self.appSession isLoggedIn]) {
        if (completeProfile) {
            [ctx addParam:@"mode" withIntValue:FREEMIUM_MODE_REGISTERBASICDATA];
            destPage = @"REGISTERFREEMIUM";
        } else {
            destPage = @"HOME";
        }
    } else {
        destPage = @"LOGIN";
    }
    
    [_pages jumpToPage:destPage withContext:ctx];
    /* Tema tour
    NSString * tourDone = [AppSession_instance getParam:@"tour_done"];
    if (tourDone == nil || ![tourDone isEqualToString:@"yes"]) {
        PageContext * context = [[PageContext alloc] init];
        [context addParam:@"DESTPAGE" withValue:destPage];
        [_pages jumpToPage:@"TOUR" withContext:context];
    } else {
        [_pages jumpToPage:destPage withContext:nil];
    }*/
}

-(void) jumpToPrivacy {
    PageContext * ctx = [[PageContext alloc] init];
    [ctx addParam:@"title" withValue:@"Política de privacidad"];
    [ctx addParam:@"htmlpage" withValue:@"legal_terms"];
    
    [theApp.pages jumpToPage:@"WEBVIEW" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
}

-(void) jumpToTerms {
    PageContext * ctx = [[PageContext alloc] init];
    [ctx addParam:@"title" withValue:@"Condiciones de uso"];
    [ctx addParam:@"htmlpage" withValue:@"legal_terms"];
    
    [theApp.pages jumpToPage:@"WEBVIEW" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
}

-(void) jumpToFAQs {
    PageContext * ctx = [[PageContext alloc] init];
    [ctx addParam:@"title" withValue:@"FAQs"];
    [ctx addParam:@"htmlpage" withValue:@"faqs"];
    
    [theApp.pages jumpToPage:@"WEBVIEW" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
}

-(void) jumpToInvite {
    [theApp MessageBox:@"Próximamente..."];
}

-(NSDictionary *)findService:(int)serviceId {
    for (int i=0;i<self.services.count;i++) {
        int curId = [((NSNumber *)self.services[i][@"id"]) intValue];
        if (curId == serviceId) {
            return theApp.services[i];
        }
    }
    return nil;
}

-(NSString *)normalizeSearchText:(NSString *)text {
    text = [[NSString alloc]
                  initWithData:
                  [text dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                  encoding:NSASCIIStringEncoding];
    text = [text uppercaseString];
    return text;
}

-(NSString *)findCatName:(int)catId {
    for (NSString *  name in self.categories) {
        NSNumber * srcId = self.categories[name][@"id"];
        if ([srcId intValue] == catId) {
            return name;
        }
    }
    return @"";
}

-(NSString *)findCatNameForService:(NSDictionary *)service {
    // Cogemos la primera
    NSArray * cats = service[@"categories"];
    if (!cats || ((NSObject *)cats == NSNull.null) || cats.count == 0) {
        return @"";
    }
    int catId = [((NSNumber *)cats[0]) intValue];
    return [self findCatName:catId];
}

-(NSString *)safeString:(NSDictionary *)object withName:(NSString *)name {
    if (object && object[name] && object[name] != NSNull.null) {
        return object[name];
    }
    return @"";
}

-(NSArray *)filteredServices:(NSArray *)allItems withText:(NSString *)text {
    if (text == nil || text.length < 3) {
        return allItems;
    }
    NSString * searchText = [self normalizeSearchText:text];
    NSMutableArray * res = [[NSMutableArray alloc] init];
    for (int i=0;i<allItems.count;i++) {
        NSDictionary * service = allItems[i];
        NSString * name = [self safeString:service withName:@"name"];
        NSString * description = [self safeString:service withName:@"description"];
        NSString * tags = [self safeString:service withName:@"tags"];
        NSString * search = [NSString stringWithFormat:@"%@ %@ %@", name, description, tags];
        search = [self normalizeSearchText:search];
        if ([search containsString:searchText]) {
            [res addObject:service];
        }
    }
    return res;
}


-(void)updateUserProfile:(BOOL)closePopups {
    [theApp showBlockView];
    [WSDataManager getProfile:^(int code, NSDictionary *result, NSDictionary * badges) {
        [theApp hideBlockView];
        // Eliminamos todos los popups
        if (closePopups)
            [theApp closeAllPopups];
    }];
}

-(void) updateBadge:(int) numBadges {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numBadges];
}


//-----------------------------------------------------
// PAYTPV
//-----------------------------------------------------
-(void) addPTPVCard:(NSString *)cardNumber expirityDate:(NSString *)expirityDate cvv:(NSString *)cvv {
    /*
    PTPVCard *card = [[PTPVCard alloc] initWithPan:cardNumber
                                        expiryDate:expirityDate
                                               cvv:cvv];
    NSLog(@"CARD: %@", card);
    [[PTPVAPIClient sharedClient] addUser:card completion:^(PTPVUser * _Nullable user, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"CARD ERROR: %@", error);
        }
        
        if (user != nil) {
            NSLog(@"CARD USER: %@", user);
        }
    }];
    */
}

-(NSArray *) getPTPVCards {
    return [[NSMutableArray alloc] init];
}

/* EXEMPLE https://github.com/PayTpv/IOS-SDK
 // get the user's card details
 PTPVCard *card = [[PTPVCard alloc] initWithPan:@"4111111111111111"
 expiryDate:@"0518"
 cvv:@"123"];
 
 // add the card
 [[PTPVAPIClient sharedClient] addUser:card completion:^(PTPVUser * _Nullable user, NSError * _Nullable error) {
    if (error != nil) {
        // handle error
        return;
    }
 
    // define payment details
    PTPVPurchaseRequest *purchaseRequest;
    purchaseRequest = [[PTPVPurchaseRequest alloc] initWithAmount:@"199"
        order:@"ios_1234"
        currency:PTPVCurrencyEUR
        productDescription:nil
        owner:nil
        scoring:nil];
 
    // make the payment
    [[PTPVAPIClient sharedClient] executePurchase:purchaseRequest forUser:user completion:^(PTPVPurchase * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            // handle error
            return;
        }
        // handle successful payment
    }];
 }];
 */

//-----------------------------------------------------
// TRACKING
//-----------------------------------------------------
-(void) sendTrackingEvent:(NSString *)event withParams:(NSDictionary *)params {
    if (TRACKING_ENABLED) {
        [FIRAnalytics logEventWithName:event parameters:params];
    }
}

@end
