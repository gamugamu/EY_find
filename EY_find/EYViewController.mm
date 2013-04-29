//
//  ViewController.m
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "EYViewController.h"
#import "VideoSource.h"
#import "IR_AVtoCVImageWrapper.h"
#import "EYDetectorNotifier.h"
#import "EYDetectorNotifier+detector.h"

@interface EYViewController ()<VideoSourceDelegate>{
    VideoSource*            _videoSource;
}
@end

@implementation EYViewController
@synthesize detectorNotifier = _detectorNotifier;

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - videoSource Delegate

- (void)frameCaptured:(frameCaptured*)captureDescription{
    // Note: On est pas dans la thread principale -> AVFoundation.
    if([_detectorNotifier canDetect]){
        cv::Mat image = imageFromAVRepresentation(captureDescription);
        // sur un Cortex-A8 600 MHz c'est lent. (iphone 3G)
        // Cortex-A8 800 MHz certainement aussi (iphone 4), mais pas encore testé.
        // Mais sur un 2 × Cortex-A9 800 MHz ça va.
        [_detectorNotifier detectOnImage: image];
    }
}

#pragma mark - lifeCycle

- (void)viewWillAppear:(BOOL)animated{
    [_videoSource startRunning];
}

- (void)viewDidDisappear:(BOOL)animated{
    [_videoSource stopRunning];
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

#pragma mark - alloc / dealloc

- (id)init{
    if(self = [super init]){
        [self setUpAll];
    }
    return self;
}

- (void)dealloc{
    [_videoSource       release];
    [_detectorNotifier  release];
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - setup

- (void)setUpAll{
    [self setUpMainView];
    [self setUpVideoSource: self.view];
    [self setUpDetector_withCameraView: self.view
                      withCaptureFrame: [_videoSource captureFrame]];
}

- (void)setUpVideoSource:(UIView*)view{
    _videoSource                = [[VideoSource alloc] init];
    _videoSource.delegate       = self;
	CALayer *videoPreviewLayer  = [view layer];
    CALayer *captureLayer       = _videoSource.previewLayer;

    [videoPreviewLayer setMasksToBounds:YES];
    [captureLayer setFrame: [view bounds]];
    [videoPreviewLayer insertSublayer:captureLayer
                                below:[[videoPreviewLayer sublayers] objectAtIndex:0]];
}

- (void)setUpDetector_withCameraView:(UIView*)view withCaptureFrame:(CGSize)captureFrame{
    _detectorNotifier = [[EYDetectorNotifier alloc] initWithCaptureFrame: captureFrame];
    _detectorNotifier.shouldDetect  = YES;
    [_detectorNotifier setCameraView: view];
}

- (void)setUpMainView{
    CGRect frame        = [UIScreen mainScreen].applicationFrame;
    UIView* mainView    = [[UIView alloc] initWithFrame: frame];
    self.view           = mainView;
    [mainView release];
}
@end
