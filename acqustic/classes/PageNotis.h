//
//  PageNotis.h
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "HeaderNav.h"
#import "NotiTab.h"

@interface PageNotis : PageBase {
    PageContext *_ctx;
    int activeTab;
    NSMutableArray * notis;
    NSMutableArray * inprogress;
    NSMutableArray * won;
    NSMutableArray * history;
}

@property (strong, nonatomic) IBOutlet HeaderNav *vHeader;
@property (strong, nonatomic) IBOutlet UIScrollView *svContent;
@property (strong, nonatomic) IBOutlet NotiTab *tabNotifications;
@property (strong, nonatomic) IBOutlet NotiTab *tabInprogress;
@property (strong, nonatomic) IBOutlet NotiTab *tabWon;


-(void) refresh;

@end
