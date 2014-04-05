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

@interface JWCViewController () <JWCRedditControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewSubreddits;

@property (strong, nonatomic) JWCRedditController *redditController;
@property (strong, nonatomic) NSArray *subreddits;
@property (strong, nonatomic) NSString *subredditAfter;

@end

@implementation JWCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.redditController = [JWCRedditController new];
    self.redditController.delegate = self;
    
    self.collectionViewSubreddits.dataSource = self;
    self.collectionViewSubreddits.delegate = self;
    
    [self.redditController getListOfSubreddits:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JWCRedditControllerDelegate
- (void)finishedLoadingSubredditList:(NSArray *)subreddits withAfter:(NSString *)after
{
    self.subreddits = subreddits;
    self.subredditAfter = after;
    
    [self.collectionViewSubreddits reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 25;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JWCCollectionViewCellSubreddit *subredditCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SubredditCell"
                                                                                              forIndexPath:indexPath];
    if (self.subreddits) {
        NSDictionary *currentSubreddit = self.subreddits[indexPath.row];
        NSDictionary *subredditInfo = [currentSubreddit objectForKey:@"data"];
        
        subredditCell.labelSubredditTitle.text = [subredditInfo objectForKey:@"display_name"];
        subredditCell.labelDescription.text = [subredditInfo objectForKey:@"public_description"];
    } else {
        subredditCell.labelSubredditTitle.text = @"Subreddit Title";
    }
    
    return subredditCell;
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
