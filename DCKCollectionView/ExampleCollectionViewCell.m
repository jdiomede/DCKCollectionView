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
    _ilkImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _ilkImageView.contentMode = UIViewContentModeScaleAspectFill;
    _ilkImageView.clipsToBounds = YES;
    [self.contentView addSubview:_ilkImageView];
    NSDictionary *views = @{@"ilkImageView":_ilkImageView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[ilkImageView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ilkImageView]|" options:0 metrics:nil views:views]];
  }
  return self;
}

@end
