//
//  PopOnDetection.h
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EYRecognizerDelegate.h"

@class FTImagePageControl;
@interface PopOnDetection : UIViewController<EYRecognizerDelegate>
@property(nonatomic, retain)id<EYDetector> eyDetector;
// callBack lorsqu'une image a été retrouvé
@property(nonatomic, copy)void(^scanIndexFound)(unsigned idx, PopOnDetection* pop);
// callBack lorsque le bouton a été pressé.
@property(nonatomic, copy)void(^goPressed)(unsigned idx, PopOnDetection* pop);

- (id)initWithDetector:(id<EYDetector>)detector andViewToDisplay:(UIView*)view;
- (void)popUpImage:(NSString*)imageName;
// GUI logic
- (IBAction)closeTapped:(UIButton *)sender;
- (IBAction)goToUrlTapped:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet FTImagePageControl *pageController;
@property (retain, nonatomic) IBOutlet UIView *displayer;
@property (retain, nonatomic) IBOutlet UILabel *productDescription;
@property (retain, nonatomic) IBOutlet UIImageView *productView;
@end
