//
//  ImageRecognizer.h
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#ifndef __EY_find__ImageRecognizer__
#define __EY_find__ImageRecognizer__

#include "IR_Config.h"

class IR_Detector{
    public:
    IR_Detector();
    
    // à refactoriser
    virtual bool processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame);
    
    // à enlever
    void testPonyDetectCreateDescriptor(const cv::Mat& inputFrame);
    void testTrain();
    
    // Comme la detection est lente. Retourne si oui ou non, ImageRecognizer
    // est en train de faire une detection.
    bool canProceed();
    
    private:
    cv::Mat grayImage;
    
    // extractor / descriptor
    cv::BFMatcher* matcher;
    cv::OrbDescriptorExtractor* detector;
    cv::OrbFeatureDetector* extractor;
    
    std::vector<cv::KeyPoint> objectKeypoints;
    std::vector<std::vector<cv::Mat> > dbDescriptors;
    
    bool shouldProcess;
};

#endif /* defined(__EY_find__ImageRecognizer__) */
