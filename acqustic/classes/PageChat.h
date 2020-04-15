//
//  PageChat.h
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "HeaderNav.h"
#import "HeaderEdit.h"
#import "SimpleEdit.h"


@interface PageChat : PageBase <UITextViewDelegate> {
    int chatId;
    NSMutableArray * lines;
    NSMutableArray * ballons;
    NSDictionary * stateFormData;
    PageContext * _ctx;
    NSString * lastBudget; // Si lo hay
    NSTimer * refresher;
    BOOL freeTextForm;
    BOOL refreshing;
    // Teclado de software
    int midViewOriginalHeight;
    int midViewKeyboardOnHeight;
    int svChatOriginalHeight;
}

@property int chatId;
@property (strong, nonatomic) IBOutlet HeaderNav *vHeader;
@property (strong, nonatomic) IBOutlet HeaderEdit *vHeaderEdit;
@property (strong, nonatomic) IBOutlet UIScrollView *svChat;
@property (strong, nonatomic) IBOutlet UIView *vTools;
@property (strong, nonatomic) IBOutlet UIView *vEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnAddImage;
@property (strong, nonatomic) IBOutlet UITextView *tvEdit;
@property (strong, nonatomic) IBOutlet UIImageView *ivSend;
@property (strong, nonatomic) IBOutlet UIButton *btnSend;
@property (strong, nonatomic) IBOutlet UILabel *lblOutofschedule;

-(IBAction) onBtnSendClick:(UIButton *)sender;


-(void) pushReceived:(NSDictionary *)userInfo;
-(void) refresh;

@end
