//
//  JWCViewControllerSubredditViewController.m
//  Reddit It
//
//  Created by Jeff Schwab on 4/5/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import "JWCViewControllerSubredditViewController.h"
#import "JWCRedditController.h"
#import "JWCCollectionViewCellRedditPost.h"

@interface JWCViewControllerSubredditViewController ()
<JWCRedditControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic) NSMutableArray *redditPosts;
@property (nonatomic) JWCRedditController *redditController;

@end

@implementation JWCViewControllerSubredditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.redditPosts = [NSMutableArray new];
    self.title = [self.subredditInfo objectForKey:@"display_name"];
    
    self.redditController = [JWCRedditController new];
    
    [self.redditController getListOfPostsFromSubreddit:[self.subredditInfo objectForKey:@"title"]];
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
    JWCCollectionViewCellRedditPost *redditPostCell = [JWCCollectionViewCellRedditPost new];
    
    return redditPostCell;
}

#pragma mark - JWCRedditControllerDelegate
- (void)finishedLoadingJSON:(NSArray *)JSON withAfter:(NSString *)after
{
    NSLog(@"%@", JSON);
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
