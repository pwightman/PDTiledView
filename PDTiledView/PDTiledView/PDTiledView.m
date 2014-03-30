
//  PDTiledView.m  PDTiledView
//  Created by Parker Wightman on 12/12/12.  Copyright (c) 2012 Parker Wightman Inc. All rights reserved.

#import "PDTiledView.h"

@interface PDTiledView ()
@property NSMutableArray * tiledScrollViews,
                         * sectionControls;
@property   UIScrollView * sectionsScrollView,
                         * currentTiledScrollView;
@end

@implementation PDTiledView

-   (id) initWithFrame:(CGRect)f    { return self = [super initWithFrame:f] ? _currentSection = -1, self : nil; }
-   (id) initWithCoder:(NSCoder*)d  { return self = [super initWithCoder:d] ? _currentSection = -1, self : nil; }
- (void)    reloadData              {

  _sectionControls  = NSMutableArray.new;
  _tiledScrollViews = NSMutableArray.new;
	
//	for (NSInteger i = 0; i < _numberOfSectionsBlock(); i++) 

	[self addSubview:_sectionsScrollView = [UIScrollView.alloc initWithFrame:self.bounds]];
	
	CGRect scrollViewFrame          = self.bounds;
	scrollViewFrame.size.height     = _numberOfSectionsBlock() * scrollViewFrame.size.width;

	_sectionsScrollView.contentSize     = self.bounds.size;
  _sectionsScrollView.backgroundColor = UIColor.scrollViewTexturedBackgroundColor;

	for (NSInteger i = 0; i < _numberOfSectionsBlock(); i++) {

    [_tiledScrollViews addObject:NSNull.null];

		UIControl *sctnCntrl  = _controlForSectionBlock(i);
		CGFloat height        = _heightForSectionControlBlock ? _heightForSectionControlBlock()
                                                              : self.frame.size.width;
		sctnCntrl.frame       = (CGRect){0, i * height, self.frame.size.width, height};
		
		[sctnCntrl addTarget:self action:@selector(sectionTapped:) forControlEvents:UIControlEventTouchUpInside];
		
    _willDisplaySectionBlock ? _willDisplaySectionBlock(sctnCntrl, i) : nil;

		[_sectionsScrollView addSubview:sctnCntrl];
		[_sectionControls     addObject:sctnCntrl];
	}
	[self setNeedsDisplay];
}

- (void) sectionTapped:(UIControl*)sctnCntrl { [self selectSection:[self sectionForSectionControl:sctnCntrl] animated:YES]; }
- (void)   tiledTapped:(UIControl*)sctnCntrl {

	if (!_didSelectTileAtIndexPathBlock) return;   NSUInteger idx;

  if ((idx = [[self tiledScrollViewForSection:_currentSection].subviews
                     indexOfObjectIdenticalTo:sctnCntrl]) != NSNotFound) // UIScrollView *tiledScrollView = ;
    _didSelectTileAtIndexPathBlock(sctnCntrl, PDIndexPathMake(_currentSection, idx));
}
- (void) selectSection:(NSInteger)sctn
              animated:(BOOL)ani             {

	if (sctn < 0 || sctn >= _sectionControls.count) @throw [NSString stringWithFormat:@"PDTiledView: selectSection:animated: was passed section = %d must be in the range %d - %d.", sctn, 0, _sectionControls.count - 1];
	
	if (sctn == _currentSection) return;

	_didSelectSectionBlock ? _didSelectSectionBlock(_sectionControls[sctn],sctn) : nil;

	CGFloat   animationDuration = !ani ?: 0.3;
	CGRect selectedSectionFrame = [_sectionControls[sctn] frame];
	
	// Animate section controls to their proper positions  	for (NSInteger i = 0; i < _sectionControls.count; i++) {

  [_sectionControls enumerateObjectsUsingBlock:^(UIControl *sectionControl, NSUInteger i, BOOL *stop) {

		CGRect newFrame = sectionControl.frame;
		
    newFrame.origin.y = i <= sctn ? i * sectionControl.frame.size.height
                                  : _sectionsScrollView.contentSize.height - (_sectionControls.count - i) * sectionControl.frame.size.height;
		
		[UIView animateWithDuration:animationDuration animations:^{ sectionControl.frame = newFrame; }];
	}];
	
	// Create tiledScrollView if it doesn't already exist to leverage some caching
	UIScrollView *tiledScrollView; tiledScrollView = [self tiledScrollViewForSection:sctn] ?: ({

		tiledScrollView                 = [UIScrollView.alloc initWithFrame:CGRectZero];
		tiledScrollView.backgroundColor = UIColor.yellowColor; 		// TEMP
		CGSize contentSize              = _sectionsScrollView.frame.size;
		
		CGFloat tileHeight = _heightForTilesInSectionBlock ? _heightForTilesInSectionBlock(sctn)
                                                       : _sectionsScrollView.frame.size.width;

		NSInteger numberOfTiles = _numberOfTilesInSectionBlock(sctn);
		
		contentSize.height          = numberOfTiles*tileHeight;
		tiledScrollView.contentSize = contentSize;
		
		for (NSInteger i = 0; i < numberOfTiles; i++) {
			UIControl *control = _controlForTileAtIndexPathBlock(PDIndexPathMake(sctn, i));

			control.frame = (CGRect){ 0,i*tileHeight,_sectionsScrollView.frame.size.width, tileHeight};
			
			[control addTarget:self action:@selector(tiledTapped:) forControlEvents:UIControlEventTouchUpInside];
			
			if (_willDisplayTileAtIndexPathBlock) _willDisplayTileAtIndexPathBlock(control, PDIndexPathMake(sctn, i));
			[tiledScrollView addSubview:control];
		}
		
		[self setTiledScrollView:tiledScrollView forSection:sctn];
    tiledScrollView;
  });
	
	if (_currentTiledScrollView) {
		UIScrollView *scrollView = _currentTiledScrollView;
		CGRect currentFrame = scrollView.frame;
		if (sctn <= _currentSection) currentFrame.origin.y += currentFrame.size.height;
		currentFrame.size.height = 0;
		[UIView animateWithDuration:animationDuration animations:^{ scrollView.frame = currentFrame; }
                     completion:^(BOOL finished) { [scrollView removeFromSuperview]; }];
	}
	
	_currentTiledScrollView = tiledScrollView;
	
	CGRect tiledScrollViewFrame = (CGRect){ 0, selectedSectionFrame.origin.y + selectedSectionFrame.size.height,
                                            _sectionsScrollView.frame.size.width};
	
	tiledScrollView.frame = tiledScrollViewFrame;
	
	[_sectionsScrollView addSubview:tiledScrollView];
	[_sectionsScrollView sendSubviewToBack:tiledScrollView];
	
	tiledScrollViewFrame.origin.y    = (sctn + 1) * selectedSectionFrame.size.height;
	tiledScrollViewFrame.size.height = _sectionsScrollView.frame.size.height - _sectionControls.count*selectedSectionFrame.size.height;
	
	[UIView animateWithDuration:animationDuration animations:^{ tiledScrollView.frame = tiledScrollViewFrame;	}];
	
	_currentSection = sctn;
}

-     (NSInteger)  sectionForSectionControl:(UIControl*)sctnCntrl { return [_sectionControls indexOfObjectIdenticalTo:sctnCntrl]; }
- (UIScrollView*) tiledScrollViewForSection:(NSInteger)sctn       { return _tiledScrollViews[sctn] == NSNull.null ? nil : _tiledScrollViews[sctn]; }
-          (void)        setTiledScrollView:(UIScrollView*)scrllV
                                 forSection:(NSInteger)sctn       { _tiledScrollViews[sctn] = scrllV; }

@end

