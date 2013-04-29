//
//  ProductData.m
//  EY_find
//
//  Created by Abadie, Loïc on 29/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import "ProductData.h"

@implementation ProductData
// bouchons
+ (NSString*)imageForIndex:(unsigned)idx;{
    static NSString* allImage[] = {
        @"casque.jpg"};
    return allImage[idx];
}

+ (NSString*)urlForLabel:(unsigned)idx{
    static NSString* allUrl[] = {
        @"http://www.google.fr"};
    return allUrl[idx];

}

+ (NSString*)labelForProduct:(unsigned)idx{
    static NSString* allLabels[] = {
        @"Un casque"};
    return allLabels[idx];
}
@end
