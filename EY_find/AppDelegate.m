//
//  AppDelegate.m
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "AppDelegate.h"
#import "EYCameraViewController.h"
#import "PopOnDetection.h"
#import "WebView.h"
#import "ProductData.h"

@interface AppDelegate(){
    PopOnDetection* _pop;
}
@end
@implementation AppDelegate

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window         = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[EYCameraViewController new] autorelease];
    self.window.rootViewController  = self.viewController;
    [self.window makeKeyAndVisible];

    [self setUpPop];
    [_pop popUpImage: @"camera.png"];

    return YES;
}

#pragma mark - lifeCycle

- (void)dealloc{
    [_pop               release];
    [_window            release];
    [_viewController    release];
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

- (void)setUpPop{
    _pop = [[PopOnDetection alloc] initWithDetector: _viewController
                                   andViewToDisplay: _viewController.view];
    
    _pop.scanIndexFound = ^(unsigned idx, PopOnDetection* pop){
        pop.productDescription.text = [ProductData labelForProduct: idx];
        [pop popUpImage: [ProductData imageForIndex: idx]];
    };
    
    _pop.goPressed = ^(unsigned idx, PopOnDetection* pop){
        [self swapToWebViewController: [ProductData urlForLabel: idx]];
    };
}

- (void)swapToWebViewController:(NSString*)stringUlr{
    WebView* webView = [[WebView alloc] init];
    [webView loadUrl: stringUlr];
    webView.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    
    [_viewController presentViewController: webView animated: YES completion: nil];
    [webView release];
}
@end
