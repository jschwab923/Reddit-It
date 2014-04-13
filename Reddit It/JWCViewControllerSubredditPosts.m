//
//  JWCViewControllerSubredditViewController.m
//  Reddit It
//
//  Created by Jeff Schwab on 4/5/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import "JWCViewControllerSubredditPosts.h"
#import "JWCRedditController.h"
#import "JWCCollectionViewCellRedditPost.h"
#import "JWCViewControllerPostDetails.h"
#import "JWCViewControllerPostComments.h"
#import "NSString+JWCSizeOfString.h"
#import "KGModal.h"

@interface JWCViewControllerSubredditPosts ()
<JWCRedditControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout>
{
    NSIndexPath *_selectedIndexPath;
    BOOL _seguePerformed;
    
}
@property (nonatomic) NSMutableArray *redditPosts;
@property (nonatomic) JWCRedditController *redditController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewPosts;

@property (nonatomic) NSMutableDictionary *postThumbnails;

@end

@implementation JWCViewControllerSubredditPosts

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.redditPosts = [NSMutableArray new];
    self.title = self.subreddit.title;
    
    self.redditController = [JWCRedditController new];
    self.redditController.delegate = self;
    
    self.collectionViewPosts.dataSource = self;
    self.collectionViewPosts.delegate = self;
    
    self.postThumbnails = [NSMutableDictionary new];
    
    [self.redditController getListOfPostsFromSubreddit:self.subreddit.url];
    
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

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.redditPosts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JWCCollectionViewCellRedditPost *redditPostCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostCell" forIndexPath:indexPath];
    
    if ([self.redditPosts count] > 0) {
        JWCRedditPost *currentPost = [self.redditPosts objectAtIndex:indexPath.row];
        redditPostCell.imageViewThumbnail.image = nil;
        
        if (currentPost.thumbnailURL) {
            redditPostCell.imageViewThumbnail.hidden = NO;
            if (![self.postThumbnails objectForKey:currentPost.postID]) {
                [self.redditController downloadThumbnailImage:currentPost.thumbnailURL andID:currentPost.postID];
            } else {
                redditPostCell.imageViewThumbnail.image = [self.postThumbnails objectForKey:currentPost.postID];
            }
        } else {
            redditPostCell.imageViewThumbnail.hidden = YES;
            redditPostCell.labelPostText.frame = redditPostCell.bounds;
        }
        
        redditPostCell.labelPostText.text = currentPost.title;
    }
    
    return redditPostCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
    {
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

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text;
    NSString *font;
    NSInteger fontSize;
    NSInteger heightAdjustment = 0;
    
    NSInteger width = CGRectGetWidth(self.collectionViewPosts.frame);
    font = @"Helvetica-Neue";
    fontSize = 18;
    
    JWCCollectionViewCellRedditPost *currentPostCell = (JWCCollectionViewCellRedditPost *)[collectionView cellForItemAtIndexPath:indexPath];
    text = [NSString stringWithFormat:@"%@%@", currentPostCell.labelPostText.text, currentPostCell.labelPostInfo.text];
    heightAdjustment = 20;
    
    CGSize size = [NSString sizeOfString:text withWidth:width font:font fontSize:fontSize];
    if (size.height < 80) {
        size.height = 90;
    } else {
        size.height += heightAdjustment;
    }
    size.width -= 10;
    return size;
}

#pragma mark - JWCRedditControllerDelegate
- (void)finishedLoadingJSON:(NSArray *)JSON withAfter:(NSString *)after
{
    [self.redditPosts addObjectsFromArray:[self.redditController parseJSON:JSON withType:@"post"]];
    [self.collectionViewPosts reloadData];
    
}

- (void)finishedDownloadingImageWithData:(NSData *)imageData andID:(NSString *)ID
{
    UIImage *postThumbnail = [UIImage imageWithData:imageData];
    [self.postThumbnails setObject:postThumbnail forKey:ID];
    
    NSLog(@"Image Downloaded");
    
    [self.collectionViewPosts reloadData];
}

#pragma mark - Rotation Handling
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionViewPosts setNeedsUpdateConstraints];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (!_seguePerformed) {
        JWCRedditPost *selectedPost = [self.redditPosts objectAtIndex:_selectedIndexPath.row];
        if ([segue.identifier isEqualToString:@"LinkSegue"]) {
            _seguePerformed = YES;
            JWCViewControllerPostDetails *vc = (JWCViewControllerPostDetails *)[segue destinationViewController];
            
            vc.postURL = [NSURL URLWithString:selectedPost.url];
        } else if ([segue.identifier isEqualToString:@"CommentsSegue"]) {
            JWCViewControllerPostComments *vc = (JWCViewControllerPostComments *)[segue destinationViewController];
            
            vc.commentsURL = selectedPost.commentsLink;
        }
    }
}

- (void)pressedViewLink:(UIButton *)viewLink
{
    [self performSegueWithIdentifier:@"LinkSegue" sender:self];
}

- (void)pressedViewComments:(UIButton *)viewComments
{
    [self performSegueWithIdentifier:@"CommentsSegue" sender:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.collectionViewPosts.collectionViewLayout invalidateLayout];
}


@end
