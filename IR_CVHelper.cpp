//
//  IR_CVHelper.cpp
//  EY_find
//
//  Created by Abadie, Loïc on 24/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#include "IR_CVHelper.h"
#include "cvneon.h"

void getGray(const cv::Mat& input, cv::Mat& gray){
    const int numChannes = input.channels();
    
    if (numChannes == 4){
#if TARGET_IPHONE_SIMULATOR
        cv::cvtColor(input, gray, CV_BGRA2GRAY);
#else
        cv::neon_cvtColorBGRA2GRAY(input, gray);
#endif
        
    }
    else if (numChannes == 3)
        cv::cvtColor(input, gray, CV_BGR2GRAY);
    
    else if (numChannes == 1)
        gray = input;
}