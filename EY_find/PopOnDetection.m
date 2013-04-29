//
//  PopOnDetection.m
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "PopOnDetection.h"

@interface PopOnDetection (){
    unsigned currentIdx;
}
@property(nonatomic, retain)UIView* viewDisplayer;
@end

@implementation PopOnDetection
@synthesize eyDetector      = _eyDetector,
            viewDisplayer   = _viewDisplayer,
            scanIndexFound  = _scanIndexFound,
            goPressed       = _goPressed;

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

- (void)imageFound:(unsigned)index intoView:(UIView*)cameRaView{
    if(_scanIndexFound)
        _scanIndexFound(index, self);
    
    currentIdx = index;
}

- (void)popUpImage:(NSString*)imageName{
    _productView.image  = [UIImage imageNamed: imageName];
    [_viewDisplayer addSubview: self.view];
}

- (IBAction)closeTapped:(UIButton *)sender{
    [_eyDetector reset];
    [self.view removeFromSuperview];
}

- (IBAction)goToUrlTapped:(UIButton *)sender{
    if(_goPressed)
        _goPressed(currentIdx, self);
}

#pragma mark - lifeCycle

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewDidUnload{
    [self setProductView:nil];
    [self setDisplayer:nil];
    [self setProductDescription:nil];
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
        [self recenterPopOnCenterView: view];
    }
    return self;
}

- (void)dealloc{
    [_eyDetector            release];
    [_productView           release];
    [_displayer             release];
    [_productDescription    release];
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

- (void)recenterPopOnCenterView:(UIView*)view{
    self.view.center = view.center;
}

@end
