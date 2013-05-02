//
//  FTCustomPageContro.m
//  Nocibe
//
//  Created by Abadie, Loïc on 23/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FTCustomPageControl.h"

@interface FTCustomPageControl()
@property(nonatomic, assign)UIImageView*	lastSegment;
@property(nonatomic, retain)NSString*		hilightedStateImageName;
@property(nonatomic, retain)NSString*		normalStateImageName;
@end

@implementation FTCustomPageControl
@synthesize currentPage				= _currentPage,
			numberOfPages			= _numberOfPages,
			lastSegment				= _lastSegment,
			hilightedStateImageName = _hilightedStateImageName,
			normalStateImageName	= _normalStateImageName;

#pragma mark ----------------------------------------------- public --------------------------------------------------------
#pragma mark ---------------------------------------------------------------------------------------------------------------

- (void)displayWithSegment:(NSString*)normalState hilighted:(NSString*)hilighted{
	self.normalStateImageName		= normalState;
	self.hilightedStateImageName	= hilighted;
}

#pragma mark getter / setter

- (void)setNumberOfPages:(NSUInteger)numberOfPages{
	_numberOfPages = numberOfPages;
	[self displaySegementAccordingToNumberOfPages: _numberOfPages];
	[self displayCurrentPage: 0];
}

- (void)setCurrentPage:(NSUInteger)currentPage{
	_currentPage = currentPage;
	[self displayCurrentPage: _currentPage];
}

#pragma mark - override

- (void)willMoveToSuperview:(UIView *)newSuperview{
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	if(self = [super initWithCoder: aDecoder]){
		[self displayPArentAlphalyzedButNotChildren];
	}
	return self;
}

- (void)dealloc{
	[_normalStateImageName		release];
	[_hilightedStateImageName	release];
	[super dealloc];
}

#pragma mark ----------------------------------------------- private -------------------------------------------------------
#pragma mark ---------------------------------------------------------------------------------------------------------------

- (void)displayPArentAlphalyzedButNotChildren{
	CGColorRef	sameColorHalfedValue = CGColorCreateCopyWithAlpha( self.backgroundColor.CGColor, .5f);
				self.backgroundColor = [UIColor colorWithCGColor: sameColorHalfedValue];
	CGColorRelease(sameColorHalfedValue);
}

- (void)displaySegementAccordingToNumberOfPages:(NSUInteger)numberOfPage{
	for(UIView* view in [self subviews])
		[view removeFromSuperview];
	
	const uint segmentSizeRect		= 10;
	uint defaultSpaceSegment		= 30;
	float separateSpace				= self.frame.size.width / (numberOfPage  + 1);
	float YCenterAlign				= self.frame.size.height / 2 - segmentSizeRect / 2;
	
	// si l'écart par défaut plus le nombre de segment est supérieur à la longueur du conteneur (self.width)
	// alors on repartie de manière homogène les segments.
	BOOL checkIfOverridingSelfSize = (defaultSpaceSegment * (numberOfPage + 1) + ( numberOfPage * segmentSizeRect)) >= self.frame.size.width;
	NSAutoreleasePool* pool			= [NSAutoreleasePool new];
	// PS: par défault de clarté, j'ai séparé les deux façons d'itérer les segments. Ca ne rajoute que 3 lignes de code en plus.
	if(checkIfOverridingSelfSize)
		for(int i = 0; i < numberOfPage; i++){
			UIImageView*	view					= [[[UIImageView alloc] initWithFrame: (CGRect){ separateSpace * (i + 1) - segmentSizeRect / 2, YCenterAlign, segmentSizeRect, segmentSizeRect}] autorelease ];
							view.image				= [UIImage imageNamed: _normalStateImageName];
							view.highlightedImage	= [UIImage imageNamed: _hilightedStateImageName];
							view.tag				= i + 1;
			[self addSubview: view];
		}else {
			// l'équation à l'air compliquée, mais elle ne l'est pas.
			// Pour faire simple on calcule la longueur total des segments-espacés. On sait qu'ils sont inférieur à la longueur
			// de self.width puisqu'on a effectué le contr^le précedemment.
			// Une fois cette longueur trouvée, on sait que si on centre la longueur total des segments-espacés par rapport à self.width,
			// alors on a notre point de départ pour le premier segment.
			// Une fois le premier segment placé, il suffit juste de rajouter le point suivant en additionnant l'espace entre 2 segments
			// pluss la largeur d'un segment. Et voilà, on a nos segments centrés et a intervals réguliers.
			
			uint	x	= numberOfPage;
			float	sw	= self.frame.size.width;
			float	e	= defaultSpaceSegment;
			float	sr	= segmentSizeRect;
			
			for (int i = 0;  i < numberOfPage;  i++) {
				// comme on a dit, on trouve d'abord le premier point. C'est la moitié de la somme totale de la longueur des segments
				// avec leur interval respectif moins la moitié de la largeur de self.width.
				float beginAt				= sw / 2 - ((x * sr) + (e * (x  - 1))) / 2;
				// et on caclul l'espace entre le premier et le suivant. Comme 'i' est égal à 0 à la première itération
				// notre premier point ainsi que les suivants seront toujours bien placé.
				float spaceBetweenSegment	= (e + sr) * i;
				// donc l'équation est donc l'addition du premier point pluss l'interval entre les itérations des espaces entre segments.
				float instervalX			= beginAt + spaceBetweenSegment;
				UIImageView*	view					= [[[UIImageView alloc] initWithFrame: (CGRect){instervalX, YCenterAlign, segmentSizeRect, segmentSizeRect}] autorelease];
								view.image				= [UIImage imageNamed: _normalStateImageName];
								view.highlightedImage	= [UIImage imageNamed: _hilightedStateImageName];
								view.tag				= i + 1;
				
				[self addSubview: view];
			}
		}
	
	[pool release];
}

- (void)displayCurrentPage:(NSUInteger)currentPage{
					_lastSegment.highlighted	= NO;
	UIImageView*	segment						= (UIImageView*)[self viewWithTag: currentPage + 1]; // le tag 0 correspond à self
					segment.highlighted			= YES;
					_lastSegment				= segment;
}

@end
