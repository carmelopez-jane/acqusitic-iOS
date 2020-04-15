//
//  PagePerfConfirmSelected.h
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "HeaderEdit.h"
#import "Performance.h"
#import "PerfInfoLOPD.h"
#import "PerfInfoAddInfo.h"
#import "PerformanceDist.h"
#import "FormBuilder.h"
#import "Performer.h"
#import "Group.h"
#import "PerformanceDist.h"

@interface PagePerfConfirmSelected : PageBase {
    PageContext *_ctx;
    
    NSInteger performanceId;
    Group * group;
    Performance * performance;
    PerformanceDist * distribution;
    int step;
    NSInteger group_id;

    UIView * infoView;
    int baseY, baseHeight, infoY, infoHeight;
    
    PerfInfoAddInfo * vAddInfo;
    PerfInfoLOPD * vLOPD;
    
    FormBuilder * distributionFM;
    NSMutableArray * finalPerformers;
    NSString * group_notes;

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
