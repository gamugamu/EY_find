//
//  IR_EncoderDecoder.cpp
//  EY_find
//
//  Created by Abadie, Loïc on 26/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#include "IR_EncoderDecoder.h"

cv::Mat testEncode(cv::Mat& src){
    return src;
    printf("--- will encode ---\n");
    
    //(1) jpeg compression
    std::vector<uchar> buff;//buffer for coding
    std::vector<int> param = std::vector<int>(2);
    param[0] = CV_IMWRITE_JPEG_QUALITY;
    param[1] = 95;//default(95) 0-100
    
    imencode(".jpg", src, buff, param);
    std::cout<<"coded file size(jpg)" << buff.size() << std::endl; // fit buff size automatically.
    
    // decodage
    cv::Mat jpegimage = imdecode(cv::Mat(buff), CV_LOAD_IMAGE_COLOR);
    return jpegimage;
}