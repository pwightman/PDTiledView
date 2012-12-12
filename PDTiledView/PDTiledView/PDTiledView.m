//
//  PDTiledView.m
//  PDTiledView
//
//  Created by Parker Wightman on 12/12/12.
//  Copyright (c) 2012 Parker Wightman Inc. All rights reserved.
//

#import "PDTiledView.h"

@interface PDTiledView ()

@property (strong, nonatomic) NSArray *sectionControls;
@property (strong, nonatomic) UIScrollView *sectionsScrollView;
@property (strong, nonatomic) NSMutableArray *tiledScrollViews;
@property (assign, nonatomic) NSInteger currentSection;
@property (strong, nonatomic) UIScrollView *currentTiledScrollView;

@end

@implementation PDTiledView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setup];
	}
	return self;
}

- (void) setup {
	_currentSection = -1;
}

- (void) reloadData {
	NSInteger numberOfSections = _numberOfSectionsBlock();
	NSMutableArray *sectionControls = [NSMutableArray arrayWithCapacity:numberOfSections];
	NSMutableArray *tiledScrollViews = [NSMutableArray arrayWithCapacity:numberOfSections];
	
	for (NSInteger i = 0; i < numberOfSections; i++) {
		[tiledScrollViews addObject:[NSNull null]];
	}
	
	_tiledScrollViews = tiledScrollViews;
	_sectionsScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
	
	CGRect scrollViewFrame = self.bounds;
	scrollViewFrame.size.height = numberOfSections * scrollViewFrame.size.width;
	
	CGSize size = self.bounds.size;
	_sectionsScrollView.contentSize = size;
	
	_sectionsScrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	[self addSubview:_sectionsScrollView];
	
	
	for (NSInteger i = 0; i < numberOfSections; i++) {
		UIControl *sectionControl = _controlForSectionBlock(i);
		
		CGFloat height = (_heightForSectionControlBlock ? _heightForSectionControlBlock() : self.frame.size.width);
		
		CGRect frame = CGRectZero;
		frame.size.width = self.frame.size.width;
		frame.size.height = height;
		frame.origin.y = i*frame.size.height;
		sectionControl.frame = frame;
		
		[sectionControl addTarget:self action:@selector(sectionTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		if (_willDisplaySectionBlock) {
			_willDisplaySectionBlock(sectionControl, i);
		}
		
		[_sectionsScrollView addSubview:sectionControl];
		[sectionControls addObject:sectionControl];
	}
	
	_sectionControls = sectionControls;
	[self setNeedsDisplay];
}

- (void) selectSection:(NSInteger)section animated:(BOOL)animated {
	if (section < 0 || section >= _sectionControls.count) {
		@throw [NSString stringWithFormat:@"PDTiledView: selectSection:animated: was passed section = %d"
				"must be in the range %d - %d.", section, 0, _sectionControls.count - 1];
	}
	
	if (section == _currentSection) {
		return;
	}
	
	if (_didSelectSectionBlock) {
		_didSelectSectionBlock([_sectionControls objectAtIndex:section], section);
	}
	
	
	CGFloat animationDuration = (animated ? 0.2 : 0);
	
	CGRect selectedSectionFrame = [[_sectionControls objectAtIndex:section] frame];
	
	// Animate section controls to their proper positions
	for (NSInteger i = 0; i < _sectionControls.count; i++) {
		UIControl *sectionControl = [_sectionControls objectAtIndex:i];
		CGRect newFrame = sectionControl.frame;
		
		if (i <= section) {
			newFrame.origin.y = i*sectionControl.frame.size.height;
		} else {
			newFrame.origin.y = _sectionsScrollView.contentSize.height - (_sectionControls.count - i)*sectionControl.frame.size.height;
		}
		
		[UIView animateWithDuration:animationDuration animations:^{
			sectionControl.frame = newFrame;
		}];
	}
	
	// Create tiledScrollView if it doesn't already exist to leverage some caching
	UIScrollView *tiledScrollView = nil;
	if ( !(tiledScrollView = [self tiledScrollViewForSection:section]) ) {
		tiledScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
		// TEMP
		tiledScrollView.backgroundColor = [UIColor yellowColor];
		CGSize contentSize = _sectionsScrollView.frame.size;
		
		CGFloat tileHeight = (_heightForTilesInSectionBlock ?
							_heightForTilesInSectionBlock(section) :
							_sectionsScrollView.frame.size.width);
		
		NSInteger numberOfTiles = _numberOfTilesInSectionBlock(section);
		
		contentSize.height = numberOfTiles*tileHeight;
		tiledScrollView.contentSize = contentSize;
		
		for (NSInteger i = 0; i < numberOfTiles; i++) {
			UIControl *control = _controlForIndexPathBlock(PDIndexPathMake(section, i));
			
			
			CGRect frame = CGRectZero;
			frame.size.width = _sectionsScrollView.frame.size.width;
			frame.size.height = tileHeight;
			frame.origin.y = i*frame.size.height;
			control.frame = frame;
			
			[control addTarget:self action:@selector(tiledTapped:) forControlEvents:UIControlEventTouchUpInside];
			
			if (_willDisplayTileAtIndexPathBlock) {
				_willDisplayTileAtIndexPathBlock(control, PDIndexPathMake(section, i));
			}
			[tiledScrollView addSubview:control];
		}
		
		[self setTiledScrollView:tiledScrollView forSection:section];
	}
	
	if (_currentTiledScrollView) {
		UIScrollView *scrollView = _currentTiledScrollView;
		CGRect currentFrame = scrollView.frame;
		if (section <= _currentSection) {
			currentFrame.origin.y += currentFrame.size.height;
		}
		currentFrame.size.height = 0;
		[UIView animateWithDuration:animationDuration
						 animations:^{
							 scrollView.frame = currentFrame;
						 } completion:^(BOOL finished) {
							 [scrollView removeFromSuperview];
						 }];
		
	}
	
	_currentTiledScrollView = tiledScrollView;
	
	CGRect tiledScrollViewFrame = CGRectZero;
	tiledScrollViewFrame.origin.y = selectedSectionFrame.origin.y + selectedSectionFrame.size.height;
	tiledScrollViewFrame.size.width = _sectionsScrollView.frame.size.width;
	
	tiledScrollView.frame = tiledScrollViewFrame;
	
	[_sectionsScrollView addSubview:tiledScrollView];
	[_sectionsScrollView sendSubviewToBack:tiledScrollView];
	
	tiledScrollViewFrame.origin.y = (section + 1) * selectedSectionFrame.size.height;
	tiledScrollViewFrame.size.height = _sectionsScrollView.frame.size.height - _sectionControls.count*selectedSectionFrame.size.height;
	
	[UIView animateWithDuration:0.2 animations:^{
		tiledScrollView.frame = tiledScrollViewFrame;
	}];
	
	_currentSection = section;
}

- (void) sectionTapped:(UIControl *)sectionControl {
	[self selectSection:[self sectionForSectionControl:sectionControl] animated:YES];
}
- (void) tiledTapped:(UIControl *)sectionControl {
	if (_didSelectTileAtIndexPathBlock) {
		UIScrollView *tiledScrollView = [self tiledScrollViewForSection:_currentSection];
		for (NSInteger i = 0; i < tiledScrollView.subviews.count; i++) {
			UIControl *control = [tiledScrollView.subviews objectAtIndex:i];
			if (sectionControl == control) {
				_didSelectTileAtIndexPathBlock(sectionControl, PDIndexPathMake(_currentSection, i));
			}
		}
	}
}

- (NSInteger)sectionForSectionControl:(UIControl *)sectionControl {
	for (NSInteger i = 0; i < _sectionControls.count; i++) {
		if ([_sectionControls objectAtIndex:i] == sectionControl) {
			return i;
		}
	}
	
	return NSNotFound;
}

- (UIScrollView *)tiledScrollViewForSection:(NSInteger)section {
	id scrollView = [_tiledScrollViews objectAtIndex:section];
	return ( scrollView == [NSNull null] ? nil : scrollView );
}

- (void) setTiledScrollView:(UIScrollView *)scrollVew forSection:(NSInteger)section {
	[_tiledScrollViews replaceObjectAtIndex:section withObject:scrollVew];
}

@end

