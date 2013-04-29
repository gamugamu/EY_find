//
//  PopUpProducts.m
//  RecoVideo
//
//  Created by Abadie, Loïc on 29/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PopUpProducts.h"
#import "FTImagePageControl.h"

@interface PopUpProducts(){
	FTImagePageControl* _pageControl;
	NSMutableSet* _setOfTags;
}

@property(nonatomic, assign)UIView* willPopUnpopView;
@property(nonatomic, assign)UIView* snapShotHelper;
@end

#ifdef NOCIBE_RECO_SUPPORT
static NSMutableSet* onlyOnePerVid = nil;
#endif

@implementation PopUpProducts
@synthesize viewToPopUp         = _viewToPopUp,
			delegate            = _delegate,
            willPopUnpopView    = _willPopUnpopView,
            snapShotHelper      = _snapShotHelper;

#pragma mark ----------------------------------------------- public --------------------------------------------------------
#pragma mark ---------------------------------------------------------------------------------------------------------------

#pragma mark - getter / setter

- (void)setViewToPopUp:(UIView *)viewToPopUp{
	if(_viewToPopUp != viewToPopUp){
		[_viewToPopUp autorelease];
		_viewToPopUp = [viewToPopUp retain];
		[_viewToPopUp addSubview: _pageControl.view];
	}
}

#pragma mark - display

- (void)recenterPopUpBoardTo:(CGPoint)point{
	_pageControl.view.center = point;
}

#pragma mark MSOverlay delegate

- (void)scanDidFound{
	/*if(![_setOfTags containsObject: value]){
		[_setOfTags addObject: value];
		NSUInteger idx          = 0;
        NSString* imageName     = [ScanTagToRepresentation imageForTag: value assignedTag: &idx];
		UIImage* image          = [UIImage imageNamed: imageName];

#ifdef NOCIBE_RECO_SUPPORT
      
        if(!onlyOnePerVid)
            onlyOnePerVid = [[NSMutableSet new] retain];
        
        if(![onlyOnePerVid containsObject: imageName])
            [onlyOnePerVid addObject: imageName];
        else
            return;
#endif
        
		if(image){
			UIImageView* imageView	= [[[UIImageView alloc] initWithImage: image] autorelease];
			imageView.tag			= idx;
			[_pageControl pushImageView: imageView];
		}
		
		if(_willPopUnpopView.hidden)
			[self animatePopUpBlow];
	}*/
}

- (void)preparePopUpForBlow{
	_willPopUnpopView.alpha		= 0;
	[_pageControl.view setTransform: CGAffineTransformScale(_pageControl.view.transform, .9f, .9f)];
	_willPopUnpopView.hidden	= NO;
}

- (void)animatePopUpUnblow{
	[UIView animateWithDuration: .2f
					 animations:^{
						 _willPopUnpopView.alpha	= 0;
                         _snapShotHelper.alpha      = 1;
						 [_pageControl.view setTransform: CGAffineTransformScale(_pageControl.view.transform, .9f, .9f)];
					 } completion:^(BOOL finished) {
						 [_pageControl.view setTransform: CGAffineTransformScale(_pageControl.view.transform, 1, 1)];
						 _willPopUnpopView.hidden  = YES;
						 [_pageControl removeAllImage];
#ifdef NOCIBE_RECO_SUPPORT
                         [onlyOnePerVid removeAllObjects];
#endif
					 }];
}

- (void)animatePopUpBlow{
	[self preparePopUpForBlow];
	[UIView animateWithDuration: .5f
					 animations:^{
						 _willPopUnpopView.alpha		= 1;
                         _snapShotHelper.alpha          = 0;
						 [_pageControl.view setTransform: CGAffineTransformScale(_pageControl.view.transform, 1, 1)];
					 } completion:^(BOOL finished) {
					 }];
}


- (void)rotatePopUp:(double)radian{
	if(!_willPopUnpopView.hidden){
		[UIView animateWithDuration: .4f
						 animations:^{
							 CGAffineTransform rotate		= CGAffineTransformMakeRotation(radian);
							 _pageControl.view.transform	= rotate;
						 } completion:^(BOOL finished) {
						 }];
	}
	else{
		CGAffineTransform rotate        = CGAffineTransformMakeRotation(radian);
		_pageControl.view.transform     = rotate;
	}
}

typedef enum{
	popUpDown,
	popUpRight,
	popUpUp,
	popUpLeft
}popUpOrientation;

static double convertAngleToRadian(popUpOrientation orientation){
	switch (orientation) {
		case popUpDown:
			return 0.0;
		case popUpRight:
			return M_PI_2 + M_PI;
		case popUpUp:
			return M_PI;
		case popUpLeft:
			return M_PI_2;
	}
}

- (void)cleanData{
	[_setOfTags removeAllObjects];
}

#pragma mark - alloc / deallloc

- (id)init{
	if(self = [super init]){
		_setOfTags = [NSMutableSet new];
		[self setUpPageLoader];
		[self registerToNotification];
	}
	return self;
}

- (void)dealloc{
	[_setOfTags		release];
	[_viewToPopUp	release];
	[_pageControl	release];
	[super dealloc];
}

#pragma mark ----------------------------------------------- private -------------------------------------------------------
#pragma mark ---------------------------------------------------------------------------------------------------------------

#pragma mark - notification

- (void)registerToNotification{
	// note ne sera jms relaché. Trouvé un autre pattern si cette classe est utilisée ailleurs
#warning potentiel leaks
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(changeOrientation:) name: UIDeviceOrientationDidChangeNotification object: nil];
   	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(displaySnapshoot) name: @"MDScanAppeared" object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(unDisplaySnapShoot) name: @"MDScanDisAppeared" object: nil];
}

#pragma  mark - observer

- (void)changeOrientation:(NSNotification*)notification{
	UIDevice* device = [notification object];
	
	UIDeviceOrientation orientation = device.orientation;
	switch (orientation) {
		case UIDeviceOrientationLandscapeLeft:
			[self rotatePopUp: convertAngleToRadian(popUpLeft)];
			break;
		
		case UIDeviceOrientationLandscapeRight:
			[self rotatePopUp: convertAngleToRadian(popUpRight)];
			break;
		
		case UIDeviceOrientationPortrait:
			[self rotatePopUp: convertAngleToRadian(popUpDown)];
			break;
			
		case UIDeviceOrientationPortraitUpsideDown:
			[self rotatePopUp: convertAngleToRadian(popUpUp)];
			break;
		default:break;
	}
}

#pragma mark - display

- (void)displaySnapshoot{
    _snapShotHelper.hidden = NO;
    _pageControl.view .userInteractionEnabled = YES;
}

- (void)unDisplaySnapShoot{
    _snapShotHelper.hidden = YES;
    _pageControl.view .userInteractionEnabled = NO;
}

#pragma mark - actionButton

- (void)closePressed{
	[_delegate closePressed];
}

- (void)tapView{
	[_delegate productPressed: [_pageControl currentImageDisplayed].tag];
}

#pragma mark - setup

- (void)setUpPageLoader{
	UINib* loaderImagePageControl       = [UINib nibWithNibName: @"pageControlPopUp" bundle: nil];
	NSArray* list                       = [loaderImagePageControl instantiateWithOwner: self options: nil];
	
    // pas de contrôle, normalement instancié qu'une seul fois
	_pageControl						= [[list objectAtIndex: 0] retain];
	[_pageControl setSegmentImageName: @"bubleGrey.png" andHilightedImageName: @"bubleWhite.png"];
    
    self.willPopUnpopView               = [_pageControl.view viewWithTag: 17 /* le tag du placeholder */];
    self.snapShotHelper                 = [_pageControl.view viewWithTag: 16 /* le tag du snapShot */];
	_willPopUnpopView.hidden            = YES;
	_pageControl.disallowUserScrolling	= YES;
	
	UIGestureRecognizer* touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapView)];
	[[_pageControl.view viewWithTag: 15] addGestureRecognizer: touchRecognizer];
	
	UIButton* button = (UIButton*)[_pageControl.view viewWithTag: 20];
	[button addTarget: self action: @selector(closePressed) forControlEvents: UIControlEventTouchDown];
	
	[touchRecognizer release];
}

@end
