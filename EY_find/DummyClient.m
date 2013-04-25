//
//  DummyClient.m
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "DummyClient.h"

@implementation DummyClient

#pragma mark - DetectorNotifierDelegate

- (void)imageFound:(unsigned)index intoView:(UIView*)cameRaView{
    NSLog(@"found %u %p", index, cameRaView);
    UIView* dumbView = [[UIView alloc] initWithFrame: CGRectMake(0,0,30,30)];
    dumbView.backgroundColor = [UIColor yellowColor];
    [cameRaView addSubview: dumbView];
}

@end
