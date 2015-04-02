//
//  ExampleCollectionViewController.m
//  DCKCollectionView
//
//  Created by James Diomede on 3/30/15.
//  Copyright (c) 2015 James Diomede. All rights reserved.
//

#import "ExampleCollectionViewController.h"

#import "DCKCollectionViewLayout.h"
#import "ExampleCollectionViewCell.h"

@interface ExampleCollectionViewController () <DCKCollectionViewLayoutDelegate>
@property (nonatomic, strong) NSArray *imageSections;
@end

@implementation ExampleCollectionViewController

static NSString * const reuseIdentifier = @"ExampleCollectionViewCell";

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
  self = [super initWithCollectionViewLayout:layout];
  if (self) {
    _imageSections = [NSArray array];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.collectionView registerClass:[ExampleCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
  self.title = @"Recent Photos on Flickr";
  self.collectionView.backgroundColor = [UIColor whiteColor];
  self.collectionView.alwaysBounceVertical = YES;
  [self refreshImageUrls];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [self.collectionViewLayout invalidateLayout];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return self.imageSections.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return ((NSArray*)self.imageSections[section]).count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  ExampleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
  if (![self.imageSections[indexPath.section][indexPath.row] isEqual:cell.ilkImageView.urlString]) {
    cell.ilkImageView.image = nil;
    cell.ilkImageView.urlString = self.imageSections[indexPath.section][indexPath.row];
  }
  return cell;
}

#pragma mark <DCKCollectionViewLayoutDelegate>

- (NSArray *)imageSectionsForCollectionView {
  return self.imageSections;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (void)refreshImageUrls {
  NSString *httpHostAndPath = @"https://api.flickr.com/services/rest";
  NSString *httpUrlParamters = [NSString stringWithFormat:@"%@%@%@%@",
                                @"?api_key=496a5ec35ff7653a836f70b1d9c7eac0",
                                @"&method=flickr.photos.getRecent",
                                @"&format=json",
                                @"&nojsoncallback=1"];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", httpHostAndPath, httpUrlParamters]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSError *parseError = NULL;
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
    NSDictionary *photos = [responseDict valueForKey:@"photos"];
    NSArray *photoArray = [photos valueForKey:@"photo"];
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSDictionary *photo in photoArray) {
      //http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
      NSString *photoUrl = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg",
                            [photo valueForKey:@"farm"],
                            [photo valueForKey:@"server"],
                            [photo valueForKey:@"id"],
                            [photo valueForKey:@"secret"]];
      [mutableArray addObject:photoUrl];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      self.imageSections = [NSArray arrayWithObject:mutableArray.copy];
      [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)]];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
      } completion:nil];
    });
  }];
  [dataTask resume];
}



@end
