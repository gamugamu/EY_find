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
#import "ImageRecognizer.h"

@interface ViewController ()<VideoSourceDelegate>{
    VideoSource*    _videoSource;
    GLESImageView*  _GLView;
}
@end

@implementation ViewController

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - videoSource Delegate

- (void)frameCaptured:(cv::Mat)frame{
    [_GLView drawFrame: frame];
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
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - setup

- (void)setUpAll{
    [self setUpOpenGlView];
    [self setUpVideoSource];
    self.view = _GLView;
}

- (void)setUpVideoSource{
    _videoSource            = [[VideoSource alloc] init];
    _videoSource.delegate    = self;
}

- (void)setUpOpenGlView{
    CGRect frame    = [UIScreen mainScreen].applicationFrame;
    _GLView         = [[GLESImageView alloc] initWithFrame: frame];
}
@end
