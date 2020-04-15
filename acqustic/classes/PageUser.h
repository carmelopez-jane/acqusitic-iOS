//
//  PageUser.h
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "HeaderNav.h"
#import "FormItemHeader.h"
#import "FormItemSep.h"
#import "FormItemDelete.h"

@interface PageUser : PageBase {
    PageContext *_ctx;
}

@property (strong, nonatomic) IBOutlet HeaderNav *vHeader;
@property (strong, nonatomic) IBOutlet UIScrollView *svContent;
@property (strong, nonatomic) IBOutlet UIImageView *vAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblGroup;
@property (strong, nonatomic) IBOutlet FormItemHeader *hGroups;
@property (strong, nonatomic) IBOutlet FormItemSep *sepGroups;
@property (strong, nonatomic) IBOutlet FormItemDelete *vDelete;
@property (strong, nonatomic) IBOutlet UILabel *lblVersion;


@end
