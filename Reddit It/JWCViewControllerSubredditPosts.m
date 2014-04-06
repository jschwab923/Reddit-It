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

@interface JWCViewControllerSubredditPosts ()
<JWCRedditControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic) NSArray *redditPosts;
@property (nonatomic) JWCRedditController *redditController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewPosts;

@property (nonatomic) NSMutableDictionary *postThumbnails;

@end

@implementation JWCViewControllerSubredditPosts

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.redditPosts = [NSMutableArray new];
    self.title = [self.subredditInfo objectForKey:@"display_name"];
    
    self.redditController = [JWCRedditController new];
    self.redditController.delegate = self;
    
    self.collectionViewPosts.dataSource = self;
    self.collectionViewPosts.delegate = self;
    
    self.postThumbnails = [NSMutableDictionary new];
    
    [self.redditController getListOfPostsFromSubreddit:[self.subredditInfo objectForKey:@"url"]];
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
        NSDictionary *currentPost = [self.redditPosts objectAtIndex:indexPath.row];
        NSDictionary *currentPostData = [currentPost objectForKey:@"data"];
        
        NSString *postID = [currentPostData objectForKey:@"id"];
    
        redditPostCell.imageViewThumbnail.image = nil;
        
        if (![[currentPostData objectForKey:@"thumbnail"] isEqualToString:@""]) {
            redditPostCell.imageViewThumbnail.hidden = NO;
            if (![self.postThumbnails objectForKey:postID]) {
                [self.redditController downloadThumbnailImage:currentPost];
            } else {
                redditPostCell.imageViewThumbnail.image = [self.postThumbnails objectForKey:postID];
            }
        } else {
            redditPostCell.imageViewThumbnail.hidden = YES;
            redditPostCell.labelPostText.frame = redditPostCell.bounds;
        }
        
        redditPostCell.labelPostText.text = [currentPostData objectForKey:@"title"];
    }
    
    return redditPostCell;
}

#pragma mark - JWCRedditControllerDelegate
- (void)finishedLoadingJSON:(NSArray *)JSON withAfter:(NSString *)after
{
    self.redditPosts = JSON;
    [self.collectionViewPosts reloadData];
    
}

- (void)finishedDownloadingImageWithData:(NSData *)imageData andID:(NSString *)ID
{
    UIImage *postThumbnail = [UIImage imageWithData:imageData];
    [self.postThumbnails setObject:postThumbnail forKey:ID];
    
    NSLog(@"Image Downloaded");
    
    [self.collectionViewPosts reloadData];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *selectedIndexPath = [[self.collectionViewPosts indexPathsForSelectedItems] firstObject];
    JWCViewControllerPostDetails *vc = (JWCViewControllerPostDetails *)[segue destinationViewController];
    
    NSDictionary *selectedPost = [self.redditPosts objectAtIndex:selectedIndexPath.row];
    NSDictionary *postData = [selectedPost objectForKey:@"data"];
    
    vc.postURL = [NSURL URLWithString:[postData objectForKey:@"url"]];
}


@end
