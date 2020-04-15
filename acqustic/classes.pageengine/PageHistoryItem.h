//
//  PageHistoryItem.h
//  ViewTransitions
//
//  Created by Javier Garcés González on 07/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Page.h"
#import "PageContext.h"

@class PageTransition;


@interface PageHistoryItemCacheInfo: NSObject {
    UIView * view;
    Page * page;
    unsigned long timestamp;
}
@property UIView * view;
@property Page * page;
@property unsigned long timestamp;
@end

@interface PageHistoryItem : NSObject {
	NSString * pageName;
	PageContext * pageContext;
	PageTransition * pageTransition;
    PageHistoryItemCacheInfo * cache;
}

@property NSString * pageName;
@property PageContext * pageContext;
@property PageTransition * pageTransition;
@property PageHistoryItemCacheInfo * cache;

-(void)cleanUpCache;
-(void)mutateTo:(NSString *)pageName context:(PageContext * )context;

@end

