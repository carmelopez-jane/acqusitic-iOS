/***************************************************************************
  
LinearLayoutView.h
LinearLayoutView
Version 1.0

Copyright (c) 2013 Charles Scalesse.
 
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
***************************************************************************/


#import <UIKit/UIKit.h>

@class LinearLayoutItem;

typedef enum {
    LinearLayoutViewOrientationVertical,
    LinearLayoutViewOrientationHorizontal
} LinearLayoutViewOrientation;

IB_DESIGNABLE
@interface LinearLayoutView : UIScrollView

@property (nonatomic, readonly) NSMutableArray *items;
@property (nonatomic, assign) LinearLayoutViewOrientation orientation;
@property (nonatomic, readonly) CGFloat layoutOffset;       // Iterates through the existing layout items and returns the current offset.
@property (nonatomic, assign) BOOL autoAdjustFrameSize;     // Updates the frame size as items are added/removed. Default is NO.
@property (nonatomic, assign) BOOL autoAdjustContentSize;   // Updates the contentView as items are added/removed. Default is YES.

- (void)addItem:(LinearLayoutItem *)linearLayoutItem;
- (void)removeItem:(LinearLayoutItem *)linearLayoutItem;
- (void)removeAllItems;

- (void)insertItem:(LinearLayoutItem *)newItem beforeItem:(LinearLayoutItem *)existingItem;
- (void)insertItem:(LinearLayoutItem *)newItem afterItem:(LinearLayoutItem *)existingItem;
- (void)insertItem:(LinearLayoutItem *)newItem atIndex:(NSUInteger)index;

- (void)moveItem:(LinearLayoutItem *)movingItem beforeItem:(LinearLayoutItem *)existingItem;
- (void)moveItem:(LinearLayoutItem *)movingItem afterItem:(LinearLayoutItem *)existingItem;
- (void)moveItem:(LinearLayoutItem *)movingItem toIndex:(NSUInteger)index;

- (void)swapItem:(LinearLayoutItem *)firstItem withItem:(LinearLayoutItem *)secondItem;

@end


typedef enum {
    LinearLayoutItemFillModeNormal,   // Respects the view's frame size
    LinearLayoutItemFillModeStretch   // Adjusts the frame to fill the linear layout view
} LinearLayoutItemFillMode;

typedef enum {
    LinearLayoutItemHorizontalAlignmentLeft,
    LinearLayoutItemHorizontalAlignmentRight,
    LinearLayoutItemHorizontalAlignmentCenter
} LinearLayoutItemHorizontalAlignment;

typedef enum {
    LinearLayoutItemVerticalAlignmentTop,
    LinearLayoutItemVerticalAlignmentBottom,
    LinearLayoutItemVerticalAlignmentCenter
} LinearLayoutItemVerticalAlignment;      

typedef struct {
    CGFloat top;
    CGFloat left;
    CGFloat bottom;
    CGFloat right;
} LinearLayoutItemPadding;

@interface LinearLayoutItem : NSObject

@property (nonatomic, strong) UIView *view;
@property (nonatomic, assign) LinearLayoutItemFillMode fillMode;
@property (nonatomic, assign) LinearLayoutItemHorizontalAlignment horizontalAlignment;    // Use horizontalAlignment when the layout view is set to VERTICAL orientation
@property (nonatomic, assign) LinearLayoutItemVerticalAlignment verticalAlignment;        // Use verticalAlignment when the layout view is set to HORIZONTAL orientation
@property (nonatomic, assign) LinearLayoutItemPadding padding;
@property (nonatomic, assign) NSDictionary *userInfo;
@property (nonatomic, assign) NSInteger tag;

- (id)initWithView:(UIView *)aView;
+ (LinearLayoutItem *)layoutItemForView:(UIView *)aView;

LinearLayoutItemPadding LinearLayoutMakePadding(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);

@end



