//
//  FTCustomPageContro.h
//  Nocibe
//
//  Created by Abadie, Loïc on 23/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTCustomPageControl : UIView
@property(nonatomic, assign)NSUInteger currentPage;
@property(nonatomic, assign)NSUInteger numberOfPages;
- (void)displayWithSegment:(NSString*)normalState hilighted:(NSString*)hilighted;
@end
