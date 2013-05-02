//
//  MSImagePageControl.m
//  PTMobileStart
//
//  Created by kiabimobile on 01/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FTImagePageControl.h"

int roundValue(double x);

@interface FTImagePageControl()<UIScrollViewDelegate>
@property(nonatomic, assign)BOOL isPageControlUsed;
@property(nonatomic, retain)NSTimer* timer;
@property(nonatomic, assign)int imageflow;
@property(nonatomic, retain)UITapGestureRecognizer* tapGesture;
@property(nonatomic, retain)NSArray* imageViewList;
- (void)newPageIsDisplaying:(NSUInteger)newPage;
@end

typedef enum{
	flowtoLeft	= -1,
	flowtoRight = 1,
}flowControl;

@implementation FTImagePageControl
@synthesize scrollImages			= _scrollImages,
			timer					= _timer,
			view					= _view,
			allowAutoScrolling		= _allowAutoScrolling,
			timeInterval			= _timeInterval,
			imageViewList			= _imageViewList,
			disallowUserScrolling	= _disallowUserScrolling,
			delegate,
			tapGesture,
			currentPage,
			imageflow,
			isPageControlUsed,
			pageControl,
            leftNext,
            rightNext;

#pragma mark ----------------------------------------------- public --------------------------------------------------------
#pragma mark ---------------------------------------------------------------------------------------------------------------

#pragma mark - uiScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (!isPageControlUsed) {
		CGFloat pageWidth		= _scrollImages.frame.size.width;
		int page				= floor((_scrollImages.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		
		if(pageControl.currentPage != page){
			pageControl.currentPage = page;
            [self newPageIsDisplaying: pageControl.currentPage];
		}
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	[self stopAnimating];
	isPageControlUsed = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if(!decelerate)
		[self reMagnetScroll: scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	[self reMagnetScroll: scrollView];
	[self startAnimating: _timeInterval];
	isPageControlUsed = NO;
}

- (void)reMagnetScroll:(UIScrollView*)scrollView{
	float widthDistance = _scrollImages.contentSize.width / _imageViewList.count;
	float magnet		= roundValue(scrollView.contentOffset.x / widthDistance);
	
	[_scrollImages scrollRectToVisible: (CGRect){magnet * widthDistance, 0, widthDistance, 1} animated: YES];
}

- (void)nextPage{
	if((pageControl.currentPage + imageflow) > (pageControl.numberOfPages - 1) || (pageControl.currentPage + imageflow) < 0.f)
		imageflow *= -1;
	
	uint nextStep = pageControl.currentPage + imageflow;

	[self flowToPage: nextStep];
}

- (void)flowToPage:(NSUInteger)idx{
	if(idx < _imageViewList.count){
		isPageControlUsed		= YES;
		CGRect frame			= _scrollImages.frame;
		frame.origin.x			= frame.size.width * idx;
		frame.origin.y			= 0;
		pageControl.currentPage = idx;

		[_scrollImages scrollRectToVisible: frame animated: YES];
		[self newPageIsDisplaying: pageControl.currentPage];
	}
}

#pragma mark - display

- (void)setSegmentImageName:(NSString*)imageName andHilightedImageName:(NSString*)hilightedImageName{
	if([pageControl respondsToSelector: @selector(displayWithSegment:hilighted:)])
		[pageControl displayWithSegment: imageName hilighted: hilightedImageName];
}

#pragma mark - push / pop

- (void)pushImageView:(UIImageView*)imageView{
	NSArray* imageList;
	
	// possible que le tableau soit vide lors de cet appel.
	if(_imageViewList)
		imageList = [_imageViewList arrayByAddingObject: imageView];
	else
		imageList = [NSArray arrayWithObject: imageView];
	
	[self computeScrollSizeForImages: imageList];
	[self computePageControl: imageList.count];
	
	if(imageList.count)
		[self flowToPage: imageList.count - 1];
}

- (NSInteger)popImageViewAtIndex:(NSUInteger)idx{
	return 0;
}

- (void)removeAllImage{
	[self computeScrollSizeForImages: [NSArray array]];
	[self computePageControl: 0];
}

#pragma mark - action button

- (IBAction)rightPressed:(UIButton *)sender{
	[self goNext];
}

- (IBAction)leftPressed:(UIButton *)sender{
	[self goBack];
}

#pragma mark - getter / setter

- (NSUInteger)currentPage{
	return pageControl.currentPage;
}

- (UIImageView*)currentImageDisplayed{
	return [_imageViewList objectAtIndex: pageControl.currentPage];
}

- (void)setAllowAutoScrolling:(BOOL)allowAutoScrolling{
	
}

- (void)setTimeInterval:(float)timeInterval{
	_allowAutoScrolling = timeInterval < 0;
	_timeInterval		= timeInterval;
}

- (void)setDisallowUserScrolling:(BOOL)disallowUserScrolling{
	_scrollImages.scrollEnabled = !disallowUserScrolling;
	_disallowUserScrolling = disallowUserScrolling;
}

#define recenterToScroll(size, sizeRef)\
(size < sizeRef)? sizeRef / 2 - size / 2 : 0

- (void)setPageImages:(NSArray*)images withNormalSegmentStateImageName:(NSString*)imageName HilightedSegmentImageBName:(NSString*)hilightedImageName{
	[self computePageControlForImages: images withSegmentImageName: imageName hilightedSegmentImageName: hilightedImageName];
	[self computeScrollSizeForImages: images];
	[self computePageControl: images.count];
	[self newPageIsDisplaying: 0];
}

#pragma mark - animation

- (void)stopAnimating{
	pageControl.currentPage = 0;
	imageflow				= flowtoRight;
	[_timer invalidate];
}

- (void)startAnimating:(float)interval{
	self.timeInterval	= interval;

	if(_allowAutoScrolling){
		[_timer invalidate];
		self.timer		= [NSTimer scheduledTimerWithTimeInterval: _timeInterval
													   target: self
													 selector: @selector(nextPage) 
													 userInfo: nil 
													  repeats: YES];
	}
}

- (void)restartAtZero{
	pageControl.currentPage = 0;
	imageflow				= flowtoRight;
	CGRect frame			= _scrollImages.frame;
	frame.origin.x			= 0;
	[_scrollImages scrollRectToVisible: frame animated: YES];
}

- (void)goNext{
	imageflow = flowtoRight;
	[self startAnimating: _timeInterval];
	[self nextPage];
}

- (void)goBack{
	imageflow = flowtoLeft;
	[self startAnimating: _timeInterval];
	[self nextPage];
}
#pragma mark - touch

- (void)setActionSingleTap:(UIViewController*)controller forAction:(SEL)selector{
	// permet la detection d'un touch event. Renvoyer au vue controller de la vue
	UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget: controller action: selector];
	tap.numberOfTapsRequired	= 1;
	tap.numberOfTouchesRequired = 1;
	[_scrollImages addGestureRecognizer:tap];
	[tap release];
}

#pragma mark - alloc / dealloc

- (id)init{
	if(self = [super init]){
		UIScrollView* scroll	= [[UIScrollView alloc] init];
		imageflow				= flowtoRight;
		[self setScrollImages: scroll];
		[self setUpScrollImage];
		[scroll release];
	}
	return self;
}

- (void)dealloc {
	[_timer			release];
	[_scrollImages	release];
	[_view			release];
	[_imageViewList release];
	[pageControl	release];
	[super dealloc];
}

#pragma mark ----------------------------------------------- private -------------------------------------------------------
#pragma mark ---------------------------------------------------------------------------------------------------------------

#pragma mark - setUp

- (void)setUpScrollImage{
    NSLog(@"get --Scroll %@", _scrollImages);
	_scrollImages.pagingEnabled						= YES;
	_scrollImages.scrollEnabled						= YES;
	_scrollImages.delegate							= self;
	_scrollImages.showsHorizontalScrollIndicator	= NO;
	_scrollImages.showsVerticalScrollIndicator		= NO;
	_scrollImages.directionalLockEnabled			= YES;
	_scrollImages.bounces							= NO;
	_scrollImages.alwaysBounceHorizontal			= YES;	
}

- (void)newPageIsDisplaying:(NSUInteger)newPage{
	rightNext.hidden	= pageControl.numberOfPages < 1 || newPage == pageControl.numberOfPages - 1;
	leftNext.hidden		= !newPage;
    NSLog(@"get current page %u", newPage);
	[delegate newImageIsDisplaying: newPage];
}

#pragma mark - setUp

- (void)computeScrollSizeForImages:(NSArray*)images{
	NSUInteger totalImage	= images.count;
    CGSize scrollSize       = _scrollImages.frame.size;
	self.imageViewList		= images;
	
    for (int i = 0; i < totalImage; i++) {
		UIView *subview     = [images objectAtIndex: i];
		CGRect frame        = subview.frame;
        CGSize frameSize    = frame.size;
		frame.origin.x      = _scrollImages.frame.size.width * i + (recenterToScroll(frameSize.width, scrollSize.width));   // on recentre par défault l'image
		frame.origin.y      = recenterToScroll(frameSize.height, scrollSize.height);                                        // on recentre par défault l'image
		subview.frame       = frame;
		[_scrollImages addSubview: subview];
	}
	
	_scrollImages.contentSize	= CGSizeMake(_scrollImages.frame.size.width * totalImage, _scrollImages.frame.size.height);
}

- (void)computePageControlForImages:(NSArray*)images withSegmentImageName:(NSString*)imageName hilightedSegmentImageName:(NSString*)hilightedImageName{	
	if([pageControl respondsToSelector: @selector(displayWithSegment:hilighted:)])
		[pageControl displayWithSegment: imageName hilighted: hilightedImageName];
	
	if(!pageControl)
		// strategie. Elles implémente toutes les deux les mêmes méthodes utilisées ici. Donc c'est ok.
		self.pageControl = (FTCustomPageControl*)[[UIPageControl new] autorelease];
}

- (void)computePageControl:(NSUInteger)totalImage{
	pageControl.numberOfPages	= totalImage;
	pageControl.currentPage		= 0;
	imageflow					= flowtoRight;
}

#pragma mark - mathHelper

int roundValue(double x) {
	return (int)(x + 0.5);
}
@end
