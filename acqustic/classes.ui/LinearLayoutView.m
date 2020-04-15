//
//  LinearLayoutView.m
//  LinearLayoutView
//
//  Created by Charles Scalesse on 3/24/12.
//  Copyright (c) 2013 Charles Scalesse. All rights reserved.
//

#import "LinearLayoutView.h"

@interface LinearLayoutView()
- (void)setup;
- (void)adjustFrameSize;
- (void)adjustContentSize;
@end

@implementation LinearLayoutView

#pragma mark - Factories

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _items = [[NSMutableArray alloc] init];
    _orientation = LinearLayoutViewOrientationVertical;
    _autoAdjustFrameSize = NO;
    _autoAdjustContentSize = YES;
    self.autoresizesSubviews = NO;
}


#pragma mark - Layout

- (void)layoutSubviews {
    
    CGFloat relativePosition = 0.0;
    CGFloat absolutePosition = 0.0;
    
    for (LinearLayoutItem *item in _items) {
        
        CGFloat startPadding = 0.0;
        CGFloat endPadding = 0.0;
        
        if (self.orientation == LinearLayoutViewOrientationHorizontal) {
            
            startPadding = item.padding.left;
            endPadding = item.padding.right;
            
            if (item.verticalAlignment == LinearLayoutItemVerticalAlignmentTop || item.fillMode == LinearLayoutItemFillModeStretch) {
                absolutePosition = item.padding.top;
            } else if (item.verticalAlignment == LinearLayoutItemVerticalAlignmentBottom) {
                absolutePosition = self.frame.size.height - item.view.frame.size.height - item.padding.bottom;
            } else { // LinearLayoutItemVerticalCenter
                absolutePosition = (self.frame.size.height / 2) - ((item.view.frame.size.height + (item.padding.bottom - item.padding.top)) / 2);
            }
            
        } else {
            
            startPadding = item.padding.top;
            endPadding = item.padding.bottom;
            
            if (item.horizontalAlignment == LinearLayoutItemHorizontalAlignmentLeft || item.fillMode == LinearLayoutItemFillModeStretch) {
                absolutePosition = item.padding.left;
            } else if (item.horizontalAlignment == LinearLayoutItemHorizontalAlignmentRight) {
                absolutePosition = self.frame.size.width - item.view.frame.size.width - item.padding.right;
            } else { // LinearLayoutItemHorizontalCenter
                absolutePosition = (self.frame.size.width / 2) - ((item.view.frame.size.width + (item.padding.right - item.padding.left)) / 2);
            }
            
        }
        
        relativePosition += startPadding;
        
        CGFloat currentOffset = 0.0;
        if (self.orientation == LinearLayoutViewOrientationHorizontal) {
            
            CGFloat height = item.view.frame.size.height;
            if (item.fillMode == LinearLayoutItemFillModeStretch) {
                height = self.frame.size.height - (item.padding.top + item.padding.bottom);
            }
            
            item.view.frame = CGRectIntegral(CGRectMake(relativePosition, absolutePosition, item.view.frame.size.width, height));
            currentOffset = item.view.frame.size.width;
            
        } else {
            
            CGFloat width = item.view.frame.size.width;
            if (item.fillMode == LinearLayoutItemFillModeStretch) {
                width = self.frame.size.width - (item.padding.left + item.padding.right);
            }
            
            item.view.frame = CGRectIntegral(CGRectMake(absolutePosition, relativePosition, width, item.view.frame.size.height));
            currentOffset = item.view.frame.size.height;
            
        }
        
        relativePosition += currentOffset + endPadding;
        
    }
    
    if (_autoAdjustFrameSize == YES) {
        [self adjustFrameSize];
    }
    
    if (_autoAdjustContentSize == YES) {
        [self adjustContentSize];
    }
}

- (void)adjustFrameSize {
    if (self.orientation == LinearLayoutViewOrientationHorizontal) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.layoutOffset, self.frame.size.height);
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.layoutOffset);
    }
}

- (void)adjustContentSize {
    if (self.orientation == LinearLayoutViewOrientationHorizontal) {
        CGFloat contentWidth = MAX(self.frame.size.width, self.layoutOffset);
        self.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
    } else {
        CGFloat contentHeight = MAX(self.frame.size.height, self.layoutOffset);
        self.contentSize = CGSizeMake(self.frame.size.width, contentHeight);
    }
}

- (CGFloat)layoutOffset {
    CGFloat currentOffset = 0.0;
    
    for (LinearLayoutItem *item in _items) {
        if (_orientation == LinearLayoutViewOrientationHorizontal) {
            currentOffset += item.padding.left + item.view.frame.size.width + item.padding.right;
        } else {
            currentOffset += item.padding.top + item.view.frame.size.height + item.padding.bottom;
        }
    }
    
    return currentOffset;
}

- (void)setOrientation:(LinearLayoutViewOrientation)anOrientation {
    _orientation = anOrientation;
    [self setNeedsLayout];
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    
    if (_autoAdjustFrameSize == YES) {
        [self adjustFrameSize];
    }
    
    if (_autoAdjustContentSize == YES) {
        [self adjustContentSize];
    }
}


#pragma mark - Add, Remove, Insert, & Move

- (void)addItem:(LinearLayoutItem *)linearLayoutItem {
    if (linearLayoutItem == nil || [_items containsObject:linearLayoutItem] == YES || linearLayoutItem.view == nil) {
        return;
    }
    
    [_items addObject:linearLayoutItem];
    [self addSubview:linearLayoutItem.view];
}

- (void)removeItem:(LinearLayoutItem *)linearLayoutItem {
    if (linearLayoutItem == nil || [_items containsObject:linearLayoutItem] == NO) {
        return;
    }
    
    [linearLayoutItem.view removeFromSuperview];
    [_items removeObject:linearLayoutItem];
}

- (void)removeAllItems {
    // only remove actual items, not scrollbars
    for (LinearLayoutItem *item in self.items) {
        [item.view removeFromSuperview];
    }
    [self.items removeAllObjects];
}

- (void)insertItem:(LinearLayoutItem *)newItem beforeItem:(LinearLayoutItem *)existingItem {
    if (newItem == nil || [_items containsObject:newItem] == YES || existingItem == nil ||  [_items containsObject:existingItem] == NO) {
        return;
    }
    
    NSUInteger index = [_items indexOfObject:existingItem];
    [_items insertObject:newItem atIndex:index];
    [self addSubview:newItem.view];
}

- (void)insertItem:(LinearLayoutItem *)newItem afterItem:(LinearLayoutItem *)existingItem {
    if (newItem == nil || [_items containsObject:newItem] == YES || existingItem == nil || [_items containsObject:existingItem] == NO) {
        return;
    }
    
    if (existingItem == [_items lastObject]) {
        [_items addObject:newItem];
    } else {
        NSUInteger index = [_items indexOfObject:existingItem];
        [_items insertObject:newItem atIndex:++index];
    }
    
    [self addSubview:newItem.view];
}

- (void)insertItem:(LinearLayoutItem *)newItem atIndex:(NSUInteger)index {
    if (newItem == nil || [_items containsObject:newItem] == YES || index >= [_items count]) {
        return;
    }
    
    [_items insertObject:newItem atIndex:index];
    [self addSubview:newItem.view];
}

- (void)moveItem:(LinearLayoutItem *)movingItem beforeItem:(LinearLayoutItem *)existingItem {
    if (movingItem == nil || [_items containsObject:movingItem] == NO || existingItem == nil || [_items containsObject:existingItem] == NO || movingItem == existingItem) {
        return;
    }
    
    [_items removeObject:movingItem];
    
    NSUInteger existingItemIndex = [_items indexOfObject:existingItem];
    [_items insertObject:movingItem atIndex:existingItemIndex];
    
    [self setNeedsLayout];
}

- (void)moveItem:(LinearLayoutItem *)movingItem afterItem:(LinearLayoutItem *)existingItem {
    if (movingItem == nil || [_items containsObject:movingItem] == NO || existingItem == nil || [_items containsObject:existingItem] == NO || movingItem == existingItem) {
        return;
    }
    
    [_items removeObject:movingItem];
    
    if (existingItem == [_items lastObject]) {
        [_items addObject:movingItem];
    } else {
        NSUInteger existingItemIndex = [_items indexOfObject:existingItem];
        [_items insertObject:movingItem atIndex:++existingItemIndex];
    }
    
    [self setNeedsLayout];
}

- (void)moveItem:(LinearLayoutItem *)movingItem toIndex:(NSUInteger)index {
    if (movingItem == nil || [_items containsObject:movingItem] == NO || index >= [_items count] || [_items indexOfObject:movingItem] == index) {
        return;
    }
    
    [_items removeObject:movingItem];
    
    if (index == ([_items count] - 1)) {
        [_items addObject:movingItem];
    } else {
        [_items insertObject:movingItem atIndex:index];
    }
    
    [self setNeedsLayout];
}

- (void)swapItem:(LinearLayoutItem *)firstItem withItem:(LinearLayoutItem *)secondItem {
    if (firstItem == nil || [_items containsObject:firstItem] == NO || secondItem == nil || [_items containsObject:secondItem] == NO || firstItem == secondItem) {
        return;
    }
    
    NSUInteger firstItemIndex = [_items indexOfObject:firstItem];
    NSUInteger secondItemIndex = [_items indexOfObject:secondItem];
    [_items exchangeObjectAtIndex:firstItemIndex withObjectAtIndex:secondItemIndex];
    
    [self setNeedsLayout];
}

- (void)redoLayout {
    [self setNeedsLayout];
}

@end

#pragma mark -

@implementation LinearLayoutItem

#pragma mark - Factories

- (id)init {
    self = [super init];
    if (self) {
        self.horizontalAlignment = LinearLayoutItemHorizontalAlignmentLeft;
        self.verticalAlignment = LinearLayoutItemVerticalAlignmentTop;
        self.fillMode = LinearLayoutItemFillModeNormal;
    }
    return self;
}

- (id)initWithView:(UIView *)aView {
    self = [super init];
    if (self) {
        self.view = aView;
        self.horizontalAlignment = LinearLayoutItemHorizontalAlignmentLeft;
        self.verticalAlignment = LinearLayoutItemVerticalAlignmentTop;
        self.fillMode = LinearLayoutItemFillModeNormal;
    }
    return self;
}

+ (LinearLayoutItem *)layoutItemForView:(UIView *)aView {
    LinearLayoutItem *item = [[LinearLayoutItem alloc] initWithView:aView];
    return item;
}


#pragma mark - Helpers

LinearLayoutItemPadding LinearLayoutMakePadding(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
    LinearLayoutItemPadding padding;
    padding.top = top;
    padding.left = left;
    padding.bottom = bottom;
    padding.right = right;
    
    return padding;
}

@end



