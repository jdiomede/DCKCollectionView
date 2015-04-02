//
//  DCKCollectionViewLayout.m
//  DCKCollectionView
//
//  Created by James Diomede on 3/30/15.
//  Copyright (c) 2015 James Diomede. All rights reserved.
//

#import "DCKCollectionViewLayout.h"

@interface DCKCollectionViewNode : NSObject

@property (nonatomic, assign) CGRect frame;

@end

@implementation DCKCollectionViewNode

@end

@interface DCKCollectionViewLayout()
@property (nonatomic, strong) NSDictionary *nodeForIndexPath;
@end

@implementation DCKCollectionViewLayout

- (instancetype)init {
  self = [super init];
  if (self) {
    _nodeForIndexPath = [NSDictionary dictionary];
  }
  return self;
}

- (void)prepareLayout {
  [super prepareLayout];
  CGFloat collectionViewWidth = self.collectionView.frame.size.width;
  CGFloat horizontalSpacing = collectionViewWidth * 0.05f;
  CGFloat verticalSpacing = horizontalSpacing;
  CGFloat numberOfColumns = 2.0f;
  CGFloat cellWidth = (collectionViewWidth - (horizontalSpacing * (numberOfColumns + 1))) / numberOfColumns;
  
  CGFloat currentXPosition = horizontalSpacing;
  CGFloat currentYPosition = verticalSpacing;
  NSUInteger numberOfSections = 0;
  id dataSource = self.collectionView.dataSource;
  if ([dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
    numberOfSections = [dataSource numberOfSectionsInCollectionView:self.collectionView];
  }
  NSMutableDictionary *mutableNodeForIndexPathDictionary = [NSMutableDictionary dictionary];
  for (NSUInteger section = 0; section < numberOfSections; ++section) {
    NSUInteger numberOfItemsInSection = 0;
    if ([dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
      numberOfItemsInSection = [dataSource collectionView:self.collectionView numberOfItemsInSection:section];
    }
    for (NSUInteger item = 0; item < numberOfItemsInSection; ++item) {

      // Simple alternation pattern
      DCKCollectionViewNode *node = [[DCKCollectionViewNode alloc] init];
      node.frame = CGRectMake(currentXPosition, currentYPosition, cellWidth, 1.5f*cellWidth);
      [mutableNodeForIndexPathDictionary setObject:node forKey:[NSIndexPath indexPathForRow:item inSection:section]];
      if (item % 2) {
        currentXPosition = horizontalSpacing;
        currentYPosition += node.frame.size.height + verticalSpacing;
      } else {
        currentXPosition = cellWidth + (horizontalSpacing * 2.0f);
      }
      
    }
  }
  self.nodeForIndexPath = mutableNodeForIndexPathDictionary.copy;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSMutableArray *mutableArray = [NSMutableArray array];
  for (NSIndexPath *indexPath in self.nodeForIndexPath.allKeys) {
    DCKCollectionViewNode *node = self.nodeForIndexPath[indexPath];
    if (CGRectIntersectsRect(node.frame, rect)) {
      UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
      [mutableArray addObject:attributes];
    }
  }
  return mutableArray.copy;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
  attributes.frame = ((DCKCollectionViewNode*)self.nodeForIndexPath[indexPath]).frame;
  return attributes;
}

- (CGSize)collectionViewContentSize {
  CGFloat collectionViewWidth = self.collectionView.frame.size.width;
  CGFloat collectionViewHeight = 0.0f;
  for (DCKCollectionViewNode *node in self.nodeForIndexPath.allValues) {
    if (node.frame.origin.y > collectionViewHeight) {
      // TODO: share vertical spacing value
      collectionViewHeight = node.frame.origin.y + node.frame.size.height + (self.collectionView.frame.size.width * 0.05f);
    }
  }
  return CGSizeMake(collectionViewWidth, collectionViewHeight);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  return NO;
}

@end
