//
//  PageHistoryItem.m
//  ViewTransitions
//
//  Created by Javier Garcés González on 07/07/11.
//  Copyright 2011 Sinergia sistemas informáticos S.L. All rights reserved.
//

#import "PageHistoryItem.h"
#import "PageTransition.h"


@implementation PageHistoryItemCacheInfo
@synthesize view;
@synthesize page;
@synthesize timestamp;
@end



@implementation PageHistoryItem

@synthesize pageName;
@synthesize pageContext;
@synthesize pageTransition;
@synthesize cache;

-(void)cleanUpCache
{
    cache.view = nil;
    cache = nil;
}

-(void)mutateTo:(NSString *)pageName context:(PageContext * )context {
    self.pageName = pageName;
    self.pageContext = context;
    [self cleanUpCache];
}


@end
