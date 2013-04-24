//
//  ImageRecognizer.h
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#ifndef __EY_find__ImageRecognizer__
#define __EY_find__ImageRecognizer__

class ImageRecognizer{
    public:
    virtual bool processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame);

    private:
};

#endif /* defined(__EY_find__ImageRecognizer__) */
