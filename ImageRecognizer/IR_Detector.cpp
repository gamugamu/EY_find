//
//  ImageRecognizer.cpp
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#include "IR_Detector.h"
#include "IR_CVHelper.h"

const int IR_ImageNotFound = -1;

// retourne seulement les points de similarités les plus proches.
cv::vector<cv::DMatch> neirestNeighboor(cv::vector<cv::vector<cv::DMatch> > matches);

// retourne si oui on non, on  a retrouver une similitude dans la banque d'images.
// match - les points calculés par neirestNeighboor();
// idx - renvoie l'idx de l'image, IR_ImageNotFound si rien n'a été trouvé.
static void didFoundReferer(cv::vector<cv::DMatch > &match, unsigned* idx);

// tri les similarités et enlève les similarités dupliquées. (certains "matches"
// pointent sur les mêmes données. Ca ne nous interesse pas.
static void sortMatch(cv::vector<cv::DMatch > &match);

// helper pour le tri du tableau des similarités.
static bool sortImgByIdx(const cv::DMatch& d1, const cv::DMatch& d2);

// helper pour calucler la région d'intérêt (ROI). Lors du calcul des images.
cv::Rect computeROI(unsigned width, unsigned height);

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

IR_Detector::IR_Detector(unsigned width, unsigned height){
    matcher         = new cv::BFMatcher(cv::NORM_L2, false);
    detector        = new cv::OrbFeatureDetector(KMax_feature);
    extractor       = new cv::OrbDescriptorExtractor;
    roi             = computeROI(width, height);
    shouldProcess   = true;
}

bool IR_Detector::processFrame(const cv::Mat& inputFrame){
    if(!shouldProcess)
        return false;
    
    shouldProcess   = false;
    
    // pour la detection, l'image doit être en noir et blanc
    // on réduit l'image afin de réduir les calculs. Les bords et
    // côtés ne nous interessent pas.
    //grayImage = grayImage(roi);
    getGray(inputFrame, grayImage);
    
    detector->detect(grayImage, objectKeypoints);
    
    // on récupère la description de l'image cliente.
    cv::Mat descriptors_1;
    extractor->compute(grayImage, objectKeypoints, descriptors_1);
    
    // l'image doit être en 32 bit, sinon l'algorythme plante
    if(descriptors_1.type() != CV_32F)
        descriptors_1.convertTo(descriptors_1, CV_32F);
    
    // on récupère les couples.
    cv::vector<cv::vector<cv::DMatch> > matches;
    matcher->knnMatch(descriptors_1, matches, 2);
    
    // mais cette detection ne suffit pas, on ne récupère que les bons couples.
    cv::vector< cv::DMatch > good_matches;
    good_matches = neirestNeighboor(matches);
        
    uint idx;

    // cette fonciotn me permet de determiner si oui ou non, on a retrouvé une
    // image, et son id.
    didFoundReferer(good_matches, &idx);
    
    printf("---> %i\n", idx);
    shouldProcess = true;

    return true;
}

bool IR_Detector::canProceed(){
    return shouldProcess;
}

#warning à enlever

void IR_Detector::testPonyDetectCreateDescriptor(const cv::Mat& inputFrame){
    cv::Mat grayReferer;
    cv::Mat descriptors_referer;
    printf("---- calcul d'image\n");
    
    std::vector<cv::KeyPoint> refererKeypoints;
    
    getGray(inputFrame, grayReferer);
    
    cv::Mat mask        = cv::Mat::zeros(grayImage.size(), CV_8UC1);
    cv::Size size       = grayReferer.size();
    cv::Size smallSize;
    smallSize.width     = size.width/2;
    smallSize.height    = size.height/2;
    
    cv::resize(grayReferer, grayReferer, smallSize);
    
    // 1 detection
    detector->detect(grayReferer, refererKeypoints);
    
    // 2
    extractor->compute(grayReferer, refererKeypoints, descriptors_referer);
    
    if(descriptors_referer.type() != CV_32F)
        descriptors_referer.convertTo(descriptors_referer, CV_32F);
    
    std::vector<cv::Mat> descriptor;
    descriptor.push_back(descriptors_referer);
    
    //train with descriptors from your db
    dbDescriptors.push_back(descriptor);
    
    matcher->add(descriptor);
}

void IR_Detector::testTrain(){
    matcher->train();
}

#pragma mark -------------------------- private --------------------------------
#pragma mark -------------------------------------------------------------------

static void didFoundReferer(cv::vector<cv::DMatch > &match, unsigned* idx){
    sortMatch(match);

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
    
    // on récupère l'index d'image qui a récoltée le plus de point.
    if(cmpctr < counter){
        cmpctr = counter;
        cmpIdx = idxRef;
    }
    
    // si on retrouve X bonnes réponses identiques alors l'image "est" retrouvée.
    // mais on pousse le test plus loin afin de ne plus trouver de false-positive.
    cmpctr >= NBOFVALIDMATCH? ++cummulationD : cummulationD = 0;
    
    printf("found? %u - %u\n", cmpctr >= NBOFVALIDMATCH, cummulationD);
    
    // si on trouve 2 similarité à la suite, alors on est sur d'avoir reconnue
    // une image. Ce test permet d'ignorer les "bruits" des "false-positives".
    // 2 falses-positives à la suite est presque improbable. 
    int result = ((cummulationD > 1) && (idxFound == cmpIdx))? cmpIdx : IR_ImageNotFound;
    printf("eval same? %u || is greater %u  -- cmpIdx: %u -- %i\n", idxFound == cmpIdx, cummulationD > 1, (cummulationD > 1 && idxFound == result)? 10 : 15, result);
    
    *idx        = result;
    idxFound    = cmpIdx;
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

cv::Rect computeROI(unsigned width, unsigned height){
    float ratio         = KRATIO;
    float Ww            = width / ratio;
    float Wh            = height / ratio;
    return cv::Rect(640 / 2 - Ww / 2, 480 / 2 - Wh / 2, Ww, Wh);
}