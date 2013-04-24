//
//  AVtoCVImageWrapper.h
//  EY_find
//
//  Created by Abadie, Loïc on 24/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#ifndef __EY_find__AVtoCVImageWrapper__
#define __EY_find__AVtoCVImageWrapper__

#include "AVFrameRep.h"

const cv::Mat imageFromAVRepresentation(const frameCaptured* rep);
#endif
