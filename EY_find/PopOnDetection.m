//
//  PopOnDetection.m
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "PopOnDetection.h"

@interface PopOnDetection ()
@property(nonatomic, retain)UIView* viewDisplayer;
@end

@implementation PopOnDetection
@synthesize eyDetector      = _eyDetector,
            viewDisplayer   = _viewDisplayer;

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

- (void)imageFound:(unsigned)index intoView:(UIView*)cameRaView{
    [cameRaView addSubview: self.view];
    [self displayIndex: index];
}

- (void)popUpImage:(NSString*)imageName{
    self.view.hidden   = NO;
    _productView.image  = [UIImage imageNamed: imageName];
    [_viewDisplayer addSubview: self.view];
}

- (IBAction)closeTapped:(UIButton *)sender{
    [_eyDetector reset];
    [self.view removeFromSuperview];
}

- (IBAction)goToUrlTapped:(UIButton *)sender{
}

#pragma mark - lifeCycle

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewDidUnload{
    [self setProductView:nil];
    [self setDisplayer:nil];
    [super viewDidUnload];
}

#pragma mark - alloc / dealloc

- (id)initWithDetector:(id<EYDetector>)detector
      andViewToDisplay:(UIView*)view{
    if (self = [super initWithNibName: @"PopOnDetection"
                               bundle: nil]) {
        self.viewDisplayer  = view;
        self.eyDetector     = detector;
        detector.delegate   = self;
        
        [self displayTargetInView: view];
    }
    return self;
}

- (void)dealloc{
    [_eyDetector    release];
    [_productView   release];
    [_displayer     release];
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

#pragma mark - display

- (void)displayTargetInView:(UIView*)view{
    UIImage* image      = [UIImage imageNamed: @"target.png"];
    UIImageView* target = [[UIImageView alloc] initWithImage: image];
    
    // on recentre
    target.center = (CGPoint){160, 230};
    
    [view addSubview: target];
    [target release];
}

- (void)displayIndex:(unsigned)idx{
}
   
@end
