//
//  PopUpProducts.h
//  RecoVideo
//
//  Created by Abadie, Loïc on 29/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PopUpProductsDelegate <NSObject>
- (void)closePressed;
- (void)restorePressed;
- (void)productPressed:(NSUInteger)tag;
@end

@interface PopUpProducts : NSObject
@property(nonatomic, retain)UIView* viewToPopUp;
@property(nonatomic, assign)id<PopUpProductsDelegate> delegate;
- (void)recenterPopUpBoardTo:(CGPoint)point;
- (void)animatePopUpUnblow;
- (void)animatePopUpBlow;
- (void)cleanData;
@end
