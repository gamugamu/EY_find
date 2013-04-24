//
//  AVtoCVImageWrapper.cpp
//  EY_find
//
//  Created by Abadie, Loïc on 24/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#include "AVtoCVImageWrapper.h"

const cv::Mat imageFromAVRepresentation(const frameCaptured* rep){
    cv::Mat frame(rep->height, rep->width, CV_8UC4, (void*)rep->baseAddress, rep->stride);
    
    if (rep->orientation == 4 /* AVCaptureVideoOrientationLandscapeLeft */)
        cv::flip(frame, frame, 0);
    
    /*
     cv::Vec4b tlPixel = frame.at<cv::Vec4b>(0,0);
     cv::Vec4b trPixel = frame.at<cv::Vec4b>(0,width - 1);
     cv::Vec4b blPixel = frame.at<cv::Vec4b>(height-1, 0);
     cv::Vec4b brPixel = frame.at<cv::Vec4b>(height-1, width - 1);
     
     
     std::cout << "TL: " << (int)tlPixel[0] << " " << (int)tlPixel[1] << " " << (int)tlPixel[2] << std::endl
     << "TR: " << (int)trPixel[0] << " " << (int)trPixel[1] << " " << (int)trPixel[2] << std::endl
     << "BL: " << (int)blPixel[0] << " " << (int)blPixel[1] << " " << (int)blPixel[2] << std::endl
     << "BR: " << (int)brPixel[0] << " " << (int)brPixel[1] << " " << (int)brPixel[2] << std::endl;
     */
    
    return frame;
}