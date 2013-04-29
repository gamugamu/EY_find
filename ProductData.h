
//
//  ProductData.h
//  EY_find
//
//  Created by Abadie, Loïc on 29/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductData : NSObject
+ (NSString*)imageForIndex:(unsigned)idx;
+ (NSString*)urlForLabel:(unsigned)idx;
+ (NSString*)labelForProduct:(unsigned)idx;
@end
