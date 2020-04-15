//
//  Concierge
//  Configuración general
//
//  Created by Javier Garcés González.
//  Copyright (c) 2017 Sinergia sistemas informáticos
//

// CONFIGURACION DE ENTRIX

//--------------------------------------------------------------------------
// Config general
#define DEBUG_MODE                      NO
#define BETA_MODE                       YES
#define CURRENT_APP_VERSION             1000
#define TRACKING_ENABLED                NO

//--------------------------------------------------------------------------
// Configuración local
#define LOCALCONFIG_DBFILE              @"localconfig.sq3";
#define UPK_PHONE                       @"phone"
#define UPK_DEVICETOKEN                 @"deviceToken"
#define UPK_PHONEINFO                   @"phoneInfo"
#define UPK_LASTUPDATED                 @"lastUpdated"

//--------------------------------------------------------------------------
// URLS de la APP (Servidor, Documentos, Link)
//#define APP_WS_URL          @"http://acqustic.betadevs.com/api/v1"
#define APP_WS_URL              @"https://app.acqustic.com/api/v1"

//--------------------------------------------------------------------------
// RAPIDAPI DEEZER
#define RAPIDAPI_DEEZER_HOST    @"deezerdevs-deezer.p.rapidapi.com"
#define RAPIDAPI_KEY            @"028972d653msha0e99fc5d3be269p115f93jsn52a21cf28a65"

//--------------------------------------------------------------------------
// ITUNES APP ID
#define ITUNES_APP_ID       1136152055

//--------------------------------------------------------------------------
// IN APP SUBSCRIPTIONS
#define ACQUSTIC_SUBSCRIPTION_PRODUCT       @"acqustic.anual2"


#define ACQUSTIC_GREEN     [Utils uicolorFromARGB:0xFF06B8AD]

//--------------------------------------------------------------------------
// Sigleton de la Actividad de la App
// La clase está creada en AppDelegate.m
@class AppDelegate;
extern AppDelegate * theApp;

