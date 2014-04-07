//
//  JWCViewController.m
//  Reddit It
//
//  Created by Jeff Schwab on 4/5/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import "JWCViewController.h"
#import "JWCRedditController.h"
#import "JWCCollectionViewCellSubreddit.h"
#import "JWCViewControllerSubredditPosts.h"

@interface JWCViewController ()
<JWCRedditControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate, UISearchBarDelegate>
{
    CGRect _originalCollectionViewFrame;
    CGRect _originalContainerViewFrame;
}

@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControlBrowseSearch;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewSubreddits;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControlSubredditSections;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControlPostSubreddit;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBarSubreddits;

@property (strong, nonatomic) JWCRedditController *redditController;
@property (strong, nonatomic) NSMutableArray *popularSubreddits;
@property (strong, nonatomic) NSMutableArray *theNewSubreddits;
@property (strong, nonatomic) NSMutableArray *searchedSubreddits;

@property (weak, nonatomic) NSMutableArray *selectedArray;

@property (strong, nonatomic) NSString *subredditAfter;
@property (nonatomic) NSInteger subredditCount;
@property (strong, nonatomic) NSString *subredditType;

@end

@implementation JWCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (UIView *subView in self.searchBarSubreddits.subviews) {
        if([subView isKindOfClass: [UITextField class]])
            [(UITextField *)subView setKeyboardAppearance: UIKeyboardAppearanceAlert];
    }
    
    self.viewContainer.autoresizesSubviews = YES;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.viewContainer.bounds), CGRectGetWidth(self.viewContainer.frame), 1)];
    line.backgroundColor = [UIColor whiteColor];
    [self.viewContainer addSubview:line];
    
    _originalCollectionViewFrame = self.collectionViewSubreddits.frame;
    _originalContainerViewFrame = self.viewContainer.frame;
    
    self.redditController = [JWCRedditController new];
    self.redditController.delegate = self;
    
    self.collectionViewSubreddits.dataSource = self;
    self.collectionViewSubreddits.delegate = self;
    
    self.searchBarSubreddits.delegate = self;
    
    self.popularSubreddits = [NSMutableArray new];
    self.theNewSubreddits = [NSMutableArray new];
    self.searchedSubreddits = [NSMutableArray new];
    
    self.selectedArray = self.popularSubreddits;
    [self.redditController getListOfSubredditsWithType:@"" after:nil count:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JWCRedditControllerDelegate
- (void)finishedLoadingJSON:(NSArray *)subreddits withAfter:(NSString *)after
{
    [self.selectedArray addObjectsFromArray:subreddits];
    self.subredditAfter = after;
    self.subredditCount = [subreddits count];
    
    [self.collectionViewSubreddits reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.selectedArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JWCCollectionViewCellSubreddit *subredditCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SubredditCell" forIndexPath:indexPath];

    [self populateCellWithArray:self.selectedArray cell:subredditCell andRow:indexPath.row];
    return subredditCell;
}

- (void)populateCellWithArray:(NSArray *)currentSubredditArray cell:(JWCCollectionViewCellSubreddit *)subredditCell andRow:(NSInteger)row
{
    if ([currentSubredditArray count] > 0) {
        NSDictionary *currentSubreddit = currentSubredditArray[row];
        NSDictionary *subredditInfo = [currentSubreddit objectForKey:@"data"];
        
        subredditCell.labelSubredditTitle.text = [subredditInfo objectForKey:@"display_name"];
        subredditCell.labelDescription.text = [subredditInfo objectForKey:@"public_description"];
    } else {
        subredditCell.labelSubredditTitle.text = @"Subreddit Title";
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(CGRectGetWidth(self.collectionViewSubreddits.frame)-10, 80);
    return size;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *visibleIndexPaths = [self.collectionViewSubreddits indexPathsForVisibleItems];
    
    for (NSIndexPath *visibleIndexPath in visibleIndexPaths) {
        if (visibleIndexPath.row == [self.selectedArray count]-1) {
            [self.redditController getListOfSubredditsWithType:self.subredditType after:self.subredditAfter count:self.subredditCount];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint scrollViewContentOffset = [scrollView contentOffset];
    if (scrollViewContentOffset.y > 70) {
        [UIView animateKeyframesWithDuration:.2 delay:0 options:0 animations:^{
            self.collectionViewSubreddits.frame = CGRectMake(0, 64, CGRectGetWidth(self.collectionViewSubreddits.frame), CGRectGetHeight(self.view.frame) - 64);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.7 animations:^{
                self.viewContainer.center = CGPointMake(CGRectGetMidX(self.viewContainer.frame), -CGRectGetHeight(self.viewContainer.frame)/2+20);
            } completion:^(BOOL finished) {
                
            }];
        }];
    } else if (CGRectGetHeight(self.collectionViewSubreddits.frame) == CGRectGetHeight(self.view.frame)-64) {
        if (scrollViewContentOffset.y < 0) {
            [self collectionViewSwipedDown:nil];
        }
    }
}

- (void)collectionViewSwipedDown:(UISwipeGestureRecognizer *)downSwipe
{
    CGFloat scrollViewContentOffsetY = self.collectionViewSubreddits.contentOffset.y;
    if (CGRectGetHeight(self.collectionViewSubreddits.frame) == CGRectGetHeight(self.view.frame)-64 && scrollViewContentOffsetY == 0) {
        [UIView animateKeyframesWithDuration:.7 delay:0 options:0 animations:^{
            self.viewContainer.frame = _originalContainerViewFrame;
            self.collectionViewSubreddits.frame = CGRectMake(_originalCollectionViewFrame.origin.x, _originalCollectionViewFrame.origin.y, CGRectGetWidth(_originalCollectionViewFrame), CGRectGetHeight(self.collectionViewSubreddits.frame));
        } completion:^(BOOL finished) {
            self.collectionViewSubreddits.frame = _originalCollectionViewFrame;
        }];
    } else if (CGRectGetHeight(self.collectionViewSubreddits.frame) == CGRectGetHeight(self.view.frame)-64 &&scrollViewContentOffsetY < -50) {
        [UIView animateKeyframesWithDuration:.7 delay:0 options:0 animations:^{
            self.viewContainer.frame = _originalContainerViewFrame;
            self.collectionViewSubreddits.frame = CGRectMake(_originalCollectionViewFrame.origin.x, _originalCollectionViewFrame.origin.y, CGRectGetWidth(_originalCollectionViewFrame), CGRectGetHeight(self.collectionViewSubreddits.frame));
        } completion:^(BOOL finished) {
            self.collectionViewSubreddits.frame = _originalCollectionViewFrame;
        }];
    }
}

#pragma mark - IBOutlets
- (IBAction)switchedPostsSubreddits:(UISegmentedControl *)postOrSubreddit
{
    switch (postOrSubreddit.selectedSegmentIndex) {
        case 0:
            [self.segmentedControlSubredditSections removeAllSegments];
            [self.segmentedControlSubredditSections insertSegmentWithTitle:@"hot" atIndex:0 animated:YES];
            [self.segmentedControlSubredditSections insertSegmentWithTitle:@"new" atIndex:1 animated:YES];
            [self.segmentedControlSubredditSections insertSegmentWithTitle:@"rising" atIndex:2 animated:YES];
            [self.segmentedControlSubredditSections insertSegmentWithTitle:@"controversial" atIndex:3 animated:YES];
            [self.segmentedControlSubredditSections insertSegmentWithTitle:@"top" atIndex:4 animated:YES];
            break;
        case 1:
            [self.segmentedControlSubredditSections removeAllSegments];
            [self.segmentedControlSubredditSections insertSegmentWithTitle:@"popular" atIndex:0 animated:YES];
            [self.segmentedControlSubredditSections insertSegmentWithTitle:@"new" atIndex:1 animated:YES];
            break;
        default:
            break;
    }
}

- (IBAction)switchedSubredditBrowseSearch:(UISegmentedControl *)browseType
{
    switch (browseType.selectedSegmentIndex) {
        case 0:
            self.selectedArray = self.popularSubreddits;
            self.segmentedControlSubredditSections.hidden = NO;
            self.searchBarSubreddits.hidden = YES;
            [self.collectionViewSubreddits reloadData];
            break;
        case 1:
            self.selectedArray = self.searchedSubreddits;
            self.segmentedControlSubredditSections.hidden = YES;
            self.searchBarSubreddits.hidden = NO;
            break;
        default:
            break;
    }
}

- (IBAction)switchSubredditSection:(UISegmentedControl *)subredditSection
{
    switch (subredditSection.selectedSegmentIndex) {
        case 0:
            self.subredditType = @"popular";
            self.selectedArray = self.popularSubreddits;
            if ([self.popularSubreddits count] == 0) {
                [self.redditController getListOfSubredditsWithType:self.subredditType after:nil count:0];
            }
            break;
        case 1:
            self.subredditType = @"new";
            self.selectedArray = self.theNewSubreddits;
            if ([self.theNewSubreddits count] == 0) {
                [self.redditController getListOfSubredditsWithType:self.subredditType after:nil count:0];
            }
            break;
        default:
            break;
    }
    [self.collectionViewSubreddits reloadData];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBarSubreddits endEditing:YES];
    [self.searchedSubreddits removeAllObjects];
    [self.redditController searchSubredditsWithQuery:searchBar.text];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    JWCViewControllerSubredditPosts *destinationViewController = (JWCViewControllerSubredditPosts *)segue.destinationViewController;
    
    NSArray *selectedIndexPaths = [self.collectionViewSubreddits indexPathsForSelectedItems];
    NSIndexPath *selectedIndexPath = selectedIndexPaths[0];

    NSDictionary *selectedSubreddit = self.selectedArray[selectedIndexPath.row];
    NSDictionary *selectedSubredditInfo = [selectedSubreddit objectForKey:@"data"];
    [destinationViewController setSubredditInfo:selectedSubredditInfo];
}

#pragma mark - Oauth Methods
//- (void)startOauth
//{
//    NSURL *redditOauthURL = [self.redditController oauthURL];
//
//    NSURLRequest *redditOauthRequest = [NSURLRequest requestWithURL:redditOauthURL];
//    [self.webView setDelegate:nil];
//    [self.webView loadRequest:redditOauthRequest];
//}

//- (IBAction)clickedContinue:(id)sender
//{
//    NSURL *responseURL = self.webView.request.mainDocumentURL;
//    NSString *responseQuery = [responseURL query];
//    NSArray *queryComponents = [responseQuery componentsSeparatedByString:@"&"];
//
//    NSMutableDictionary *queryComponentsDictionary = [NSMutableDictionary new];
//
//    for (NSString *component in queryComponents) {
//        NSArray *pairComponents = [component componentsSeparatedByString:@"="];
//        NSString *key = pairComponents[0];
//        NSString *value = pairComponents[1];
//
//        [queryComponentsDictionary setValue:value forKey:key];
//    }
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
//    [self.webView stopLoading];
//
//    [self.redditController setOauthCode:[queryComponentsDictionary objectForKey:@"code"]];
//
//    [self.redditController requestAccessToken];
//}
@end
