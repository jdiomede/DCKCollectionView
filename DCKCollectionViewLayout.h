//
//  DCKCollectionViewLayout.h
//  DCKCollectionView
//
//  Created by James Diomede on 3/30/15.
//  Copyright (c) 2015 James Diomede. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCKCollectionViewLayoutDelegate <NSObject>

- (NSArray*)imageSectionsForCollectionView;

@end

@interface DCKCollectionViewLayout : UICollectionViewLayout

@end
