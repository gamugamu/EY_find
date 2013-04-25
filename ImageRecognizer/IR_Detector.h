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

typedef void (*IR_CallBack)(unsigned idx);

class IR_Detector{
    public:
    IR_Detector(unsigned width, unsigned height, IR_CallBack imageFound);
    
    // à refactoriser
    virtual bool processFrame(const cv::Mat& inputFrame);
    
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
    
    // permet de ne calculer qu'une zone specifique de l'image.
    cv::Rect roi;
    
    // callBack lorsqu'une image est retrouvée. Renvoie son id.
    IR_CallBack _imageFound = NULL;
    
    bool shouldProcess;
};

#endif /* defined(__EY_find__ImageRecognizer__) */