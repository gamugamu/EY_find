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

@interface AppDelegate(){
    PopOnDetection* pop;
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

    // test
    pop            = [[PopOnDetection alloc] initWithDetector: _viewController
                                             andViewToDisplay: _viewController.view];

    [pop popUpImage: @"casque.jpg"];
    pop.scanIndexFound = ^(unsigned idx){
        [self swapToWebViewController: idx];
    };
    return YES;
}

#pragma mark - lifeCycle

- (void)dealloc{
    [pop                release];
    [_window            release];
    [_viewController    release];
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

- (void)swapToWebViewController:(unsigned)idx{
    WebView* webView = [[WebView alloc] init];
    [webView loadUrl: @"http://www.google.fr"];
    [_viewController presentViewController: webView animated: YES completion: nil];
    [webView release];
}
@end
