//
//  PageChat.m
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageChat.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "ChatBallon.h"
#import "ChatBallonTF.h"
#import "WSDataManager.h"
#import "NSDate+Utilities.h"

@interface PageChat ()

@end

@implementation PageChat

@synthesize chatId = chatId;
@synthesize vHeader, vHeaderEdit, svChat, vTools, vEdit, btnAddImage, tvEdit, ivSend, btnSend, lblOutofschedule;


-(BOOL) onPreloadPage:(PageContext *)context {
    PageChat * refThis = self;
    
    _ctx = context;
    chatId = (int)[context intParamByName:@"chatId"];
    [theApp showBlockView];
    [WSDataManager getChat:chatId withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [self setBadges:badges];
            refThis->lines = [[NSMutableArray alloc] init];
            NSArray * res = (NSArray *)result;
            for (int i=0;i<res.count;i++) {
                [refThis->lines addObject:res[i]];
            }
            NSLog(@"DATA: %@", refThis->lines);
            //int badges = [((NSNumber *)refThis->task[@"allpending"]) intValue];
            //[theApp updateBadge:badges];
            [refThis endPreloading:YES];
        } else {
            [theApp stdError:code];
            [refThis endPreloading:NO];
        }
    }];
    return YES;
}

-(void)onEnterPage:(PageContext *)context{
    PageChat * refThis = self;

    [super onEnterPage:context];
    [self.vHeader setActiveSection:HEADER_SECTION_CHATS];
    [self setupBadges:vHeader];
    
    [self loadNIB:@"PageChat"];
    
    self.vHeaderEdit.lblTitle.text = @"Chats";
    self.vHeaderEdit.btnSave.hidden = YES;

    self.tvEdit.delegate = self;
    self.tvEdit.textContainerInset = UIEdgeInsetsMake(8,5,8,5);
    
    self.lblOutofschedule.text = theApp.appConfig.chat_outofschedule_message_es;
    self.lblOutofschedule.hidden = NO;

    // Quitamos la toolbar de la caja de edición
    self.tvEdit.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tvEdit.inputAccessoryView = [[UIView alloc] init];
    UITextInputAssistantItem* shortcut = [self.tvEdit inputAssistantItem];
    shortcut.leadingBarButtonGroups = @[];
    shortcut.trailingBarButtonGroups = @[];

    [self fillInChat];
    [self goToEnd:NO];

    [self textViewDidChange:self.tvEdit];

    [self.btnAddImage addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
    
    [self startRefreshTimer];
    
    // Tracking
    /*
    [theApp sendTrackingViewChatEvent:[NSString stringWithFormat:@"%@ - %@", task[@"serviceId"], task[@"service"]] withCat:task[@"cat"]];
    */
    
    midViewOriginalHeight = self->midView.frame.size.height;
    svChatOriginalHeight = self->svChat.frame.size.height;
    [self registerForKeyboardNotifications];
    
    [Utils setOnClick:self.svChat withBlock:^(UIView *sender) {
        if ([self.tvEdit isFirstResponder]) {
            [self.tvEdit resignFirstResponder];
        }
    }];
    
    // Barra de control... en función del estado
    [self setupTool];

}

-(PageContext *)onLeavePage:(NSString *)destPage {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (refresher.isValid)
        [refresher invalidate];
    return [_ctx clone];
}


// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    CGSize keyboardSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect fr = self->midView.frame;
    NSLog(@"MIDVIEW FRAME ORIG: %f, %f, %f, %f", fr.origin.x, fr.origin.y, fr.size.width, fr.size.height);
    if (midViewKeyboardOnHeight == 0) { // Hacemos el cálculo la primera vez
        int kbToolbarHeight = -40/*40*/; // La barra que añade
        midViewKeyboardOnHeight = midViewOriginalHeight-keyboardSize.height-kbToolbarHeight;
    }
    fr.size.height = midViewKeyboardOnHeight;
    self->midView.frame = fr;
    NSLog(@"MIDVIEW FRAME FINAL: %f, %f, %f, %f", fr.origin.x, fr.origin.y, fr.size.width, fr.size.height);
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    // NO HACEMOS NADA AQUI. SE HACE EN WILLSHOW
    return;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGSize keyboardSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    /*
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight ) {
        CGSize origKeySize = keyboardSize;
        keyboardSize.height = origKeySize.width;
        keyboardSize.width = origKeySize.height;
    }
    */
    /*
    int height = keyboardSize.height;
    height -= self.vEdit.frame.size.height;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(height, 0, 0, 0);
    svChat.contentInset = contentInsets;
    svChat.scrollIndicatorInsets = contentInsets;
     */
    CGRect fr = self->midView.frame;
    NSLog(@"MIDVIEW FRAME ORIG: %f, %f, %f, %f", fr.origin.x, fr.origin.y, fr.size.width, fr.size.height);
    int kbToolbarHeight = 40;
    fr.size.height = 369;// midViewOriginalHeight-keyboardSize.height-kbToolbarHeight;
    self->midView.frame = fr;
    NSLog(@"MIDVIEW FRAME FINAL: %f, %f, %f, %f", fr.origin.x, fr.origin.y, fr.size.width, fr.size.height);
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    /*
    CGRect rect = svChat.frame;
    rect.size.height -= keyboardSize.height;
    NSLog(@"Rect Size Height: %f", rect.size.height);
    if (!CGRectContainsPoint(rect, activeField.frame.origin)) {
        CGPoint point = CGPointMake(0, activeField.frame.origin.y - keyboardSize.height);
        NSLog(@"Point Height: %f", point.y);
        [scroller setContentOffset:point animated:YES];
    }
    */
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    /*
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    svChat.contentInset = contentInsets;
    svChat.scrollIndicatorInsets = contentInsets;
    */
    CGRect fr = self->midView.frame;
    fr.size.height = midViewOriginalHeight;
    self->midView.frame = fr;
    NSLog(@"MIDVIEW FRAME RECOVERED: %f, %f, %f, %f", fr.origin.x, fr.origin.y, fr.size.width, fr.size.height);
}


-(void) startRefreshTimer {
    refresher = [NSTimer scheduledTimerWithTimeInterval:20.0
                                                 target:self
                                               selector:@selector(refresh)
                                               userInfo:nil
                                                repeats:NO];
}

-(void) fillInChat {
    
    if (refresher.isValid)
        [refresher invalidate];

    // Vaciamos svServices
    for (UIView *view in [self.svChat subviews]) {
        if ([view isKindOfClass:ChatBallon.class] || [view isKindOfClass:ChatBallonTF.class])
            [view removeFromSuperview];
    }
    [ballons removeAllObjects];
    
    // Añadimos los actuales...
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    double sep = 0;
    double marginLeft = 5;
    double marginRight = 20;
    double yTop = 20; // Empezamos en 20
    NSLog(@"refres lines: %@", lines);
    for (int i=0;i<lines.count;i++) {
        NSDictionary * line = lines[i];
        BOOL fromUser = [line[@"is_user"] integerValue] == 1;
        NSLog(@"Line: %@", line);
        int type = [((NSNumber *)line[@"type"]) intValue];
        ChatBallonTF * op = [[ChatBallonTF alloc] initWithText:line[@"text"] time:[Utils formatDateRelative:[line[@"date"] integerValue]] fromUser:fromUser];
        CGRect pos = op.frame;
        if (fromUser) {
            pos.origin.x = self.svChat.frame.size.width - pos.size.width - marginRight;
        } else {
            pos.origin.x = marginLeft;
        }
        pos.origin.y = yTop;
        op.frame = pos;
        [self.svChat addSubview:op];
        [ballons addObject:op];
        yTop += op.frame.size.height + sep;
    }
    self.svChat.contentSize = CGSizeMake(0, yTop+2*sep + 10);
    /*
    self.svChat.contentOffset = CGPointMake(0, self.svChat.contentSize.height - self.svChat.bounds.size.height + self.svChat.contentInset.bottom);
     */
}

-(void) goToEnd:(BOOL)animated {
    CGFloat offsetY = self.svChat.contentSize.height - self.svChat.bounds.size.height + self.svChat.contentInset.bottom;
    if (offsetY < 0)
        offsetY = 0;
    if (!animated) {
        self.svChat.contentOffset = CGPointMake(0, offsetY);
    } else {
        CGPoint offset = CGPointMake(0, offsetY);
        [self.svChat setContentOffset:offset animated:YES];
    }
}

-(void) refresh {
    PageChat * refThis = self;
    // Si ya estamos refrescando, no continuamos
    if (refreshing) {
        return;
    }
    if (refresher.isValid)
        [refresher invalidate];
    int lastLineId = 0;
    if (lines) {
        if (lines.count > 0) {
            NSDictionary * lastLine = lines[lines.count-1];
            if (lastLine) {
                lastLineId = [((NSNumber *)lastLine[@"id"]) intValue];
            }
        }
    }
    refreshing = YES;
    [WSDataManager getChat:chatId from:lastLineId withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
        refThis->refreshing = NO;
        if (code == WS_SUCCESS) {
            if ([theApp.pages getCurPage] && [[theApp.pages getCurPage].pageName isEqualToString:@"CHAT"]) {
                // Si tenemos líneas nuevas
                NSArray * newLines = (NSArray *)result;
                if (newLines.count > 0) {
                    for (int i=0;i<newLines.count;i++) {
                        [self->lines addObject:newLines[i]];
                    }
                    [refThis fillInChat];
                    [refThis goToEnd:YES];
                    // Sonido !!!
                    //[theApp playAudio:@"new_message"];
                }
                // Estado (miramos si ha cambiado)
                [refThis setupTool];
                // Badges
                //int badges = [((NSNumber *)refThis->task[@"allpending"]) intValue];
                //[theApp updateBadge:badges];
            }
        }
        // Lo lanzamos de nuevo...
        [self startRefreshTimer];
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    CGFloat fixedWidth = textView.frame.size.width;
    CGFloat minHeight = 37;
    CGFloat maxHeight = 120;
    textView.scrollEnabled = NO;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    if (newFrame.size.height < minHeight)
        newFrame.size.height = minHeight;
    if (newFrame.size.height > maxHeight) {
        newFrame.size.height = maxHeight;
        textView.scrollEnabled = YES;
    }
    textView.frame = newFrame;
    [self updateViewSizes];
}

-(void) updateViewSizes {
    // Edit
    CGFloat vEditHeight = self.tvEdit.frame.origin.y*2 + self.tvEdit.frame.size.height;
    self.vEdit.frame = CGRectMake(0, self.vEdit.superview.frame.size.height-vEditHeight, self.vEdit.frame.size.width, vEditHeight);

    // Si no hay tool pendiente...
    self.vTools.frame = CGRectMake(0,self.vEdit.frame.origin.y-self.vTools.frame.size.height,self.vTools.frame.size.width, self.vTools.frame.size.height);

    self.svChat.frame = CGRectMake(0, self.svChat.frame.origin.y, self.svChat.frame.size.width, self.vTools.frame.origin.y - self.svChat.frame.origin.y);
    
    /* NO ES NECESARIO AQUI
    CGPoint offset = CGPointMake(0, self.svChat.contentSize.height - self.svChat.bounds.size.height + self.svChat.contentInset.bottom);
    [self.svChat setContentOffset:offset animated:NO];
    */

    
}

-(void) addComment {
    NSString * text = [self.tvEdit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![text isEqualToString:@""]) {
        double sep = 0;
        double marginLeft = 5;
        double marginRight = 20;
        CGFloat yTop = 0;
        if (ballons.count > 0) {
            UIView * last = ballons[ballons.count-1];
            yTop = last.frame.origin.y + last.frame.size.height + sep;
        }
        ChatBallonTF * op = [[ChatBallonTF alloc] initWithText:text time:@"22:30" fromUser:YES];
        CGRect pos = op.frame;
        pos.origin.x = self.svChat.frame.size.width - pos.size.width - marginRight;
        pos.origin.y = yTop;
        op.frame = pos;
        [self.svChat addSubview:op];
        [ballons addObject:op];
        yTop += op.frame.size.height + sep;
        self.svChat.contentSize = CGSizeMake(0, yTop+2*sep+10);
    
        self.tvEdit.text = @"";
        [self textViewDidChange:self.tvEdit];
        
        op.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            op.alpha = 1.0;
        }];

        
        CGPoint offset = CGPointMake(0, self.svChat.contentSize.height - self.svChat.bounds.size.height + self.svChat.contentInset.bottom);
        [self.svChat setContentOffset:offset animated:YES];
    }
}

-(void) addImage {
    double sep = 0;
    double marginLeft = 5;
    double marginRight = 20;
    CGFloat yTop = 0;
    if (ballons.count > 0) {
        UIView * last = ballons[ballons.count-1];
        yTop = last.frame.origin.y + last.frame.size.height + sep;
    }
    ChatBallonTF * op = [[ChatBallonTF alloc] initWithImage:@"fake_service.png" time:@"22:30" fromUser:YES];
    CGRect pos = op.frame;
    pos.origin.x = self.svChat.frame.size.width - pos.size.width - marginRight;
    pos.origin.y = yTop;
    op.frame = pos;
    [self.svChat addSubview:op];
    [ballons addObject:op];
    yTop += op.frame.size.height + sep;
    self.svChat.contentSize = CGSizeMake(0, yTop+2*sep+10);
    
    self.tvEdit.text = @"";
    [self textViewDidChange:self.tvEdit];
    
    op.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        op.alpha = 1.0;
    }];
    CGPoint offset = CGPointMake(0, self.svChat.contentSize.height - self.svChat.bounds.size.height + self.svChat.contentInset.bottom);
    [self.svChat setContentOffset:offset animated:YES];
}


-(void) sendChatLine:(NSString *)text {
    [WSDataManager addChatTextLine:chatId text:text withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
        if (code == WS_SUCCESS) {
            [theApp.pages jumpToPage:@"CHAT" withContext:[self->_ctx clone] withTransition:nil andBackTransition:nil ignoreHistory:YES];
        } else {
            [theApp stdError:code];
        }
    }];
}

-(void) onDeactivate {
    if (refresher.isValid)
        [refresher invalidate];
}

-(void) onActivate {
    [self refresh];
}


-(void) pushReceived:(NSDictionary *)userInfo {
    [self refresh];
}

-(IBAction) onBtnSendClick:(UIButton *)sender {
    NSString * text = [self.tvEdit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [theApp dismissKeyboard];
    if (![text isEqualToString:@""]) {
        [self sendChatLine:text];
    }
}


-(void)setupTool {
    // Reseteamos...
    /* no hace falta, que sólo hay 1 tool
    [[self.vTools subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
     */

    if ([theApp.appConfig inChatSchedule]) {
        self.vTools.hidden = YES;
        CGRect fr = self.svChat.frame;
        fr.size.height = svChatOriginalHeight + self.vTools.frame.size.height;
        self.svChat.frame = fr;
    } else {
        self.vTools.hidden = NO;
        CGRect fr = self.svChat.frame;
        fr.size.height = svChatOriginalHeight;
        self.svChat.frame = fr;
    }
    
    /*
    // Miramos si estamos en un estado pendiente...
    NSDictionary * state = task[@"state"];
    int curStep = [((NSNumber *)state[@"curStep"]) intValue];
    NSArray * steps = state[@"steps"];

    // Miramos si tenemos step y si debemos continuar...

    NSDictionary * step = nil;
    int status = 100; // 100 => aquí equivale a SERVICIO FINALIZADO
    if (curStep < steps.count) {
        step = state[@"steps"][curStep];
        status = [((NSNumber *)step[@"status"]) intValue];
    }
    
    if (status == 100) {
        [vTools addSubview:self.vToolClosedchat];
        self.vEdit.userInteractionEnabled = NO;
        self.vEdit.alpha = 0.5;
    }
    
    // Ajustamos el tamaño de vTools a la de su hijo.
    CGFloat oldToolHeight = self.vTools.frame.size.height;
    if (self.vTools.subviews.count > 0) {
        UIView * firstChild = self.vTools.subviews[0];
        self.vTools.frame = CGRectMake(0,self.vEdit.frame.origin.y-firstChild.frame.size.height, self.vTools.frame.size.width, firstChild.frame.size.height);
    } else {
        self.vTools.frame = CGRectMake(0,self.vEdit.frame.origin.y-1, self.vTools.frame.size.width, 1);
    }
    [self updateViewSizes];
    
    // SI ha cambiado de tamaño, nos vamos al final ... suavemente ...
    if (oldToolHeight != self.vTools.frame.size.height) {
        [self goToEnd:YES];
    }
    */
}


@end
