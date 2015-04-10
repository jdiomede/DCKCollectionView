//
//  DCKCollectionViewLayout.h
//  DCKCollectionView
//
//  Created by James Diomede on 3/30/15.
//  Copyright (c) 2015 James Diomede. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCKCollectionViewLayoutDelegate <NSObject>

- (NSArray*)imageSectionsForCollectionView; // expose data to access text content
- (NSUInteger)numberOfColumnsForCollectionView; // dyanmic based on screen size and device
- (CGFloat)marginsForCollectionView; // space from top, bottom, left, and right assumed similar
- (CGFloat)marginsForCollectionViewCells; // assumes x and y are similar
- (UIFont*)fontForTitleText; // potentially dynamic based on screen size and device

@end

@interface DCKCollectionViewLayout : UICollectionViewLayout

@end
