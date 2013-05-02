//
//  WebView.m
//  EY_find
//
//  Created by Abadie, Loïc on 29/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "WebView.h"

@interface WebView()<UIWebViewDelegate>{
    UIWebView* _webView;
}
@end

@implementation WebView

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------


#pragma mark public

- (void)loadUrl:(NSString*)stringUrl{
    NSURL* url = [NSURL URLWithString: stringUrl];
    NSURLRequest* request = [NSURLRequest requestWithURL: url];
    [_webView loadRequest: request];
}

#pragma mark - uiwebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"zoomm scale %f", webView.scrollView.zoomScale);
    webView.scrollView.zoomScale = .5f;
    //[webView scalesPageToFit];
    webView.scrollView.minimumZoomScale = .3f;
    [webView.scrollView setZoomScale: .5f animated: YES];
    NSLog(@" - zoomm scale %f", webView.scrollView.zoomScale);

}

#pragma mark - alloc / dealloc

- (id)init{
    if(self = [super init]){
        [self setUpAll];
    }
    return self;
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - setUp

- (void)setUpAll{
    self.view           = [self setUpWebView];
    _webView            = (UIWebView*)self.view;
    _webView.delegate   = self;
    [self setUpBackButtonInView: _webView];
}

- (UIView*)setUpWebView{
    UIWebView* view = [[UIWebView alloc] initWithFrame: CGRectMake(0, 20, 320, 460)];
    return [view autorelease];
}

- (void)setUpBackButtonInView:(UIView*)view{
    UIButton* button        = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 50, 50)];
    
    [button addTarget: self
               action: @selector(goBackToParentViewController)
     forControlEvents: UIControlEventTouchDown];
   
    [view addSubview: button];
    [button release];
}

#pragma mark - logic

- (void)goBackToParentViewController{
    [self dismissViewControllerAnimated: YES completion: nil];
}
@end
