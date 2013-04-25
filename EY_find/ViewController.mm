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
#import "IR_Detector.h"
#import "UIImage+OpenCV.h"

@interface ViewController ()<VideoSourceDelegate>{
    VideoSource*    _videoSource;
    GLESImageView*  _GLView;
    IR_Detector*    _detector;
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
    _detector->processFrame(image);
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
    [_videoSource   release];
    [_GLView        release];
    delete _detector;
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - IR_DetectorCallBack

void ir_imageFound(unsigned idx){
    printf("ffffound %u\n", idx);

}

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
    _detector = new IR_Detector(640, 480, ir_imageFound);
    
    // note: test seulement
    UIImage* referer    = [UIImage imageNamed: @"referer_2.jpg"];
    UIImage* referer2   = [UIImage imageNamed: @"eclipse.jpg"];
    UIImage* ramen      = [UIImage imageNamed: @"ramen.jpg"];

    _detector->testPonyDetectCreateDescriptor([referer toMat]);
    _detector->testPonyDetectCreateDescriptor([referer2 toMat]);
    _detector->testPonyDetectCreateDescriptor([ramen toMat]);

}

@end
