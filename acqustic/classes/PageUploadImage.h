//
//  PageUploadImage.h
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

extern void (^PageUploadImageChanged)(NSString * item);

@interface PageUploadImage : PageBase <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    PageContext *_ctx;
    
    NSString * imageSrc;
    
    int itemsYpos;
    NSMutableArray * itemsList;
    FormItemSep * footerSep;
    FormItemSubnote * footerSubnote;
    
    NSInteger groupId;
    
}

@property (strong, nonatomic) IBOutlet HeaderNav *vHeader;
@property (strong, nonatomic) IBOutlet HeaderEdit *vHeaderEdit;
@property (strong, nonatomic) IBOutlet UIScrollView *svContent;
@property (strong, nonatomic) IBOutlet UIView *vImageHolder;
@property (strong, nonatomic) IBOutlet UIImageView *ivImage;
@property (strong, nonatomic) IBOutlet UIView *vDelete;
@property (strong, nonatomic) IBOutlet UIImageView *ivDelete;
@property (strong, nonatomic) IBOutlet UIImageView *ivMessage;
@property (strong, nonatomic) IBOutlet UILabel *lblImage;



@end
