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
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, strong) NSArray *imageSections;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation ExampleCollectionViewController

static NSString * const reuseIdentifier = @"ExampleCollectionViewCell";

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
  self = [super initWithCollectionViewLayout:layout];
  if (self) {
    _numberOfColumns = 1;
    _imageSections = [NSArray array];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.refreshControl addTarget:self action:@selector(refreshImageUrls) forControlEvents:UIControlEventValueChanged];
  [self.collectionView addSubview:self.refreshControl];
  [self.collectionView registerClass:[ExampleCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
  self.title = @"Recent Photos on Flickr";
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStylePlain target:self action:@selector(more)];
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Less" style:UIBarButtonItemStylePlain target:self action:@selector(less)];
  self.collectionView.backgroundColor = [UIColor colorWithRed:(233.0f/255.0f) green:(233.0f/255.0f) blue:(233.0f/255.0f) alpha:1.0f];
  self.collectionView.alwaysBounceVertical = YES;
  [self refreshImageUrls];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [self.collectionViewLayout invalidateLayout];
}

- (void)less {
  if (self.numberOfColumns > 1) {
    self.numberOfColumns--;
    [self.collectionViewLayout invalidateLayout]; // force layout
//    [self.collectionView reloadData]; // reload images at new size
    [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];// reload images at new size
  }
}

- (void)more {
  if (self.numberOfColumns < 4) {
    self.numberOfColumns++;
    [self.collectionViewLayout invalidateLayout]; // force layout
//    [self.collectionView reloadData]; // reload images at new size
    [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];// reload images at new size
  }
}

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
      NSString *title = [photo valueForKey:@"title"];
      [mutableArray addObject:@{@"photoUrl":photoUrl, @"title":title}];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.refreshControl endRefreshing];
      self.imageSections = [NSArray arrayWithObject:mutableArray.copy];
      [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)]];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
      } completion:nil];
    });
  }];
  [dataTask resume];
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
    UIFont *titleTextFont = [self fontForTitleText];
    NSDictionary *params = self.imageSections[indexPath.section][indexPath.row];
    // calculate imageView height based on <cell attribute height> - <description view height>
    UICollectionViewLayoutAttributes *attributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    CGRect rect = [params[@"title"] boundingRectWithSize:CGSizeMake(cell.frame.size.width - ([self marginsForCollectionViewCells] * 2.0f), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titleTextFont} context:nil];
    CGFloat imageHeight = attributes.frame.size.height - rect.size.height;
    [cell.ilkImageView setUrlString:params[@"photoUrl"] withAttributes:@{ILKImageSizeAttributeName:[NSValue valueWithCGSize:CGSizeMake(attributes.frame.size.width, imageHeight)], ILKCornerRadiusAttributeName:@(3.0f), ILKRectCornerAttributeName:@(ILKRectCornerTopLeft|ILKRectCornerTopRight)}];
    // set title text
    cell.imageTitle.font = titleTextFont;
    cell.imageTitle.text = params[@"title"];
  }
  return cell;
}

#pragma mark <DCKCollectionViewLayoutDelegate>

- (NSArray *)imageSectionsForCollectionView {
  return self.imageSections;
}

- (NSUInteger)numberOfColumnsForCollectionView {
  return self.numberOfColumns;
}

- (CGFloat)marginsForCollectionView {
  return self.collectionView.frame.size.width * 0.025f;
}

- (CGFloat)marginsForCollectionViewCells {
  return 10.0f;
}

- (UIFont *)fontForTitleText {
  return [UIFont fontWithName:@"HelveticaNeue" size:(14.0f-7.0f*self.numberOfColumns/4.0f)]; // some random font scaling
}

@end
