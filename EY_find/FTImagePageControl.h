//
//  MSImagePageControl.h
//  PTMobileStart
//
//  Created by kiabimobile on 01/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTCustomPageControl.h"

@protocol FTImagePageControlDelegate <NSObject>
- (void)newImageIsDisplaying:(NSUInteger)currentIdx;
@end

@interface FTImagePageControl : NSObject
/* sont implicitement private. Public à cause de interfaceBuilder */
@property(retain, nonatomic) IBOutlet UIScrollView*			scrollImages;		// simple GUI pour la nib file
@property(retain, nonatomic) IBOutlet FTCustomPageControl*	pageControl;		// simple GUI pour la nib file
@property(retain, nonatomic) IBOutlet UIView*				leftNext;           // simple GUI pour la nib file
@property(retain, nonatomic) IBOutlet UIView*				rightNext;          // simple GUI pour la nib file
- (IBAction)rightPressed:(UIButton *)sender;
- (IBAction)leftPressed:(UIButton *)sender;
/* ----- */

@property(retain, nonatomic) IBOutlet UIView* view;								// contient tout les autres vues. (scroll + FTCustomPageContrôle)
@property(nonatomic, readonly)NSUInteger currentPage;							// la page actuelle
@property(nonatomic, assign)id <FTImagePageControlDelegate> delegate;
@property(nonatomic, assign)BOOL allowAutoScrolling;
@property(nonatomic, assign)BOOL disallowUserScrolling;							// empêche l'utilisateur de scroller la scrollView.
@property(nonatomic, assign)float timeInterval;									// en settant la valeur à 0, pas d'autoscrolling, en la mettant a < 0, autoScrolling.
// insert dans la scroll view les images du tableau
- (void)setPageImages:(NSArray*)images withNormalSegmentStateImageName:(NSString*)imageName HilightedSegmentImageBName:(NSString*)hilightedImageName;
- (void)setSegmentImageName:(NSString*)imageName andHilightedImageName:(NSString*)hilightedImageName;
// rajoute une imageView dans la liste
- (void)pushImageView:(UIImageView*)imageView;
// enlève l'imageView de la liste. Renvoie l'index si l'opération c'est bien déroulé ou NSNotFound.
- (NSInteger)popImageViewAtIndex:(NSUInteger)idx;
- (void)removeAllImage;
- (UIImageView*)currentImageDisplayed;
// permet de recevoir le single tap.
- (void)setActionSingleTap:(UIViewController*)controller forAction:(SEL)selector;
// actionne le début du scroll
- (void)startAnimating:(float)interval;
// termine le scroll
- (void)stopAnimating;
- (void)restartAtZero;
- (void)goNext;
- (void)goBack;
@end
