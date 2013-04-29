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
        @"camera.png",
        @"stationMeteo.jpg",
        @"soundBlaster.jpg"};
    return allImage[idx];
}

+ (NSString*)urlForLabel:(unsigned)idx{
    static NSString* allUrl[] = {
        @"http://easy-shopping.commercedigital.fr/StarterMobile/catalogEntry.html?langId=1&ceId=216212",
        @"http://easy-shopping.commercedigital.fr/StarterMobile/catalogEntry.html?langId=1&ceId=216208",
        @"http://easy-shopping.commercedigital.fr/StarterMobile/catalogEntry.html?langId=1&ceId=216200"};
    return allUrl[idx];

}

+ (NSString*)labelForProduct:(unsigned)idx{
    static NSString* allLabels[] = {
        @"Kit Reflex Canon - EOS1000D (10MP)+18-55IS (STAB)",
        @"Station Météo LA CROSSE WM5400 J+1",
        @"Chaîne mini LG RAD114 MP3 USB"};
    return allLabels[idx];
}
@end
