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
<JWCRedditControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControlBrowseSearch;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewSubreddits;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBarSubreddits;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControlSubredditSections;


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

#pragma mark - IBOutlets
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
                [self.redditController getListOfSubredditsWithType:self.subredditType after:self.subredditAfter count:self.subredditCount];
            }
            break;
        case 1:
            self.subredditType = @"new";
            self.selectedArray = self.theNewSubreddits;
            if ([self.theNewSubreddits count] == 0) {
                [self.redditController getListOfSubredditsWithType:self.subredditType after:self.subredditAfter count:self.subredditCount];
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
