//
//  PDTiledView.h
//  PDTiledView
//
//  Created by Parker Wightman on 12/12/12.
//  Copyright (c) 2012 Parker Wightman Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

struct PDIndexPath {
	NSInteger section;
	NSInteger tile;
};
typedef struct PDIndexPath PDIndexPath;

CG_INLINE
PDIndexPath PDIndexPathMake(NSInteger section, NSInteger tile) {
	PDIndexPath indexPath;
	indexPath.section = section;
	indexPath.tile = tile;
	
	return indexPath;
}

@interface PDTiledView : UIView

#pragma Required Blocks
@property (strong, nonatomic) NSInteger (^numberOfSectionsBlock)();
@property (strong, nonatomic) NSInteger (^numberOfTilesInSectionBlock)(NSInteger section);
@property (strong, nonatomic) UIControl* (^controlForSectionBlock)(NSInteger section);
@property (strong, nonatomic) UIControl* (^controlForIndexPathBlock)(PDIndexPath indexPath);

#pragma Optional Blocks
// Default is the width of this PDTiledView, so it will be square
@property (strong, nonatomic) CGFloat (^heightForSectionControlBlock)();
// Default is the width of this PDTiledView, so it will be square
@property (strong, nonatomic) CGFloat (^heightForTilesInSectionBlock)(NSInteger section);

@property (strong, nonatomic) void (^didSelectTileAtIndexPathBlock)(UIControl *tile, PDIndexPath indexPath);
@property (strong, nonatomic) void (^didSelectSectionBlock)(UIControl *sectionControl, NSInteger section);
@property (strong, nonatomic) void (^willDisplaySectionBlock)(UIControl *sectionControl, NSInteger section);
@property (strong, nonatomic) void (^willDisplayTileAtIndexPathBlock)(UIControl *tile, PDIndexPath indexPath);

- (void) reloadData;
- (void) selectSection:(NSInteger)section animated:(BOOL)animated;
	
@end
