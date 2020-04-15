//
//  PageUserSubscription.m
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageUserSubscription.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "HeaderEdit.h"
#import "WSDataManager.h"
#import "NSAttributedString+DDHTML.h"

@interface PageUserSubscription ()

@end

@implementation PageUserSubscription

@synthesize vHeaderEdit, svContent, lblTitle, lblSubtitle, vProduct, lblProductTitle, lblProductPrice, lblProductSubtitle, lblProductDescription, btnSubscribe, lblSubscribed, tvConditions, lblManage;

-(BOOL)onPreloadPage:(PageContext *)context {
    PageUserSubscription * refThis = self;
    [theApp showBlockView];
    [WSDataManager getProfile:^(int code, NSDictionary *result, NSDictionary *badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            //[self setBadges:badges];
            theApp.appSession.performerProfile = [[Performer alloc] initWithDictionary:result];
            //[refThis setBadges:badges];
            [refThis endPreloading:YES];
        } else {
            [theApp stdError:code];
            [refThis endPreloading:NO];
        }
    }];
    return YES;
}

-(void)onEnterPage:(PageContext *)context {
    
    [super onEnterPage:context];

    if ([theApp.appSession isSubscribed]) {
        [self loadNIB:@"PageUserSubscription_active"];
        [Utils setOnClick:self.lblManage withBlock:^(UIView *sender) {
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"itms-apps://apps.apple.com/account/subscriptions"]];
        }];
    } else if ([theApp.appSession wasSubscribed]) {
        [self loadNIB:@"PageUserSubscription_reactivation"];
    } else {
        [self loadNIB:@"PageUserSubscription"];
    }

    _ctx = context;
    
    self.vHeaderEdit.btnSave.hidden = YES;
    self.vHeaderEdit.lblTitle.text = @"Suscripción Acqustic";
    
    // Ajustamos el texto de condiciones
    // Texto con links
    NSString * baseText = self.tvConditions.text;
    baseText = [baseText stringByReplacingOccurrencesOfString:@"política de privacidad" withString:@"<a href='http://privacy'>política de privacidad</a> "];
    baseText = [baseText stringByReplacingOccurrencesOfString:@"términos y condiciones" withString:@"<a href='http://terms'>términos de uso</a> "];
    baseText = [NSString stringWithFormat:@"<font color='#000000'>%@</font>", baseText];
    self.tvConditions.delegate = self;
    self.tvConditions.attributedText = [NSAttributedString attributedStringFromHTML:baseText normalFont:self.tvConditions.font boldFont:self.tvConditions.font italicFont:self.tvConditions.font];
    self.tvConditions.linkTextAttributes = @{
        NSForegroundColorAttributeName: ACQUSTIC_GREEN,
    };

    [self.btnSubscribe addTarget:self action:@selector(onSubscribe:) forControlEvents:UIControlEventTouchUpInside];
    [Utils setOnClick:self.lblSubscribed withBlock:^(UIView *sender) {
        [self doRestore];
    }];
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
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


-(void) onSubscribe:(UIButton *)btn {
    [self doPurchase];
}

#pragma mark - Store Kit Methods

//Variables d'estat necesaries per la compra
float  amount;

- (void) doPurchase
{
    if (![WSDataManager isNetworkAvailable]) {
        [theApp stdError:WS_ERROR_NONETWORKAVAIABLE];
        return;
    }

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    if ([SKPaymentQueue canMakePayments])
    {
        [theApp showBlockView];
        [self requestProductWithIdentifier:ACQUSTIC_SUBSCRIPTION_PRODUCT];
    }
    else
    {
        //[self unblockBuyButtons];
        [theApp MessageBox:@"Por favor, habilite las \"Compras integradas\" desde el menú de cofiguración:\nAjustes/General/Restricciones/Contenido Permitido/Permitir: Compras integradas."];
    }
}

- (void) doRestore {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) requestProductWithIdentifier:(NSString*) identifier
{
    NSSet *productIdentifiers = [NSSet setWithObject:identifier ];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [theApp hideBlockView];
    [theApp MessageBox:@"Imposible conectarse con iTunes. Compruebe su conexión a Internet e inténtelo de nuevo."];
    /*
    [self unblockBuyButtons];
    [theApp ErrorBox:NSLocalizedString(@"Imposible conectarse amb itunes. Comprobi la seva connexió a Internet e intenti-ho de nou.", @"")];
    MineLog(@"La compra a fallat");
    */
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [theApp hideBlockView];
    NSArray *products = response.products;
    for (int i=0;i<products.count;i++) {
        SKProduct* product = products[i];
        if ([product.productIdentifier isEqualToString:ACQUSTIC_SUBSCRIPTION_PRODUCT]) {
            NSLog(@"Product title: %@" , product.localizedTitle);
            NSLog(@"Product description: %@" , product.localizedDescription);
            NSLog(@"Product price: %@" , product.price);
            NSLog(@"Product id: %@" , product.productIdentifier);
            
            [theApp showBlockView];
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            return;
        }
    }
    [theApp MessageBox:@"Hi ha hagut un problema en connectar amb l'App Store"];
    for (NSString *invalidProductId in response.invalidProductIdentifiers) {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
}


- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    [theApp hideBlockView];
    NSLog(@"Purchase removedTransactions");
    // Release the transaction observer since transaction is finished/removed.
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

NSString* transactionIdentifierAux;

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased: {
                [theApp hideBlockView];
                //MIRAR SI EL TRANSACTION OBJECT RETORNA EL IDENTIFICADOR
                
                // aquest if es degut a que per cada sessió la defaultqueue no es buida i controlem manualment si ja el tenim
                
                // Obtenim el receipt actual de l'usuari, amb totes les seves
                // subscripcions
                NSString * receipt = @"";
                NSData * receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
                if (receiptData != nil) {
                    receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
                }
                //NSLog(@"PURCHASE RECEIPT: [[%@]]", receiptData);
                //NSLog(@"PURCHASE RECEIPT BASE64: [[%@]]", receipt);
                
                // Aquí hablamos con el servidor
                [WSDataManager subscribe:ACQUSTIC_SUBSCRIPTION_PRODUCT receipt:receipt withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                    if (code == WS_SUCCESS) {
                        // Si todo va bien....
                        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                        theApp.appSession.performerProfile = [[Performer alloc] initWithDictionary:result];
                        [theApp.pages goBack];
                    } else {
                        // Error en la subscripción
                        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                        [theApp.pages goBack];
                    }
                }];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                [theApp hideBlockView];
                //MineLog(@"La compra ha fallat");
                //[self unblockBuyButtons];
                if (transaction.error) {
                    NSLog(@"ERROR IAP: %@", transaction.error);
                }
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                [theApp hideBlockView];
                
                NSString * receipt = nil;
                NSData * receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
                if (receiptData != nil) {
                    receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
                }
                //NSLog(@"PURCHASE RECEIPT: [[%@]]", receiptData);
                //NSLog(@"PURCHASE RECEIPT BASE64: [[%@]]", receipt);
                if (receipt != nil) {
                    // Aquí hablamos con el servidor
                    [WSDataManager subscribe:ACQUSTIC_SUBSCRIPTION_PRODUCT receipt:receipt withBlock:^(int code, NSDictionary *result, NSDictionary *badges) {
                        if (code == WS_SUCCESS) {
                            // Si todo va bien....
                            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                            [theApp.pages goBack];
                        } else {
                            // Error en la subscripción
                            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                            [theApp.pages goBack];
                        }
                    }];
                }
                //MineLog(@"La compra era una restauració ");
                break;
            }
            case SKPaymentTransactionStatePurchasing: {
                //MineLog(@"Comprant");
                break;
            }
            default: {
                //[self unblockBuyButtons];
                //MineLog(@"Unknown error Buying");
                break;
            }
        }

    }
}


@end
