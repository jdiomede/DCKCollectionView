//
//  ExampleCollectionViewCell.m
//  DCKCollectionView
//
//  Created by James Diomede on 4/1/15.
//  Copyright (c) 2015 James Diomede. All rights reserved.
//

#import "ExampleCollectionViewCell.h"

@implementation ExampleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _ilkImageView = [[ILKImageView alloc] initWithFrame:frame];
  }
  return self;
}

@end
