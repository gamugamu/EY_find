//
//  PopOnDetection.m
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "PopOnDetection.h"

@interface PopOnDetection ()

@end

@implementation PopOnDetection
@synthesize eyDetector = _eyDetector;

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

- (void)imageFound:(unsigned)index intoView:(UIView*)cameRaView{
    [cameRaView addSubview: self.view];
    [self displayIndex: index];
}

- (IBAction)closeTapped:(UIButton *)sender{
    [_eyDetector reset];
    [self.view removeFromSuperview];
}

#pragma mark - lifeCycle

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewDidUnload{
    [self setIndex:nil];
    [super viewDidUnload];
}

#pragma mark - alloc / dealloc

- (void)dealloc{
    [_eyDetector release];
    [_index release];
    [super dealloc];
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

- (void)displayIndex:(unsigned)idx{
    _index.text = [NSString stringWithFormat: @"%u", idx];
}
   
@end
