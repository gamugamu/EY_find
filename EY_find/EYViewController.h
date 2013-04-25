//
//  ViewController.h
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EYDetectorNotifier;
@interface EYViewController : UIViewController
@property(nonatomic, readonly)EYDetectorNotifier* detectorNotifier;
@end
