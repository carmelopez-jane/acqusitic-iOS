//
//  PageChats.h
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "HeaderNav.h"

@interface PageChats : PageBase {
    PageContext *_ctx;
    NSArray * chats;
}

@property (strong, nonatomic) IBOutlet HeaderNav *vHeader;
@property (strong, nonatomic) IBOutlet UIScrollView *svContent;

-(void) refresh;

@end
