//
//  AVFrameRep.h
//  EY_find
//
//  Created by Abadie, Loïc on 24/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#ifndef EY_find_AVFrameRep_h
#define EY_find_AVFrameRep_h

struct frameCaptured{
    uint8_t *baseAddress;
    size_t width;
    size_t height;
    size_t stride;
    int /* AVCaptureVideoOrientation */ orientation;
};

#endif
