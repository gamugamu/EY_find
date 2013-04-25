//
//  ViewController.m
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "EYViewController.h"
#import "VideoSource.h"
#import "GLESImageView.h"
#import "IR_AVtoCVImageWrapper.h"
#import "EYDetectorNotifier.h"
#import "EYDetectorNotifier+detector.h"

@interface EYViewController ()<VideoSourceDelegate>{
    VideoSource*            _videoSource;
    GLESImageView*          _GLView;
    dispatch_queue_t        _detectorQueue;
}
@end

@implementation EYViewController
@synthesize detectorNotifier = _detectorNotifier;

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - videoSource Delegate

- (void)frameCaptured:(frameCaptured*)captureDescription{
    // Note: Nous ne somme pas dans la thread principale. Ceci
    // est du à AVFoundation.
    cv::Mat image = imageFromAVRepresentation(captureDescription);

    if([_detectorNotifier canDetect]){
        cv::Mat outputImage = image.clone();
        
        dispatch_async(_detectorQueue, ^(void){
            [_detectorNotifier detectOnImage: outputImage];
        });
    }
    [_GLView drawFrame: image];
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
    dispatch_release(_detectorQueue);
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - setup

- (void)setUpAll{
    [self setUpDetectorQueue];
    [self setUpOpenGlView];
    [self setUpVideoSource];
    [self setUpDetector: _GLView];
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

- (void)setUpDetector:(UIView*)GLView{
    _detectorNotifier               = [EYDetectorNotifier new];
    _detectorNotifier.shouldDetect  = YES;
    [_detectorNotifier setCameraView: GLView];
}

- (void)setUpDetectorQueue{
    _detectorQueue = dispatch_queue_create("com.EY_find.IR_Lib.detectorQueue", NULL);  
}

@end
