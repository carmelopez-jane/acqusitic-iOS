//
//  PageWeb.h
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "HeaderEdit.h"

@interface PageWeb : PageBase <UIWebViewDelegate>{
    PageContext *_ctx;
}

@property (strong, nonatomic) IBOutlet HeaderEdit *vHeader;
@property (strong, nonatomic) IBOutlet UIWebView *wvService;

@end
