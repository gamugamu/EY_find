//
//  DetectorNotifier_detector.h
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "DetectorNotifier.h"

@interface DetectorNotifier (detector)
- (void)detectOnImage:(cv::Mat)image;
- (void)setCameraView:(UIView*)view;
// detector wrapper (IR_Detector->canProceed())
- (BOOL)canDetect;
@end
