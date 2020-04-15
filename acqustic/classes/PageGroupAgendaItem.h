//
//  PageGroupAgendaItem.h
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
#import "AgendaItem.h"

@interface PageGroupAgendaItem : PageBase {
    PageContext *_ctx;
    Agendaitem * agendaitem;
    
    FormBuilder * fm1;
}

@property (strong, nonatomic) IBOutlet HeaderNav *vHeader;
@property (strong, nonatomic) IBOutlet HeaderEdit *vHeaderEdit;
@property (strong, nonatomic) IBOutlet UIScrollView *svContent;
@property (strong, nonatomic) IBOutlet FormItemDelete *vDelete;


@end
