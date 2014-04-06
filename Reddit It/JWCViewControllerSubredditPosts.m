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

@interface JWCViewControllerSubredditPosts ()
<JWCRedditControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic) NSArray *redditPosts;
@property (nonatomic) JWCRedditController *redditController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewPosts;

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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
