//
//  EYRecognizerDelegate.h
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import <Foundation/Foundation.h>

// Informe le client lorsqu'une image a été detectée. Permet également de controller
// si le client désire encore être informé ou non. Wrapper entre la vue OpenGL
// et la librairie libIR.
@protocol EYRecognizerDelegate <NSObject>
- (void)imageFound:(unsigned)index intoView:(UIView*)cameRaView;
@end
