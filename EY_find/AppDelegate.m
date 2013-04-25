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
    pop                         = [[PopOnDetection alloc] initWithNibName: @"PopOnDetection" bundle: nil];
    _viewController.delegate    = pop;
    pop.eyDetector              = _viewController;
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
@end
