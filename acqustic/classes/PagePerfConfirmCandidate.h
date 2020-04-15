//
//  PagePerfConfirmCandidate.h
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "HeaderEdit.h"
#import "Performance.h"

@interface PagePerfConfirmCandidate : PageBase {
    PageContext *_ctx;
    
    NSInteger performanceId;
    Performance * performance;
    int step;
    UIView * infoView;
}

@property (strong, nonatomic) IBOutlet UIScrollView *svContent;
@property (strong, nonatomic) IBOutlet UILabel * lblTitle;
@property (strong, nonatomic) IBOutlet UILabel * lblDescription;
@property (strong, nonatomic) IBOutlet UILabel * lblGroup;
@property (strong, nonatomic) IBOutlet UIView * vClose;
@property (strong, nonatomic) IBOutlet UIView * vChat;
@property (strong, nonatomic) IBOutlet UIImageView * ivAlert;
@property (strong, nonatomic) IBOutlet UIView * vInfo;
@property (strong, nonatomic) IBOutlet UIScrollView * svInfo;

@property (strong, nonatomic) IBOutlet UIButton * btnAction1;
@property (strong, nonatomic) IBOutlet UIButton * btnAction2;
@property (strong, nonatomic) IBOutlet UIButton * btnAction3;


@end
