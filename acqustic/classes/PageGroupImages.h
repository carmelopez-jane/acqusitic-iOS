//
//  PageGroupImages.h
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
#import "FormItemSubnote.h"
#import "Album.h"

extern void (^PageGroupImagesChanged)(NSArray * items);

@interface PageGroupImages : PageBase <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    PageContext *_ctx;
    
    NSMutableArray * items;
    
    int itemsYpos;
    NSMutableArray * itemsList;
    FormItemSep * footerSep;
    FormItemSubnote * footerSubnote;
    
    NSInteger groupId;
    
    NSInteger itemIndex;
    
}

@property (strong, nonatomic) IBOutlet HeaderNav *vHeader;
@property (strong, nonatomic) IBOutlet HeaderEdit *vHeaderEdit;
@property (strong, nonatomic) IBOutlet UIScrollView *svContent;
@property (strong, nonatomic) IBOutlet FormItemDelete *vDelete;


@end
