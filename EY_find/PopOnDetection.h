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
- (id)initWithDetector:(id<EYDetector>)detector andViewToDisplay:(UIView*)view;
- (void)popUpImage:(NSString*)imageName;
- (IBAction)closeTapped:(UIButton *)sender;
- (IBAction)goToUrlTapped:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIView *displayer;
@property (retain, nonatomic) IBOutlet UIImageView *productView;

@end
