//
//  VideoSource.h
//  OpenCV Tutorial
//
//  Created by BloodAxe on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "IR_AVFrameRep.h"

@protocol VideoSourceDelegate <NSObject>
- (void)frameCaptured:(frameCaptured*)captureDescription;
@end

@interface VideoSource : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
@property(nonatomic, assign)id<VideoSourceDelegate> delegate;
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;
- (AVCaptureVideoOrientation) videoOrientation;
- (bool) hasMultipleCameras;
- (void) toggleCamera;
- (void) startRunning;
- (void) stopRunning;
@end