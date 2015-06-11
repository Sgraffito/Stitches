//
//  FavoritesCVC.m
//  Stitches2
//
//  Created by Nicole Yarroch on 5/30/15.
//  Copyright (c) 2015 Nicole Yarroch. All rights reserved.
//

#import "FavoritesCVC.h"
#import "RaverlyOAuth.h"

@interface FavoritesCVC ()
@property (strong, nonatomic) NSDictionary *favorites;
@property (strong, nonatomic) NSArray *projectImages;
@end

@implementation FavoritesCVC

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - Instantiate
- (NSArray *)projectImages {
    if (!_projectImages) _projectImages = [[NSArray alloc] init];
    return _projectImages;
}

- (NSDictionary *)favorites {
    if (!_favorites) _favorites = [[NSDictionary alloc] init];
    return _favorites;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    RaverlyOAuth *myEngine = [RaverlyOAuth sharedInstance];

    NSLog(@"MyEngine.username %@", myEngine.userName);
    NSString *url = [NSString stringWithFormat:@"https://api.ravelry.com/people/%@/favorites/list.json", myEngine.userName];

    [myEngine.ravelryClient getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Response content
        NSLog(@"%@", responseObject);

        self.favorites = (NSDictionary *)responseObject;
        self.title = @"Favorites retrieved";
            [self.collectionView reloadData];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Favorites"
        message:[error localizedDescription]
        delegate:nil
        cancelButtonTitle:@"Ok"
        otherButtonTitles:nil];
        [alertView show];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [[self.favorites valueForKeyPath:@"favorites.favorited.first_photo.medium_url"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    // Get images for favorited projects
    self.projectImages = [self.favorites valueForKeyPath:@"favorites.favorited.first_photo.medium_url"];

    static NSString *identifier = @"FavoritesCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    // Add the image to the cell
    UIImageView *favoritesImageView = (UIImageView *)[cell viewWithTag:100];
    
    // URL
    NSURL *imageURL = self.projectImages[indexPath.row];
    
//    NSLog(@"Image is: %@", imageURL);
    
    // Default image
//    favoritesImageView.image = [UIImage imageNamed:@"signitureSnake"];
    
    
    
    favoritesImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", imageURL]]]];
    favoritesImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    return cell;
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    float numberOfCells = 3;
    float numberOfSpaces = 2;
    float widthOfSpace = 5;
    float spaceSize = numberOfSpaces * widthOfSpace;
    float cellWidth = (screenSize.size.width - spaceSize) / numberOfCells;
    float cellHeight = cellWidth;
    return CGSizeMake(cellWidth, cellHeight);
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

@end
