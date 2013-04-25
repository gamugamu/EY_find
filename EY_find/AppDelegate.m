//
//  AppDelegate.m
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "AppDelegate.h"
#import "EYViewController.h"

@implementation AppDelegate

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window         = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[EYViewController new] autorelease];
    self.window.rootViewController  = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - lifeCycle

- (void)dealloc{
    [_window            release];
    [_viewController    release];
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------
@end
