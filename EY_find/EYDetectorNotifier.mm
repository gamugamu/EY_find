//
//  DetectorNotifier.m
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import <objc/runtime.h> // pour la reflexivité en c
#import <objc/message.h> // pour les messages en c.

#import "EYDetectorNotifier.h"
#import "IR_Detector.h"
#import "IR_AVtoCVImageWrapper.h"
#import "UIImage+OpenCV.h"

@interface EYDetectorNotifier(){
    IR_Detector* _detector;
}
@property(nonatomic, readonly)int currentImageDetected;
@property(nonatomic, retain)UIView* cameraView;
@end

static id DETECTOR_SINGLETON;
static const char ivar_currentImageDetected[]   = "_currentImageDetected";
static const char ivar_delegate[]               = "_delegate";
static const char ivar_cameraView[]             = "_cameraView";

@implementation EYDetectorNotifier
@synthesize delegate                = _delegate,
            shouldDetect            = _shouldDetect,
            currentImageDetected    = _currentImageDetected,
            cameraView              = _cameraView;

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

- (void)reset{
    _currentImageDetected = IR_ImageNotFound;
}

// categorie
- (void)detectOnImage:(cv::Mat)image{
    // pas de delegate, pas de chocolats!
    if(_shouldDetect || !_delegate)
        _detector->processFrame(image);
}

#pragma mark - hidden category

- (BOOL)canDetect{
    return _detector->canProceed();
}

#pragma mark - alloc / dealloc

- (id)initWithCaptureFrame:(CGSize)captureSize{
    if(self = [super init]){
        [self setUpAll: captureSize];
    }
    return self;
}

- (id)init{
    if(self = [super init]){
       
    }
    return self;
}

- (void)dealloc{
    delete _detector;
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

- (void)setUpAll:(CGSize)size{
    [self setUpDefault];
    [self setUpDetector: size];
    // note ça sera un singleton, donc ok.
    DETECTOR_SINGLETON = self;
}

#pragma mark - IR_DetectorCallBack

// c'est un callback en c, donc on utilise le runtime d'obj-c.
void ir_imageFound(unsigned idx){
    int value;
    object_getInstanceVariable(DETECTOR_SINGLETON, ivar_currentImageDetected, (void**)&value);
    
    if(value != idx){
        id delegate;
        // récupère le delegate et plus haut la valeur de l'index de l'image courrante.
        object_getInstanceVariable(DETECTOR_SINGLETON, ivar_delegate, (void**)&delegate);
        SEL SEL_imageFound  = @selector(imageFound:intoView:);
        bool canRespond     = class_respondsToSelector(object_getClass(delegate), SEL_imageFound);
        
        // assigne la nouvelle valeure.
        /* *(int**)& on renvoie l'adresse de la variable, et on la type en pointeur de pointeur de int + déréférence */
        object_setInstanceVariable(DETECTOR_SINGLETON, ivar_currentImageDetected, (int*)idx);
        
        if(canRespond){
            // le callBack est renvoyé dans la thread principale. Comme ça le client peut faire
            // son GUI en toute transparence. Malgrès que tout le calcul s'est fait en tâche de fond.
            dispatch_async(dispatch_get_main_queue(), ^{
                // cameraView appartient au controlleur qui manipule les images et le Detector.
                id cameraView;
                object_getInstanceVariable(DETECTOR_SINGLETON, ivar_cameraView, (void**)&cameraView);
                objc_msgSend(delegate, SEL_imageFound, idx, cameraView);
            });
        }
    }
}

#pragma mark - global

- (void)setUpDefault{
    [self reset];
}

- (void)setUpDetector:(CGSize)size{
    _detector = new IR_Detector(size.width, size.height, ir_imageFound, true);
    
#warning test à enlever
    // note: test seulement
#define TOTAL 7
    NSString* image[TOTAL] = {
        @"img_0.png",
        @"img_1.jpg",
        @"img_2.jpg",
        @"key_1.jpg",
        @"lion_0.jpg",
        @"lion_1.jpg",
        @"blum_0.jpg"
    };
    
    for (int i = 0; i < TOTAL; i++) {
        UIImage* img_0  = [UIImage imageNamed: image[i]];
        _detector->testPonyDetectCreateDescriptor([img_0 toMat]);
    }
}

@end
