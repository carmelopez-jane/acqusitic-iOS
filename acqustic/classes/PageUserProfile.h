//
//  PageUserProfile.h
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
#import "performer.h"

@interface PageUserProfile : PageBase {
    PageContext *_ctx;
    Performer * performer;
    
    FormBuilder * fm1;
}

@property (strong, nonatomic) IBOutlet HeaderNav *vHeader;
@property (strong, nonatomic) IBOutlet HeaderEdit *vHeaderEdit;
@property (strong, nonatomic) IBOutlet UIScrollView *svContent;


@end
