//
//  ImageSearchCollectionViewController.m
//  pixster
//
//  Created by Eric Hung on 2/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "ImageSearchCollectionViewController.h"
#import "ImageCollectionCell.h"
#import "UIImageView+AFNetworking.h"

@interface ImageSearchCollectionViewController () <UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray *imageResults;
@property (nonatomic, strong) NSString *currentSearchText;
@end

@implementation ImageSearchCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Pixster";
        self.imageResults = [NSMutableArray array];
    }
    return self;
}

-(id) initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.title = @"Pixster";
        self.imageResults = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCell"];
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 320.0, 44.0)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 44.0)];
    searchBarView.autoresizingMask = 0;
    searchBar.delegate = self;
    [searchBarView addSubview:searchBar];
    self.navigationItem.titleView = searchBarView;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.imageResults count];
//    NSString *searchTerm = self.searches[section];
//    return [self.searchResults[searchTerm] count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;//[self.imageResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionCell *cell = (ImageCollectionCell*)[cv dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];

   cell.imageView21.image = nil;
    [cell.imageView21 setImageWithURL:[NSURL URLWithString:[self.imageResults[indexPath.row] valueForKeyPath:@"url"]]];
    NSLog(@"%@", [self.imageResults[indexPath.row] valueForKeyPath:@"url"]);
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(95, 95);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    NSURL *url = nil;
    self.currentSearchText = [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    [self.imageResults removeAllObjects];
    
    for (int i = 0; i < 2; i++) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&rsz=8&start=%d", [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], i*8]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response,NSData *data, NSError *connectionError) {
            id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
            NSDictionary *responseData = [results objectForKey:@"responseData"];
            NSMutableArray *array = [responseData objectForKey:@"results"];
            if ([array isKindOfClass:[NSArray class]]) {
                [self.imageResults addObjectsFromArray:array];
                [self.collectionView reloadData];
            }
    }];
    }
    [searchBar resignFirstResponder];
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"%d", indexPath.row);
    if (indexPath.row == [self.imageResults count]/3-4) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&rsz=8&start=%d", self.currentSearchText, [self.imageResults count]]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response,NSData *data, NSError *connectionError) {
                id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                NSDictionary *responseData = [results objectForKey:@"responseData"];
                NSMutableArray *array = [responseData objectForKey:@"results"];
                if ([array isKindOfClass:[NSArray class]]) {
                    [self.imageResults addObjectsFromArray:array];
                    [self.collectionView reloadData];
                }
            }];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}
@end
