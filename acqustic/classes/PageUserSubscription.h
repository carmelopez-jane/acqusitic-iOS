//
//  PageUserSubscription.h
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "HeaderEdit.h"
#import "Performance.h"

#import <StoreKit/StoreKit.h>

@interface PageUserSubscription : PageBase <SKProductsRequestDelegate, SKPaymentTransactionObserver, UITextViewDelegate> {
    PageContext *_ctx;
    
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;

}

@property (strong, nonatomic) IBOutlet HeaderEdit * vHeaderEdit;
@property (strong, nonatomic) IBOutlet UIScrollView *svContent;
@property (strong, nonatomic) IBOutlet UILabel * lblTitle;
@property (strong, nonatomic) IBOutlet UILabel * lblSubtitle;
@property (strong, nonatomic) IBOutlet UIView * vProduct;
@property (strong, nonatomic) IBOutlet UILabel * lblProductTitle;
@property (strong, nonatomic) IBOutlet UILabel * lblProductPrice;
@property (strong, nonatomic) IBOutlet UILabel * lblProductSubtitle;
@property (strong, nonatomic) IBOutlet UILabel * lblProductDescription;
@property (strong, nonatomic) IBOutlet UIButton * btnSubscribe;
@property (strong, nonatomic) IBOutlet UILabel * lblSubscribed;
@property (strong, nonatomic) IBOutlet UITextView * tvConditions;
@property (strong, nonatomic) IBOutlet UILabel * lblManage;


@end
