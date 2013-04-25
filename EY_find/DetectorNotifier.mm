//
//  DetectorNotifier.m
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import <objc/runtime.h>
#import "DetectorNotifier.h"
#import "IR_Detector.h"
#import "IR_AVtoCVImageWrapper.h"
#import "UIImage+OpenCV.h"

@interface DetectorNotifier(){
    IR_Detector* _detector;
}
@property(nonatomic, readonly)int currentImageDetected;
@end

static id SELF;
static const char ivar_currentImageDetected[] = "_currentImageDetected";

@implementation DetectorNotifier
@synthesize delegate                = _delegate,
            shouldDetect            = _shouldDetect,
            currentImageDetected    = _currentImageDetected;

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

- (void)reset{
    _currentImageDetected = IR_ImageNotFound;
}

// categorie
- (void)detectOnImage:(cv::Mat)image{
    if(_shouldDetect)
        _detector->processFrame(image);
}

#pragma mark - alloc / dealloc

- (id)init{
    if(self = [super init]){
        [self setUpDefault];
        [self setUpDetector];
        SELF = self;
    }
    return self;
}

- (void)dealloc{
    delete _detector;
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - IR_DetectorCallBack

void ir_imageFound(unsigned idx){
    int value;
    object_getInstanceVariable(SELF, ivar_currentImageDetected, (void**)&value);
    
    printf("--value %i %p\n", value, SELF);
   /* if(value != idx)
        if(0){
            printf("ffffound %u\n", idx);
        }
    */
}

#pragma mark - global

- (void)setUpDefault{
    [self reset];
    printf("test %i\n", _currentImageDetected);
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
