//
//  PagePerfResume.h
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "HeaderEdit.h"
#import "Performance.h"

@interface PagePerfResume : PageBase {
    PageContext *_ctx;
    
    NSInteger performanceId;
    Performance * performance;
}

@property (strong, nonatomic) IBOutlet UIScrollView *svContent;
@property (strong, nonatomic) IBOutlet UILabel * lblTitle;
@property (strong, nonatomic) IBOutlet UILabel * lblDescription;
@property (strong, nonatomic) IBOutlet UILabel * lblGroup;
@property (strong, nonatomic) IBOutlet UILabel * lblDetail;
@property (strong, nonatomic) IBOutlet UIView * vClose;
@property (strong, nonatomic) IBOutlet UIButton * btnRuta;
@property (strong, nonatomic) IBOutlet UIButton * btnBack;


@end
