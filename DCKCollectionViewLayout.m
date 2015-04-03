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
   NSArray *imageSections = [((id<DCKCollectionViewLayoutDelegate>)self.collectionView.dataSource) imageSectionsForCollectionView];
  
  CGFloat collectionViewWidth = self.collectionView.frame.size.width;
  CGFloat horizontalSpacing = collectionViewWidth * 0.05f;
  CGFloat verticalSpacing = horizontalSpacing;
  CGFloat numberOfColumns = 2.0f;
  CGFloat cellWidth = (collectionViewWidth - (horizontalSpacing * (numberOfColumns + 1))) / numberOfColumns;
  
  CGFloat currentXPosition = horizontalSpacing;
  CGFloat currentYPositionColA = verticalSpacing;
  CGFloat currentYPositionColB = verticalSpacing;
  NSUInteger numberOfSections = imageSections.count;
  NSMutableDictionary *mutableNodeForIndexPathDictionary = [NSMutableDictionary dictionary];
  for (NSUInteger section = 0; section < numberOfSections; ++section) {
    NSUInteger numberOfItemsInSection = ((NSArray*)imageSections[section]).count;
    for (NSUInteger item = 0; item < numberOfItemsInSection; ++item) {
      
      DCKCollectionViewNode *node = [[DCKCollectionViewNode alloc] init];
      
      // TODO: setup defines or parameters that can be overridden
      static const CGFloat kHorizontalSpacing = 10.0f;
      static const CGFloat kVerticalSpacing = 10.0f;
      CGFloat cellHeight = 1.5f*cellWidth;
      CGRect rect = [imageSections[section][item][@"title"] boundingRectWithSize:CGSizeMake(cellWidth - (kHorizontalSpacing * 2.0f), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]} context:nil];
      if (rect.size.height > 0.0f) {
        cellHeight += rect.size.height + (kVerticalSpacing * 2.0f) + 1.0f;
      }
      
      if (currentYPositionColA > currentYPositionColB) {
        currentXPosition = cellWidth + (horizontalSpacing * 2.0f);
        node.frame = CGRectMake(currentXPosition, currentYPositionColB, cellWidth, cellHeight);
        currentYPositionColB += node.frame.size.height + verticalSpacing;
      } else {
        currentXPosition = horizontalSpacing;
        node.frame = CGRectMake(currentXPosition, currentYPositionColA, cellWidth, cellHeight);
        currentYPositionColA += node.frame.size.height + verticalSpacing;
      }
      [mutableNodeForIndexPathDictionary setObject:node forKey:[NSIndexPath indexPathForRow:item inSection:section]];
      
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
    if (node.frame.origin.y + node.frame.size.height > collectionViewHeight) {
      // TODO: share vertical spacing value
      collectionViewHeight = node.frame.origin.y + node.frame.size.height + (collectionViewWidth * 0.05f);
    }
  }
  return CGSizeMake(collectionViewWidth, collectionViewHeight);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  return NO;
}

@end
