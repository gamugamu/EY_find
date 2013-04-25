//
//  VideoSource.m
//  OpenCV Tutorial
//
//  Created by BloodAxe on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoSource.h"

@interface VideoSource (){
  AVCaptureSession * session;
  NSArray * captureDevices;
  AVCaptureDeviceInput * captureInput;
  AVCaptureVideoDataOutput * captureOutput;
  int currentCameraIndex;
}
@end

@implementation VideoSource
@synthesize delegate;

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

- (bool) hasMultipleCameras{
  return [captureDevices count] > 1;
}

- (AVCaptureVideoOrientation) videoOrientation{
  AVCaptureConnection * connection = [captureOutput connectionWithMediaType:AVMediaTypeVideo];
  
    if (connection)
    return [connection videoOrientation];
  
  NSLog(@"Warning  - cannot find AVCaptureConnection object");
  return AVCaptureVideoOrientationLandscapeRight;
}

- (void) toggleCamera{
  currentCameraIndex++;
  int camerasCount      = [captureDevices count];
  currentCameraIndex    = currentCameraIndex % camerasCount;
  
  AVCaptureDevice *videoDevice = [captureDevices objectAtIndex:currentCameraIndex];

  [session beginConfiguration];
  
  if (captureInput){
    [session removeInput:captureInput];
  }
  
  NSError * error;
  captureInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
  
  if (error)
    NSLog(@"Couldn't create video input");

  [session addInput:captureInput];
  [session setSessionPreset:AVCaptureSessionPreset640x480];
  [session commitConfiguration];
}

- (void) startRunning{
  [session startRunning];
}

- (void) stopRunning{
  [session stopRunning];
}

#pragma mark -
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection{ 
    if (!delegate)
        return;
  
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
  
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
  
    /*Get information about the image*/
    frameCaptured capture;
    capture.baseAddress     = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    capture.width           = CVPixelBufferGetWidth(imageBuffer);
    capture.height          = CVPixelBufferGetHeight(imageBuffer);
    capture.stride          = CVPixelBufferGetBytesPerRow(imageBuffer);
    capture.orientation     = self.videoOrientation;
    
    if([delegate respondsToSelector: @selector(frameCaptured:)])
        [delegate frameCaptured: &capture];
  
    /* We unlock the  image buffer */
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
}

#pragma mark - alloc / dealloc

- (id)init{
    if (self = [super init]){
        currentCameraIndex  = 0;
        session             = [[AVCaptureSession alloc] init];
        [session setSessionPreset:AVCaptureSessionPreset640x480];
        captureDevices      = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        AVCaptureDevice *videoDevice = [captureDevices objectAtIndex:0];
        
        NSError * error;
        captureInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
            NSLog(@"Couldn't create video input");
        
        captureOutput = [[AVCaptureVideoDataOutput alloc] init];
        captureOutput.alwaysDiscardsLateVideoFrames = YES;
        
        // Set the video output to store frame in BGRA (It is supposed to be faster)
        NSString* key               = (NSString*)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* value             = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
        [captureOutput setVideoSettings:videoSettings];
        
        /*We create a serial queue to handle the processing of our frames*/
        dispatch_queue_t queue;
        queue = dispatch_queue_create("com.EY_find.cameraQueue", NULL);
        [captureOutput setSampleBufferDelegate:self queue:queue];
        dispatch_release(queue);
        
        [session addInput:captureInput];
        [session addOutput:captureOutput];
    }
    
    return self;
}

- (void)dealloc{
    [captureOutput  release];
    [captureDevices release];
    [session        release];
    [super dealloc];
}
@end
