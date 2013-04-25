//
//  DetectorNotifier.m
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "DetectorNotifier.h"
#import "IR_Detector.h"

@implementation DetectorNotifier
@synthesize delegate;

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

- (void)startObserving{

}

// arrête d'être informé des detections d'images.
- (void)stopOberving{

}

- (void)reset{

}

#pragma mark - alloc / dealloc

- (id)init{

}

- (void)dealloc{
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

@end
