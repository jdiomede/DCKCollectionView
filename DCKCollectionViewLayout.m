//
//  DCKCollectionViewLayout.m
//  DCKCollectionView
//
//  Created by James Diomede on 3/30/15.
//  Copyright (c) 2015 James Diomede. All rights reserved.
//

#import "DCKCollectionViewLayout.h"

#import "DCKCollectionViewDefines.h"

@interface DCKCollectionViewNode : NSObject

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) DCKCollectionViewNode *previousNode;

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
  CGFloat horizontalSpacing = collectionViewWidth * 0.025f;
  CGFloat verticalSpacing = horizontalSpacing;
  
  NSUInteger numberOfColumns = 1;
  
  CGFloat cellWidth = (collectionViewWidth - (horizontalSpacing * (numberOfColumns + 1))) / numberOfColumns;
  
  NSUInteger numberOfSections = imageSections.count;
  NSMutableDictionary *mutableNodeForIndexPathDictionary = [NSMutableDictionary dictionary];
  for (NSUInteger section = 0; section < numberOfSections; ++section) {
    // initialize nodes array for section
    NSMutableArray *nodes = [NSMutableArray array];
    for (NSUInteger i = 0; i < numberOfColumns; ++i) {
      DCKCollectionViewNode *node = [[DCKCollectionViewNode alloc] init];
      node.frame = CGRectMake(horizontalSpacing, verticalSpacing, 0.0f, 0.0f);
      [nodes addObject:node];
    }
    NSUInteger numberOfItemsInSection = ((NSArray*)imageSections[section]).count;
    for (NSUInteger item = 0; item < numberOfItemsInSection; ++item) {
      DCKCollectionViewNode *node = [[DCKCollectionViewNode alloc] init];
      node.count = 1;
      // calculate height based on title text
      CGFloat cellHeight = 1.5f*cellWidth;
      CGRect rect = [imageSections[section][item][@"title"] boundingRectWithSize:CGSizeMake(cellWidth - (kDescriptionHorizontalSpacing * 2.0f), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:DESCRIPTION_FONT()} context:nil];
      if (rect.size.height > 0.0f) {
        cellHeight += rect.size.height + (kDescriptionVerticalSpacing * 2.0f) + 1.0f;
      }
      // add cell to the shortest column
      __block NSUInteger shortestColumnIndex = 0;
      __block CGFloat shortestYPosition = MAXFLOAT;
      [nodes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DCKCollectionViewNode *node = (DCKCollectionViewNode*)obj;
        CGFloat yPosition = node.frame.origin.y + node.frame.size.height + verticalSpacing;
        if (yPosition < shortestYPosition) {
          shortestColumnIndex = idx;
          shortestYPosition = yPosition;
        }
      }];
      CGFloat xPosition = horizontalSpacing + shortestColumnIndex * (horizontalSpacing + cellWidth);
      node.frame = CGRectMake(xPosition, shortestYPosition, cellWidth, cellHeight);
      // update nodes dictionary
      [mutableNodeForIndexPathDictionary setObject:node forKey:[NSIndexPath indexPathForRow:item inSection:section]];
      // update nodes array
      node.previousNode = nodes[shortestColumnIndex];
      node.count += node.previousNode.count;
      nodes[shortestColumnIndex] = node;
    }
    // determine maximum height between all columns
    DCKCollectionViewNode *node = nodes[0];
    __block CGFloat maxHeight = node.frame.origin.y + node.frame.size.height;
    [nodes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      DCKCollectionViewNode *node = (DCKCollectionViewNode*)obj;
      if (node.frame.origin.y + node.frame.size.height > maxHeight) {
        maxHeight = node.frame.origin.y + node.frame.size.height;
      }
    }];
    // add pixels to each cell to align all columns in section
    [nodes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      DCKCollectionViewNode *node = (DCKCollectionViewNode*)obj;
      CGFloat diff = (maxHeight - (node.frame.origin.y + node.frame.size.height))/node.count;
      if (diff > FLT_EPSILON) {
        while (node.previousNode != nil) {
          CGRect frame = node.frame;
          frame.size.height += diff;
          frame.origin.y += (node.count-1)*diff;
          node.frame = frame;
          node = node.previousNode;
        }
      }
    }];
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
