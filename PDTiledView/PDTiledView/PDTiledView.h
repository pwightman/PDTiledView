
//  PDTiledView.h   PDTiledView
//  Created by Parker Wightman on 12/12/12.  Copyright (c) 2012 Parker Wightman Inc. All rights reserved.

#if !TARGET_OS_IPHONE
#import <Cocoa/Cocoa,h>
#define       UIView NSView
#define    UIControl NSControl
#define UIScrollView NSScrollView
#else
#import <UIKit/UIKit.h>
#endif

typedef        struct    _PDIndexPath{NSInteger section; NSInteger tile; } PDIndexPath;
CG_INLINE PDIndexPath PDIndexPathMake(NSInteger section, NSInteger tile) { return (PDIndexPath){section,tile}; }

@interface PDTiledView : UIView @property NSInteger currentSection;

#pragma Required Blocks

@property (copy) NSInteger            (^numberOfSectionsBlock)();
@property (copy) NSInteger      (^numberOfTilesInSectionBlock)(  NSInteger   section);
@property (copy) UIControl *         (^controlForSectionBlock)(  NSInteger   ection);
@property (copy) UIControl * (^controlForTileAtIndexPathBlock)(PDIndexPath   indexPath);

/*! @note BOTH @c heightFor... blocks \"default\" to the width of THIS @c PDTiledView , and hence.. a square */

#pragma Optional Blocks

@property (copy)  CGFloat      (^heightForSectionControlBlock)();
@property (copy)  CGFloat      (^heightForTilesInSectionBlock)(  NSInteger   section);
@property (copy)     void     (^didSelectTileAtIndexPathBlock)(  UIControl * tile,         PDIndexPath indexPath);
@property (copy)     void             (^didSelectSectionBlock)(  UIControl * sectionControl, NSInteger section);
@property (copy)     void           (^willDisplaySectionBlock)(  UIControl * sectionControl, NSInteger section);
@property (copy)     void   (^willDisplayTileAtIndexPathBlock)(  UIControl * tile,         PDIndexPath indexPath);

- (void)    reloadData;
- (void) selectSection:(NSInteger)x
              animated:(BOOL)ani;
@end
