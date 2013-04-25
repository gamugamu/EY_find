//
//  EYCameraViewController.h
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "EYViewController.h"
#import "EYRecognizerDelegate.h"

// EYCameraViewController est une facade de EYViewController. Se charge de
// faire l'interface cliente pour EYDetector, en conservant une interface VueController.
// Pour ça que EYViewController a été surchargé.
@interface EYCameraViewController : EYViewController<EYDetector>
@property(nonatomic, assign)id<EYRecognizerDelegate>delegate;
@end
