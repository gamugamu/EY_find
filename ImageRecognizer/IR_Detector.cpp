//
//  ImageRecognizer.cpp
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#include "IR_Detector.h"
#include "IR_CVHelper.h"

#include <mach/mach.h>
#include <mach/mach_time.h>

const int IR_ImageNotFound = -1;

// retourne seulement les points de similarités les plus proches.
cv::vector<cv::DMatch> neirestNeighboor(cv::vector<cv::vector<cv::DMatch> > matches);

// retourne si oui on non, on  a retrouvé une similitude dans la banque d'images.
// match - les points calculés par neirestNeighboor();
// idx - renvoie l'idx de l'image, IR_ImageNotFound si rien n'a été trouvé.
static void didFoundReferer(cv::vector<cv::DMatch > &match, unsigned* idx, unsigned cummulAndValidate);

// trie les similarités et enlève les similarités dupliquées. (certains "matches"
// pointent sur les mêmes données. Ca ne nous interesse pas.
static void sortMatch(cv::vector<cv::DMatch > &match);

// aide pour le tri du tableau des similarités.
static bool sortImgByIdx(const cv::DMatch& d1, const cv::DMatch& d2);

// aide pour calculer la région d'intérêt (ROI) lors du calcul des images.
cv::Rect computeROI(unsigned width, unsigned height);

double subtractTimes( uint64_t endTime, uint64_t startTime ){
    uint64_t difference = endTime - startTime;
    static double conversion = 0.0;
    
    if( conversion == 0.0 )
    {
        mach_timebase_info_data_t info;
        kern_return_t err = mach_timebase_info( &info );
        
        //Convert the timebase into seconds
        if( err == 0  )
            conversion = 1e-9 * (double) info.numer / (double) info.denom;
    }
    
    return conversion * (double) difference;
}

#pragma mark -------------------------- public ---------------------------------
#pragma mark -------------------------------------------------------------------

IR_Detector::IR_Detector(unsigned width,
                         unsigned height,
                         IR_CallBack imageFound,
                         bool shouldDegrad):cummulBeforeValidate(shouldDegrad? 0 : 1){
    // Note: En mode dégradé, on ne fait pas de cummulation de validations
    assert(imageFound);    // le callBack doit être implémenté.
    isDegraded      = shouldDegrad;

    matcher         = new cv::BFMatcher(cv::NORM_L2, false);
    detector        = new cv::OrbFeatureDetector(KMax_feature);
    extractor       = new cv::OrbDescriptorExtractor;
    roi             = computeROI(width, height);
    shouldProcess   = true;
    _imageFound     = imageFound;
 }

bool IR_Detector::processFrame(const cv::Mat& inputFrame){
    if(!shouldProcess)
        return false;
    
    shouldProcess   = false;
    
    // pour la détection, l'image doit être en noir et blanc
    // on rétrécit la zone de l'image afin de réduire les calculs.
    // Les bords et les côtés ne nous interessent pas.
    getGray(inputFrame, grayImage);
    //grayImage = grayImage(roi);
    printf("-----------\n");

    uint64_t now    = mach_absolute_time();
    detector->detect(grayImage, objectKeypoints);
    printf("(1)- described --- %lf\n", subtractTimes(mach_absolute_time(), now));

    // on récupère la description de l'image cliente.
    cv::Mat descriptors_1;
    now    = mach_absolute_time();
    extractor->compute(grayImage, objectKeypoints, descriptors_1);
    printf("(2)- compute --- %lf\n", subtractTimes(mach_absolute_time(), now));

    // l'image doit être en 32 bit, sinon l'algorythme plante.
    if(descriptors_1.type() != CV_32F)
        descriptors_1.convertTo(descriptors_1, CV_32F);
    
    // on récupère les couples.
    now    = mach_absolute_time();
    cv::vector<cv::vector<cv::DMatch> > matches;
    matcher->knnMatch(descriptors_1, matches, 2);
    printf("(3)- extract --- %lf\n", subtractTimes(mach_absolute_time(), now));

    now    = mach_absolute_time();
    // mais cette detection ne suffit pas, on ne récupère que les bons couples.
    cv::vector< cv::DMatch > good_matches;
    good_matches = neirestNeighboor(matches);
        
    uint idx;

    // cette fonction me permet de determiner si oui ou non, on a retrouvé une
    // image. Nous renvoie l'id de l'image, en cas de réussite.
    didFoundReferer(good_matches, &idx, cummulBeforeValidate);
    printf("(4)- found --- %lf\n", subtractTimes(mach_absolute_time(), now));

    if(idx != IR_ImageNotFound)
        // note: je ne teste pas si le pointer de la fonction est à NULL ou pas.
        // quoi qu'il arrive, ce callBack doit être implémenté.
        _imageFound(idx);
    
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
    printf("---- calcul d'image %u\n", cummulBeforeValidate);
    
    std::vector<cv::KeyPoint> refererKeypoints;
    
    getGray(inputFrame, grayReferer);
    /*
    cv::Mat mask        = cv::Mat::zeros(grayImage.size(), CV_8UC1);
    cv::Size size       = grayReferer.size();
    cv::Size smallSize;
    smallSize.width     = size.width/2;
    smallSize.height    = size.height/2;
    
    cv::resize(grayReferer, grayReferer, smallSize);
    printf("size %u %u\n", grayReferer.size().width, grayReferer.size().height);
    */
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

void IR_Detector::setup(){
}

static void didFoundReferer(cv::vector<cv::DMatch > &match,
                            unsigned* idx,
                            unsigned cummulAndValidate){
    sortMatch(match);

    static unsigned cummulationD;
    static unsigned idxFound;
    
    unsigned counter    = 0;
    int idxRef          = -1;
    int cmpIdx          = -1;
    unsigned cmpctr     = 0;

    printf("-------\n");
    for (int i = 0; i < match.size(); i++) {
        printf("-----R [distance %f], Image: %u Query: %u Train: %u\n", match[i].distance, match[i].imgIdx, match[i].queryIdx, match[i].trainIdx);
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

    int result;
    if(!cummulAndValidate)
        // en mode dégradé, il n'y a pas de test de false positive.
        result = cmpctr >= NBOFVALIDMATCH? cmpIdx : IR_ImageNotFound;
    else{
        // si on trouve n similarité à la suite, alors on est sur d'avoir reconnue
        // une image. Ce test permet d'ignorer les "bruits" des "false-positives".
        // 2 falses-positives à la suite est presque improbable.
        
        // si on retrouve X bonnes réponses identiques alors l'image "est" retrouvée.
        // mais on pousse le test plus loin afin de ne plus trouver de false-positive.
        cmpctr >= NBOFVALIDMATCH? ++cummulationD : cummulationD = 0;
        
        result = ((cummulationD > cummulAndValidate) &&
                  (idxFound == cmpIdx))? cmpIdx : IR_ImageNotFound;
    }
    printf("test %u %u - %i\n", (cummulationD >= cummulAndValidate), (idxFound == cmpIdx), result);
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
    return cv::Rect(width / 2 - Ww / 2, height / 2 - Wh / 2, Ww, Wh);
}