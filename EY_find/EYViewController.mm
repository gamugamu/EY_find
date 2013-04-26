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
    
    //[_GLView drawFrame: image];
    
    if([_detectorNotifier canDetect]){
        cv::Mat image = imageFromAVRepresentation(captureDescription).clone();
        // sur un Cortex-A8 600 MHz c'est lent. (iphone 3G)
        // Cortex-A8 800 MHz certainement aussi (iphone 4), mais pas encore testé.
        // En plus le processeur graphique powerVR est pas terrible, ce qui donne
        // une pénalité de plus lorsque l'on utilise openGL (sad).
        // Mais sur un 2 × Cortex-A9 800 MHz le multi thread fonctionne. Forcement.
        // Et tout les tutti-frutty au dessus ça fonctionne aussi.
        // (Pour tout ces cranneurs qui tournent sur le A6 (pseudo ARM Cortex-A15 en
        // bi coeur + PowerVR * 4, je ne me fait pas de soucis).
        
        // Donc pour ne pas pénaliser le GUI sur le calcul de détéction
        // (le parallelisme ne fonctionne vraiment physiquement
        // que si il y a plusieurs processeurs). Dans un seul core, les calculs
        // se font par priorité dans un simili de parallelisme. Donc _detectorQueue
        // est de priorité LOW, sinon ça va ramer, parce qu'il y a aussi l'affichage
        // de la vue openGL.
       // dispatch_async(_detectorQueue, ^(void){
            [_detectorNotifier detectOnImage: image];
        
        //});
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
    dispatch_release(_detectorQueue);
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - setup

- (void)setUpAll{
    [self setUpDetectorQueue];
    [self setUpMainView];
    [self setUpVideoSource: self.view];
    // Note: La vue openGL est dessinée dans une autre thread, nottament à cause
    // de AVCapture. Comme le client va disposer d'une vue afin d'afficher des
    // layers, on utilisera donc une view qui servira de container. Comme ça
    // la vue OpenGL et la vue principale peuvent être utilisée sur des threads
    // différentes (côté client forcement sur la thread principale).
    [self setUpDetector_withCameraView: self.view];
}

- (void)setUpVideoSource:(UIView*)view{
    _videoSource                = [[VideoSource alloc] init];
    _videoSource.delegate       = self;
	CALayer *videoPreviewLayer  = [view layer];
    CALayer *captureLayer       = [_videoSource previewLayer];

    [videoPreviewLayer setMasksToBounds:YES];
    [captureLayer setFrame: [view bounds]];
    [videoPreviewLayer insertSublayer:captureLayer below:[[videoPreviewLayer sublayers] objectAtIndex:0]];
}

- (void)setUpDetector_withCameraView:(UIView*)view{
    _detectorNotifier               = [EYDetectorNotifier new];
    _detectorNotifier.shouldDetect  = YES;
    [_detectorNotifier setCameraView: view];
}

- (void)setUpDetectorQueue{
    _detectorQueue          = dispatch_queue_create("com.EY_find.IR_Lib.detectorQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t low    = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, NULL);

    dispatch_set_target_queue(_detectorQueue, low);
}

- (void)setUpMainView{
    CGRect frame        = [UIScreen mainScreen].applicationFrame;
    UIView* mainView    = [[UIView alloc] initWithFrame: frame];
    self.view           = mainView;
    [mainView release];
}
@end
