//
//  ViewController.m
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "ViewController.h"
#import <opencv2/highgui/cap_ios.h>
using namespace cv;

@interface ViewController (){
    CvVideoCamera*  _videoCamera;
    UIImageView*    _videoDisplayer;
}
@end

@implementation ViewController

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - lifeCycle

- (void)viewDidLoad{
    [super viewDidLoad];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - setup

- (void)setUpVideoCamera:(CvVideoCamera*)videoCamera withParentView:(UIView*)view{
    videoCamera = [[CvVideoCamera alloc] initWithParentView: view];
    videoCamera.defaultAVCaptureDevicePosition      = AVCaptureDevicePositionFront;
    videoCamera.defaultAVCaptureSessionPreset       = AVCaptureSessionPreset352x288;
    videoCamera.defaultAVCaptureVideoOrientation    = AVCaptureVideoOrientationPortrait;
    videoCamera.defaultFPS      = 30;
    videoCamera.grayscaleMode   = NO;
}
@end
