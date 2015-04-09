//
//  ExampleCollectionViewCell.m
//  DCKCollectionView
//
//  Created by James Diomede on 4/1/15.
//  Copyright (c) 2015 James Diomede. All rights reserved.
//

#import "ExampleCollectionViewCell.h"

#import "DCKCollectionViewDefines.h"

@interface ExampleCollectionViewCell()
@property (nonatomic, strong) UIView *descriptionView;
@property (nonatomic, strong) UIImageView *descriptionBackgroundImageView;
@property (nonatomic, strong) NSLayoutConstraint *dynamicDescriptionViewHeightConstraint;
@end

@implementation ExampleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _ilkImageView = [[ILKImageView alloc] initWithFrame:CGRectZero];
    _ilkImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_ilkImageView];
    _descriptionBackgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"#000000_100px_rounded_5px"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)]];
    _descriptionBackgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _descriptionView = [[UIView alloc] initWithFrame:CGRectZero];
    _descriptionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_descriptionView addSubview:_descriptionBackgroundImageView];
    _imageTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    _imageTitle.translatesAutoresizingMaskIntoConstraints = NO;
    _imageTitle.font = DESCRIPTION_FONT();
    _imageTitle.textColor = [UIColor blackColor];
    _imageTitle.numberOfLines = 0;
    [_descriptionView addSubview:_imageTitle];
    [self.contentView addSubview:_descriptionView];
    NSDictionary *views = @{@"ilkImageView":_ilkImageView, @"descriptionView":_descriptionView, @"descriptionImageBackgroundView":_descriptionBackgroundImageView, @"imageTitle":_imageTitle};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[descriptionImageBackgroundView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[descriptionImageBackgroundView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[imageTitle]-padding-|" options:0 metrics:@{@"padding":@(kDescriptionHorizontalSpacing)} views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[imageTitle]-padding-|" options:0 metrics:@{@"padding":@(kDescriptionVerticalSpacing)} views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[ilkImageView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[descriptionView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ilkImageView][descriptionView]|" options:0 metrics:nil views:views]];
    _dynamicDescriptionViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_descriptionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100.0f];
    [self addConstraint:_dynamicDescriptionViewHeightConstraint];
    [self setNeedsUpdateConstraints];
  }
  return self;
}

- (void)updateConstraints {
  // recalculate description view height based on new title text
  CGRect rect = [self.imageTitle.text boundingRectWithSize:CGSizeMake(self.contentView.frame.size.width - (kDescriptionHorizontalSpacing * 2.0f), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.imageTitle.font} context:nil];
  if (rect.size.height > 0.0f) {
    self.dynamicDescriptionViewHeightConstraint.constant = rect.size.height + (kDescriptionVerticalSpacing * 2.0f) + 1.0f;
  } else {
    self.dynamicDescriptionViewHeightConstraint.constant = 0.0f;
  }
  // increase frame to avoid unecessary layout conflicts after constraints have been updated but before size changes
  CGRect frame = self.contentView.frame;
  frame.size.height += self.dynamicDescriptionViewHeightConstraint.constant;
  self.contentView.frame = frame;
  [super updateConstraints];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.ilkImageView.image = nil;
  self.imageTitle.text = @"";
}

@end
