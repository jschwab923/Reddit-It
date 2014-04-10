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
#import "JWCCollectionVIewCellRedditPost.h"
#import "JWCViewControllerPostDetails.h"
#import "KGModal.h"
#import "JWCRedditPost.h"
#import "JWCSubreddit.h"

@interface JWCViewController ()
<JWCRedditControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate, UISearchBarDelegate>
{
    CGRect _originalCollectionViewFrame;
    CGRect _originalContainerViewFrame;
    NSIndexPath *_selectedIndexPath;
    
    BOOL _seguePerformed;
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

@property (strong, nonatomic) NSMutableArray *hotPosts;
@property (strong, nonatomic) NSMutableArray *theNewPosts;
@property (strong, nonatomic) NSMutableArray *risingPosts;
@property (strong, nonatomic) NSMutableArray *controversialPosts;
@property (strong, nonatomic) NSMutableArray *topPosts;

@property (weak, nonatomic) NSMutableArray *selectedArray;

@property (strong, nonatomic) NSString *subredditAfter;
@property (nonatomic) NSInteger subredditCount;
@property (strong, nonatomic) NSString *subredditType;

@property (strong, nonatomic) NSMutableDictionary *postThumbnails;

@end

@implementation JWCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.segmentedControlSubredditSections removeAllSegments];
    [self.segmentedControlSubredditSections insertSegmentWithTitle:@"hot" atIndex:0 animated:YES];
    [self.segmentedControlSubredditSections insertSegmentWithTitle:@"new" atIndex:1 animated:YES];
    [self.segmentedControlSubredditSections insertSegmentWithTitle:@"rising" atIndex:2 animated:YES];
    [self.segmentedControlSubredditSections insertSegmentWithTitle:@"controversial" atIndex:3 animated:YES];
    [self.segmentedControlSubredditSections insertSegmentWithTitle:@"top" atIndex:4 animated:YES];
    [self.segmentedControlSubredditSections setSelectedSegmentIndex:0];
    [self.segmentedControlBrowseSearch setEnabled:NO forSegmentAtIndex:1];
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
    
    self.hotPosts = [NSMutableArray new];
    self.theNewPosts = [NSMutableArray new];
    self.risingPosts = [NSMutableArray new];
    self.controversialPosts = [NSMutableArray new];
    self.topPosts = [NSMutableArray new];
    
    self.postThumbnails = [NSMutableDictionary new];
    
    self.selectedArray = self.hotPosts;
    [self.redditController getListOfPostsWithSection:@"hot"];
}

- (void)viewWillAppear:(BOOL)animated
{
    _seguePerformed = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JWCRedditControllerDelegate
- (void)finishedLoadingJSON:(NSArray *)JSON withAfter:(NSString *)after
{
    switch (self.segmentedControlPostSubreddit.selectedSegmentIndex) {
        case 0:
            [self.selectedArray addObjectsFromArray:[self.redditController parseJSON:JSON withType:@"post"]];
            break;
        case 1:
            [self.selectedArray addObjectsFromArray:[self.redditController parseJSON:JSON withType:@"subreddit"]];
            break;
        default:
            break;
    }
    self.subredditAfter = after;
    self.subredditCount = [self.selectedArray count];
    [self.collectionViewSubreddits reloadData];
}

- (void)finishedDownloadingImageWithData:(NSData *)imageData andID:(NSString *)ID
{
    UIImage *postThumbnail = [UIImage imageWithData:imageData];
    [self.postThumbnails setObject:postThumbnail forKey:ID];
    
    NSLog(@"Image Downloaded");
    
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
    UICollectionViewCell *currentCell;

    switch (self.segmentedControlPostSubreddit.selectedSegmentIndex) {
        case 0:
        {
            currentCell = (JWCCollectionViewCellRedditPost *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PostCell" forIndexPath:indexPath];
            [self populateCellWithPostsArray:self.selectedArray cell:currentCell andRow:indexPath.row];
            break;
        }
        case 1:
            currentCell = (JWCCollectionViewCellSubreddit *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SubredditCell" forIndexPath:indexPath];
            [self populateCellWithSubredditArray:self.selectedArray cell:currentCell andRow:indexPath.row];
            break;
        default:
            break;
    }
    return currentCell;
}

- (void)populateCellWithPostsArray:(NSArray *)currentPostsArray cell:(UICollectionViewCell *)postCell andRow:(NSInteger)row
{
    JWCCollectionViewCellRedditPost *tempCell = (JWCCollectionViewCellRedditPost *)postCell;
    if ([currentPostsArray count] > 0) {
        
        JWCRedditPost *currentPost = [currentPostsArray objectAtIndex:row];
        tempCell.labelPostText.text = currentPost.title;
        tempCell.imageViewThumbnail.image = nil;
        if (currentPost.thumbnailURL) {
            if (![self.postThumbnails objectForKey:currentPost.postID]) {
                [self.redditController downloadThumbnailImage:currentPost.thumbnailURL andID:currentPost.postID];
            } else {
                tempCell.imageViewThumbnail.image = [self.postThumbnails objectForKey:currentPost.postID];
            }
        } else {
            tempCell.imageViewThumbnail.hidden = YES;
        }
    }
}

- (void)populateCellWithSubredditArray:(NSArray *)currentSubredditArray cell:(UICollectionViewCell *)subredditCell andRow:(NSInteger)row
{
    JWCCollectionViewCellSubreddit *tempCell = (JWCCollectionViewCellSubreddit *)subredditCell;
    if ([currentSubredditArray count] > 0) {
        JWCSubreddit *currentSubreddit = [currentSubredditArray objectAtIndex:row];
        tempCell.labelSubredditTitle.text = currentSubreddit.title;
        tempCell.labelDescription.text = currentSubreddit.publicDescription;
    } else {
        tempCell.labelSubredditTitle.text = @"Subreddit Title";
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControlPostSubreddit.selectedSegmentIndex == 0) {
        _selectedIndexPath = indexPath;

        KGModal *postDetailSelection = [KGModal sharedInstance];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
        UIButton *viewLink = [[UIButton alloc] initWithFrame:CGRectMake(30, 0, 90, 30)];
        [viewLink setTitle:@"Link" forState:UIControlStateNormal];
        [viewLink addTarget:self action:@selector(pressedViewLink:)
           forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *viewComments = [[UIButton alloc] initWithFrame:CGRectMake(30, 45, 90, 30)];
        [viewComments setTitle:@"Comments" forState:UIControlStateNormal];
        [viewComments addTarget:self action:@selector(pressedViewComments:)
           forControlEvents:UIControlEventTouchUpInside];
        
        [contentView addSubview:viewLink];
        [contentView addSubview:viewComments];
        
        [postDetailSelection showWithContentView:contentView];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *currentText;
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:18];
    CGSize textSize = CGSizeMake(265.0, MAXFLOAT);
    
    switch (self.segmentedControlPostSubreddit.selectedSegmentIndex) {
        case 0:
        {
            JWCRedditPost *currentPost = self.selectedArray[indexPath.row];
            currentText = currentPost.title;
            break;
        }
        case 1:
        {
            JWCSubreddit *currentSubreddit = self.selectedArray[indexPath.row];
            currentText = currentSubreddit.publicDescription;
            break;
        }
        default:
            break;
    }
    CGRect boundingRect = [currentText boundingRectWithSize:textSize
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]
                                                          context:nil];
    CGSize roundedSize;
    if (boundingRect.size.height <= 100) {
        roundedSize = CGSizeMake(CGRectGetWidth(collectionView.frame), 100);
    } else {
        roundedSize = CGSizeMake(CGRectGetWidth(collectionView.frame), ceil(boundingRect.size.height));
    }
    
    return roundedSize;
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
            self.selectedArray = self.hotPosts;
            [self.segmentedControlBrowseSearch setSelectedSegmentIndex:0];
            [self.segmentedControlBrowseSearch setEnabled:NO forSegmentAtIndex:1];
            self.segmentedControlSubredditSections.hidden = NO;
            self.searchBarSubreddits.hidden = YES;
            [self.collectionViewSubreddits reloadData];
            
            [self.segmentedControlSubredditSections removeAllSegments];
            [self.segmentedControlSubredditSections insertSegmentWithTitle:@"hot" atIndex:0 animated:YES];
            [self.segmentedControlSubredditSections insertSegmentWithTitle:@"new" atIndex:1 animated:YES];
            [self.segmentedControlSubredditSections insertSegmentWithTitle:@"rising" atIndex:2 animated:YES];
            [self.segmentedControlSubredditSections insertSegmentWithTitle:@"controversial" atIndex:3 animated:YES];
            [self.segmentedControlSubredditSections insertSegmentWithTitle:@"top" atIndex:4 animated:YES];
            break;
        case 1:
            self.selectedArray = self.popularSubreddits;
            [self.segmentedControlBrowseSearch setEnabled:YES forSegmentAtIndex:1];
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
    switch (self.segmentedControlPostSubreddit.selectedSegmentIndex) {
        case 0:
            break;
        case 1:
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
            break;
        default:
            break;
    }
}

- (IBAction)switchSubredditSection:(UISegmentedControl *)subredditSection
{
    switch (self.segmentedControlPostSubreddit.selectedSegmentIndex) {
        case 0:
            [self.postThumbnails removeAllObjects];
            switch (subredditSection.selectedSegmentIndex) {
                case 0:
                    self.selectedArray = self.hotPosts;
                    self.subredditType = @"hot";
                    if ([self.selectedArray count] == 0) {
                        [self.redditController getListOfPostsWithSection:self.subredditType];
                    }
                    break;
                case 1:
                    self.selectedArray = self.theNewPosts;
                    self.subredditType = @"new";
                    if ([self.selectedArray count] == 0) {
                        [self.redditController getListOfPostsWithSection:self.subredditType];
                    }
                    break;
                case 2:
                    self.selectedArray = self.risingPosts;
                    self.subredditType = @"rising";
                    if ([self.selectedArray count] == 0) {
                        [self.redditController getListOfPostsWithSection:self.subredditType];
                    }
                    break;
                case 3:
                    self.selectedArray = self.controversialPosts;
                    self.subredditType = @"controversial";
                    if ([self.selectedArray count] == 0) {
                        [self.redditController getListOfPostsWithSection:self.subredditType];
                    }
                    break;
                case 4:
                    self.selectedArray = self.topPosts;
                    self.subredditType = @"top";
                    if ([self.selectedArray count] == 0) {
                        [self.redditController getListOfPostsWithSection:self.subredditType];
                    }
                    break;
                default:
                    break;
            }
            break;
        case 1:
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
    switch (self.segmentedControlPostSubreddit.selectedSegmentIndex) {
        case 0:
        {
            if (!_seguePerformed) {
                _seguePerformed = YES;
                JWCViewControllerPostDetails *destinationViewController = (JWCViewControllerPostDetails *)segue.destinationViewController;
            
                JWCRedditPost *selectedPost = [self.selectedArray objectAtIndex:_selectedIndexPath.row];
                NSURL *postURL = [NSURL URLWithString:selectedPost.url];
                [destinationViewController setPostURL:postURL];
            }
            break;
        }
        case 1:
        {
            if (!_seguePerformed) {
                [[KGModal sharedInstance] hideAnimated:YES];
                _seguePerformed = YES;
                JWCViewControllerSubredditPosts *destinationViewController = (JWCViewControllerSubredditPosts *)segue.destinationViewController;
                
                NSIndexPath *selectedIndexPath = [[self.collectionViewSubreddits indexPathsForSelectedItems] firstObject];
                JWCSubreddit *selectedSubreddit = [self.selectedArray objectAtIndex:selectedIndexPath.row];
                [destinationViewController setSubreddit:selectedSubreddit];
            }
            break;
        }
        default:
            break;
    }
}

- (void)pressedViewLink:(UIButton *)viewLink
{
    [[KGModal sharedInstance] hideAnimated:YES];
    [self performSegueWithIdentifier:@"LinkSegue" sender:self];
}

- (void)pressedViewComments:(UIButton *)viewComments
{
    [[KGModal sharedInstance] hideAnimated:YES];
    [self performSegueWithIdentifier:@"CommentsSegue" sender:self];
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
