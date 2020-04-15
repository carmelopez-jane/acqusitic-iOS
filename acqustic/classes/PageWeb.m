//
//  PageWeb.m
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageWeb.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "HeaderEdit.h"

@interface PageWeb ()

@end

@implementation PageWeb

@synthesize vHeader, wvService;

-(void)onEnterPage:(PageContext *)context{
    
    [super onEnterPage:context];

    [self loadNIB:@"PageWeb"];
    //[super setTopColor:RACC_YELLOW];

    _ctx = context;
    
    self.vHeader.title = [context paramByName:@"title"];
    self.vHeader.btnSave.hidden = YES;
    
    NSString * htmlPage = [NSString stringWithFormat:@"%@_%@", [context paramByName:@"content"], NSLocalizedString(@"lang", nil)];
    NSString* path = [[NSBundle mainBundle] pathForResource:htmlPage
                                                     ofType:@"html"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSString * bundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
    
    [self.wvService loadHTMLString:content baseURL:baseURL];
    /*
    self.wvService.delegate = self;
    [self.wvService loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://sso.fedrepsol.com/idp/startSSO.ping?PartnerSpId=SPARADAS"]]];
    */
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}

/*
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"WEBVIEW LOAD %@", request);
    NSLog(@"HEADERS: %@", request.allHTTPHeaderFields);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView
didFailLoadWithError:(NSError *)error {
    
}
*/
@end
