//
//  DetectorNotifier.m
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import <objc/runtime.h> // pour la reflexivité en c
#import <objc/message.h> // pour les messages en c.

#import "DetectorNotifier.h"
#import "IR_Detector.h"
#import "IR_AVtoCVImageWrapper.h"
#import "UIImage+OpenCV.h"

@interface DetectorNotifier(){
    IR_Detector* _detector;
}
@property(nonatomic, readonly)int currentImageDetected;
@end

static id DETECTOR_SINGLETON;
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
        // note ça sera un singleton, donc ok.
        DETECTOR_SINGLETON = self;
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

// c'est un callback en c, donc on utilise le runtime d'objc.
void ir_imageFound(unsigned idx){
    int value;
    object_getInstanceVariable(DETECTOR_SINGLETON, ivar_currentImageDetected, (void**)&value);
    
    if(value != idx){
        id delegate;
        // récupère le delegate et plus haut la valeur de l'index de l'image courrante.
        object_getInstanceVariable(DETECTOR_SINGLETON, "_delegate", (void**)&delegate);
        SEL SEL_imageFound  = @selector(imageFound:intoView:);
        bool canRespond     = class_respondsToSelector(object_getClass(delegate), SEL_imageFound);
        
        // assigne la nouvelle valeure.
        /* *(int**)& on renvoie l'adresse de la variable, et on la type en pointeur de pointeur de int + déréférence */
        object_setInstanceVariable(DETECTOR_SINGLETON, ivar_currentImageDetected, (int*)idx);
        
        int value;
        object_getInstanceVariable(DETECTOR_SINGLETON, ivar_currentImageDetected, (void**)&value);
        
        if(canRespond){
            objc_msgSend(delegate, SEL_imageFound, idx, NULL);
        }
    }
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
