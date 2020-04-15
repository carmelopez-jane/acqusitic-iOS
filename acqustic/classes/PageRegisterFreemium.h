//
//  PageRegisterFreemium.h
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "HeaderEdit.h"
#import "Performance.h"
#import "DownMOptionsPicker.h"

@interface PageRegisterFreemium : PageBase {
    PageContext *_ctx;
    
    NSInteger performanceId;
    Performance * performance;
    
    DownMOptionsPicker * picker;
}

@property (strong, nonatomic) IBOutlet UIScrollView *svContent;
@property (strong, nonatomic) IBOutlet UILabel * lblTitle;
@property (strong, nonatomic) IBOutlet UIButton * btnComplete;
@property (strong, nonatomic) IBOutlet UIButton * btnLater;



@end
