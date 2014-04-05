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

@interface JWCViewController () <JWCRedditControllerDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) JWCRedditController *redditController;

@end

@implementation JWCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.redditController = [JWCRedditController new];
    self.redditController.delegate = self;
    
    [self.redditController getListOfSubreddits:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JWCRedditControllerDelegate
- (void)finishedLoadingSubredditList:(NSDictionary *)subredditJSON
{
    NSLog(@"%@", subredditJSON);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JWCCollectionViewCellSubreddit *subredditCell = [JWCCollectionViewCellSubreddit new];
    
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
