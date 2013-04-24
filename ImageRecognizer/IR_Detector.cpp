//
//  ImageRecognizer.cpp
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#include "IR_Detector.h"
#include "IR_CVHelper.h"

// retourne seulement les points de similarités les plus proches.
cv::vector<cv::DMatch> neirestNeighboor(cv::vector<cv::vector<cv::DMatch> > matches);

// tri les similarités et enlève les similarités dupliquées. (certains "matches"
// pointent sur les mêmes données. Ca ne nous interesse pas.
static void sortMatch(cv::vector<cv::DMatch > &match);

// helper pour le tri du tableau des similarités.
static bool sortImgByIdx(const cv::DMatch& d1, const cv::DMatch& d2);

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

IR_Detector::IR_Detector(){
    matcher         = new cv::BFMatcher(cv::NORM_L2, false);
    detector        = new cv::OrbFeatureDetector(KMax_feature);
    extractor       = new cv::OrbDescriptorExtractor;
}

bool IR_Detector::processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame){
    if(!shouldProcess)
        return false;
    
    shouldProcess   = false;
        
    // convert input frame to gray scale
    float ratio         = KRATIO;
    float Ww            = 640 / ratio;
    float Wh            = 480 / ratio;
    cv::Rect roi        = cv::Rect(640 / 2 - Ww / 2, 480 / 2 - Wh / 2, Ww, Wh);
    
    getGray(inputFrame, grayImage);
    
    grayImage = grayImage(roi);
    
    detector->detect(grayImage, objectKeypoints);
    
    // patch
    cv::Mat descriptors_1;
    
    extractor->compute(grayImage, objectKeypoints, descriptors_1);
    
    if(descriptors_1.type() != CV_32F)
        descriptors_1.convertTo(descriptors_1, CV_32F);
    
    cv::vector< cv::DMatch > good_matches;
    
    if(descriptors_1.type() != 0){
        std::map<unsigned, unsigned>map;
        cv::vector<cv::vector<cv::DMatch> > matches;
        matcher->knnMatch( descriptors_1, matches, 2);
        good_matches = neirestNeighboor(matches);
    }
        
    cv::Mat t;
    cv::cvtColor(inputFrame, t, CV_BGRA2BGR);
    cv::drawKeypoints(t, objectKeypoints, t, cv::Scalar::all(-1), cv::DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
    cv::cvtColor(t, outputFrame, CV_BGR2BGRA);
    
    sortMatch(good_matches);
    bool didRefererFound;
    uint idx;
    /*
    didFoundReferer(good_matches, &didRefererFound, &idx);
    
    if(didRefererFound){
        std::ostringstream str;
        str << "Detected: " << idx << " | " << cummulationD;
        cv::putText(outputFrame, str.str(), cv::Point(30,50), CV_FONT_HERSHEY_TRIPLEX, 1.f, CV_RGB(0,250,0));
    }
    */
    shouldProcess = true;

    return true;
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

static void didFoundReferer(cv::vector<cv::DMatch > &match, bool* isReferrerFound, unsigned* idx){
    static unsigned cummulationD;
    static unsigned idxFound;
    
    unsigned counter    = 0;
    int idxRef          = -1;
    unsigned cmpIdx     = 0;
    unsigned cmpctr     = 0;
    
    for (int i = 0; i < match.size(); i++) {
        // printf("-----R [distance %f], Image: %u Query: %u Train: %u\n", match[i].distance, match[i].imgIdx, match[i].queryIdx, match[i].trainIdx);
        if(idxRef != match[i].imgIdx){
            if(cmpctr < counter){
                cmpctr = counter;
                cmpIdx = idxRef;
            }
            counter = 0;
            idxRef  = match[i].imgIdx;
        }
        counter++;
    }
    
    // on récupère l'index d'image qui a récolté le plus de point.
    if(cmpctr < counter){
        cmpctr = counter;
        cmpIdx = idxRef;
    }
    
    // si on retrouve X bonnes réponses identiques alors l'image "est" retrouvée.
    // mais on pousse le test plus loin afin de ne plus trouver de false-positive.
    *isReferrerFound    = cmpctr >= NBOFVALIDMATCH /* X */;
    *idx                = cmpIdx;
    
    if(*isReferrerFound)
        cummulationD++;
    else
        cummulationD = 0;
    
    // si on trouve 2 similarité à la suite, alors on est sur d'avoir reconnue
    // une image. Ce test permet d'ignorer les "bruits" des "false-positives".
    // 2 falses-positives à la suite est presque improbable. 
    *isReferrerFound = cummulationD > 1 && idxFound == *idx;
    
    idxFound = *idx;
}

static void sortMatch(cv::vector<cv::DMatch > &match){
    // on trie le tableau, pour determiner plus facilement les voisins et les
    // matches similaires.
    std::sort(match.begin(), match.end(), sortImgByIdx);
    
    // ici on enlève les duplications de match. Ca ne sert à rien de conserver les
    // matches qui pointent vers les mêmes similitudes.
    cv::vector<cv::DMatch >::iterator i;
    if(match.size())
        for(i = match.begin(); i != match.end() - 1; ++i){
            if((*i).imgIdx == (*(i + 1)).imgIdx && (*i).trainIdx == (*(i + 1)).trainIdx ){
                printf("erase %u\n", i->imgIdx);
                i = match.erase(i);
                i--;
            }
        }
}

static bool sortImgByIdx(const cv::DMatch& d1, const cv::DMatch& d2){
    return d1.imgIdx < d2.imgIdx;
}

cv::vector<cv::DMatch> neirestNeighboor(cv::vector<cv::vector<cv::DMatch> > matches){
    cv::vector<cv::DMatch> good_matches;
    good_matches.reserve(matches.size());
    
    for (size_t i = 0; i < matches.size(); ++i){
        if (matches[i].size() < 2)
            continue;
        
        const cv::DMatch &m1    = matches[i][0];
        const cv::DMatch &m2    = matches[i][1];
        float nndrRatio         = RATIODETECTION;
        
        if(m1.distance <= nndrRatio * m2.distance)
            if(abs(m1.queryIdx - m1.trainIdx) < ISOIDXDIFF)
                good_matches.push_back(m1);
    }
    
    return good_matches;
}