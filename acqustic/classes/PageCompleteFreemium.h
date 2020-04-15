//
//  PageCompleteFreemium.h
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "HeaderNav.h"
#import "HeaderEdit.h"
#import "FormBuilder.h"
#import "FormItemHeader.h"
#import "FormItemSep.h"
#import "FormItemDelete.h"
#import "Performer.h"
#import "Group.h"

#define FREEMIUM_MODE_REGISTERBASICDATA                    1
#define FREEMIUM_MODE_REGISTERFORPERFORMANCE          2

@interface PageCompleteFreemium : PageBase {
    PageContext *_ctx;
    Performer * performer;
    NSMutableArray * groups;
    FormBuilder * perfFM;
    NSMutableArray * groupFMs;
    /*
    NSInteger groupId;
    Group * group;
    FormBuilder * fm0, * fm1, * fm2;
    */
}

@property (strong, nonatomic) IBOutlet HeaderNav *vHeader;
@property (strong, nonatomic) IBOutlet HeaderEdit *vHeaderEdit;
@property (strong, nonatomic) IBOutlet UIScrollView *svContent;
@property (strong, nonatomic) IBOutlet FormItemDelete *vDelete;


@end
