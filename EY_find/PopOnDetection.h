//
//  PopOnDetection.h
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EYRecognizerDelegate.h"

@interface PopOnDetection : UIViewController<EYRecognizerDelegate>
@property(nonatomic, retain)id<EYDetector> eyDetector;
- (IBAction)closeTapped:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UILabel *index;
@end
