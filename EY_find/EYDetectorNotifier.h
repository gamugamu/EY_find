//
//  DetectorNotifier.h
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EYRecognizerDelegate.h"

@interface EYDetectorNotifier : NSObject<EYDetector>
- (id)initWithCaptureFrame:(CGSize)captureSize;
@property(nonatomic, assign)id<EYRecognizerDelegate>delegate;
@end
