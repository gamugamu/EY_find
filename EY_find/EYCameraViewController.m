//
//  EYCameraViewController.m
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "EYCameraViewController.h"
#import "EYDetectorNotifier.h"

@interface EYCameraViewController ()

@end

@implementation EYCameraViewController

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - facade

- (void)setDelegate:(id<EYRecognizerDelegate>)delegate{
    [super detectorNotifier].delegate = delegate;
}

- (BOOL)shouldDetect{
    return [super detectorNotifier].shouldDetect;
}

- (void)setShouldDetect:(BOOL)shouldDetect{
    [super detectorNotifier].shouldDetect = shouldDetect;
}

- (void)reset{
    [[super detectorNotifier] reset];
}

@end
