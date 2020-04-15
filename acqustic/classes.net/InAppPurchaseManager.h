//
//  InAppPurchaseManager.h
//  PDL
//
//  Created by Javier Garcés González on 24/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
/*
#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
*/
@class InAppPurchaseManager;

@protocol InAppPurchaseManagerListener <NSObject>

- (void)InAppPurchaseManager:(id)manager onProductsDownloaded:(NSArray *)products invalid:(NSArray *)invalid;
- (void)InAppPurchaseManager:(id)manager onProductPurchased:(SKPaymentTransaction *)transaction;
- (void)InAppPurchaseManager:(id)manager onProductRestored:(SKPaymentTransaction *)transaction;
- (void)InAppPurchaseManager:(id)manager onProductFailed:(SKPaymentTransaction *)transaction;

// NOTA: Los dos últimos métodos han de llamar a finishTransaction cuando ya hayan acabado el procedimiento
// Si no se llama, es que no se ha cerrado la transacción, y queda para "más tarde"

@end


@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
    
    id<InAppPurchaseManagerListener> _listener;
}

// public methods
- (void)loadStore:(id<InAppPurchaseManagerListener>)listener products:(NSSet *)products;
-(void)closeStore;
- (BOOL)canMakePurchases;
- (void)purchaseProduct:(SKProduct *)product;
- (void)finishTransaction:(SKPaymentTransaction *)transaction;

@end
