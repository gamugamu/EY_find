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
    AVCaptureVideoPreviewLayer *_previewLayer;
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

- (void)setupVideoPreview:(AVCaptureSession*)captureSession{
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: captureSession];
    [_previewLayer setVideoGravity: AVLayerVideoGravityResizeAspectFill];
}

#pragma mark - alloc / dealloc

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    
    return nil;
}

- (AVCaptureDevice *)backFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (id)init{
    if (self = [super init]){
        currentCameraIndex  = 0;
        session             = [[AVCaptureSession alloc] init];
       
        NSError * error;
        captureInput = [AVCaptureDeviceInput deviceInputWithDevice: [self backFacingCamera] error:&error];
        
        if (error)
            NSLog(@"Couldn't create video input");
        
        
        if ([session canSetSessionPreset: AVCaptureSessionPreset1280x720])
            [session setSessionPreset: AVCaptureSessionPreset1280x720];
        
        if ([session canAddInput: captureInput]) {
            [session addInput: captureInput];
        } else{
            [session setSessionPreset: AVCaptureSessionPresetMedium];
            [session addInput: captureInput];
        }

        captureDevices      = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
                
        captureOutput = [[AVCaptureVideoDataOutput alloc] init];
        captureOutput.alwaysDiscardsLateVideoFrames = YES;

        // Set the video output to store frame in BGRA (It is supposed to be faster)
        NSString* key               = (NSString*)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* value             = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
        [captureOutput setVideoSettings:videoSettings];
        
        /*We create a serial queue to handle the processing of our frames*/
        dispatch_queue_t queue;
        queue                       = dispatch_queue_create("com.EY_find.cameraQueue", NULL);
        dispatch_queue_t hight      = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, NULL);
        dispatch_set_target_queue(queue, hight);

        [captureOutput setSampleBufferDelegate:self queue:queue];        
        [session addOutput:captureOutput];
        [self setupVideoPreview: session];
        
        dispatch_release(queue);
    }
    
    return self;
}

- (void)dealloc{
    [captureOutput  release];
    [captureDevices release];
    [session        release];
    [_previewLayer  release];
    [super dealloc];
}
@end
