//
//  InAppPurchaseManager.m
//  PDL
//
//  Created by Javier Garcés González on 24/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "SKProduct+LocalizedPrice.h"
#import "Acqustic.h"
#import "AppDelegate.h"

@implementation InAppPurchaseManager

- (void)requestProductsData:(NSSet *)products
{
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:products];
    productsRequest.delegate = self;
    [productsRequest start];
    [theApp showBlockView];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [theApp hideBlockView];
    
    NSArray *products = response.products;
    if (_listener != nil) {
        [_listener InAppPurchaseManager:self onProductsDownloaded:products invalid:response.invalidProductIdentifiers];
    }
    
}

#pragma -
#pragma Public methods

//
// call this method once on startup
//
- (void)loadStore:(id<InAppPurchaseManagerListener>)listener products:(NSSet *)products
{
    _listener = listener;
    
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestProductsData:products];
}

-(void)closeStore
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseProduct:(SKProduct *)product
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [theApp showBlockView];
}

#pragma -
#pragma Purchase helpers

/*
//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
*/

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [theApp hideBlockView];
    
    if (_listener != nil)
        [_listener InAppPurchaseManager:self onProductPurchased:transaction];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [theApp hideBlockView];
    
    if (_listener != nil)
        [_listener InAppPurchaseManager:self onProductRestored:transaction];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    [theApp hideBlockView];
    
    if (_listener != nil)
        [_listener InAppPurchaseManager:self onProductFailed:transaction];
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


@end
