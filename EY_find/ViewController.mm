//
//  ViewController.m
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "ViewController.h"
#import "VideoSource.h"
#import "GLESImageView.h"
#import "IR_AVtoCVImageWrapper.h"
#import "DetectorNotifier.h"
#import "DetectorNotifier+detector.h"

@interface ViewController ()<VideoSourceDelegate, DetectorNotifierDelegate>{
    VideoSource*        _videoSource;
    GLESImageView*      _GLView;
    DetectorNotifier*   _detectorNotifier;
}
@end

@implementation ViewController

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - videoSource Delegate

- (void)frameCaptured:(frameCaptured*)captureDescription{
    // Note: Nous ne somme pas dans la thread principale. Ceci
    // est du à AVFoundation.
    cv::Mat image = imageFromAVRepresentation(captureDescription);
    [_detectorNotifier detectOnImage: image];
    [_GLView drawFrame: image];
}

#pragma mark - DetectorNotifierDelegate

- (void)imageFound:(unsigned)index intoView:(UIView*)cameRaView{
    NSLog(@"called------------------------------- %u %p", index, cameRaView);
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
    [_GLView            release];
    [_detectorNotifier  release];
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - setup

- (void)setUpAll{
    [self setUpOpenGlView];
    [self setUpVideoSource];
    [self setUpDetector];
    self.view = _GLView;
}

- (void)setUpVideoSource{
    _videoSource            = [[VideoSource alloc] init];
    _videoSource.delegate   = self;
}

- (void)setUpOpenGlView{
    CGRect frame    = [UIScreen mainScreen].applicationFrame;
    _GLView         = [[GLESImageView alloc] initWithFrame: frame];
}

- (void)setUpDetector{
    _detectorNotifier               = [DetectorNotifier new];
    _detectorNotifier.shouldDetect  = YES;
    _detectorNotifier.delegate      = self;
}

@end
