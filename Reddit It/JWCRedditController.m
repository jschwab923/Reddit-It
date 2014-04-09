//
//  JWCRedditController.m
//  Reddit It
//
//  Created by Jeff Schwab on 4/5/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import "JWCRedditController.h"

#define REDDIT_REDIRECT_URI @"http://www.jeffwritescode.com/reddititredirect/"
#define REDDIT_CLIENT_ID @"wmDKutCWHjquKA"
#define REDDIT_OAUTH @"https://ssl.reddit.com/api/v1/authorize?state=%@&duration=permanent&response_type=code&scope=identity&client_id=%@&redirect_uri=%@"

#define REDDIT_SECRET @"DsoW2WhAik4BN_RpYoINJv9AQ30"


#define SUBREDDIT_URL @"http://www.reddit.com/subreddits/%@.json"
#define SUBREDDIT_AFTER_URL @"http://www.reddit.com/subreddits/%@.json?after=%@"
#define SUBREDDIT_AFTER_COUNT_URL @"http://www.reddit.com/subreddits/%@.json?after=%@&count=%i"

#define MAIN_SECTIONS_URL @"http://www.reddit.com/%@.json"

#define SUBREDDIT_SEARCH_URL @"http://www.reddit.com/subreddits/search.json?q=%@"

#define SUBREDDIT_POSTS_URL @"http://www.reddit.com/%@.json"

@implementation JWCRedditController

- (NSURL *)oauthURL
{
    self.state = @"stringthingstringping";
    
    NSString *oauth = [NSString stringWithFormat:REDDIT_OAUTH, self.state, REDDIT_CLIENT_ID, REDDIT_REDIRECT_URI];
    oauth = [oauth stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *oauthURL = [NSURL URLWithString:oauth];
    
    return oauthURL;
}

- (void)requestAccessToken
{
    NSURL *accessTokenUrl = [NSURL URLWithString:@"https://ssl.reddit.com/api/v1/access_token?"];
    
    NSMutableURLRequest *accessTokenRequest = [NSMutableURLRequest requestWithURL:accessTokenUrl];
    [accessTokenRequest setHTTPMethod:@"POST"];
    //    [accessTokenRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //    [accessTokenRequest setValue:self.state forHTTPHeaderField:@"state"];
    //    [accessTokenRequest setValue:@"identity" forHTTPHeaderField:@"scope"];
    //    [accessTokenRequest setValue:REDDIT_CLIENT_ID forHTTPHeaderField:@"client_id"];
    //    [accessTokenRequest setValue:REDDIT_REDIRECT_URI forHTTPHeaderField:@"redirect_uri"];
    //    [accessTokenRequest setValue:self.oauthCode forHTTPHeaderField:@"code"];
    //    [accessTokenRequest setValue:@"authorization_code" forHTTPHeaderField:@"grant_type"];
    
    [accessTokenRequest setValue:REDDIT_CLIENT_ID forHTTPHeaderField:@"client_id"];
    [accessTokenRequest setValue:REDDIT_SECRET forHTTPHeaderField:@"client_secret"];
    
    NSString *postDataString = [NSString stringWithFormat:@"grant_type=authorization_code&code=%@&redirect_uri=%@", self.oauthCode, REDDIT_REDIRECT_URI];
    NSData *postData = [NSData dataWithBytes:[postDataString UTF8String]
                                      length:[postDataString length]];
    
    [accessTokenRequest setHTTPBody:postData];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:accessTokenRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSLog(@"%@ %@", responseJSON, error);
    }];
    [dataTask resume];
}

- (void)getListOfPostsWithSection:(NSString *)section
{
    NSString *urlString = [NSString stringWithFormat:MAIN_SECTIONS_URL, section];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *postURL = [NSURL URLWithString:urlString];
    
    [self queryRedditWithURL:postURL];
}

- (void)getListOfSubredditsWithType:(NSString *)type after:(NSString *)afterParameter count:(NSInteger)count
{
    NSString *subbredditURL;
    if (afterParameter) {
        if (count) {
            subbredditURL = [NSString stringWithFormat:SUBREDDIT_AFTER_COUNT_URL, type, afterParameter, count];
        } else {
            subbredditURL = [NSString stringWithFormat:SUBREDDIT_AFTER_URL, type, afterParameter];
        }
    } else {
        subbredditURL = [NSString stringWithFormat:SUBREDDIT_URL, type];
    }
    
    NSURL *url = [NSURL URLWithString:subbredditURL];
    [self queryRedditWithURL:url];
}

- (void)searchSubredditsWithQuery:(NSString *)query
{
    NSString *queryString = [NSString stringWithFormat:SUBREDDIT_SEARCH_URL, query];
    queryString = [queryString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:queryString];
    
    [self queryRedditWithURL:url];
}

- (void)getListOfPostsFromSubreddit:(NSString *)subreddit
{
    NSString *postsURL = [NSString stringWithFormat:SUBREDDIT_POSTS_URL, subreddit];
    postsURL = [postsURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *queryURL = [NSURL URLWithString:postsURL];
    
    [self queryRedditWithURL:queryURL];
}

// Takes a dictionary that either contains and array of post dictionarys, or just one post dictionary.
- (void)downloadThumbnailImage:(NSURL *)imageURL andID:(NSNumber *)postID
{
    NSMutableDictionary *thumbnailIDandURL = [NSMutableDictionary new];
    
    NSURL *thumbnailURL = imageURL;
    
    [thumbnailIDandURL setObject:thumbnailURL forKey:postID];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDownloadTask *downloadTask = [urlSession downloadTaskWithURL:thumbnailURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSData *imageData = [NSData dataWithContentsOfURL:location];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate finishedDownloadingImageWithData:imageData
                                                          andID:[[thumbnailIDandURL allKeysForObject:thumbnailURL] firstObject]];
            });
        }
    }];
    [downloadTask resume];
    
}

- (void)queryRedditWithURL:(NSURL *)url
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            NSDictionary *dataDictionary = [responseJSON objectForKey:@"data"];
            NSArray *children = [dataDictionary objectForKey:@"children"];
            
            NSString *after = [dataDictionary objectForKey:@"after"];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate finishedLoadingJSON:children withAfter:after];
            });
        } else {
            NSLog(@"%@", error);
        }
    }];
    [dataTask resume];
}

- (NSMutableArray *)parseJSON:(NSArray *)JSON withType:(NSString *)JSONType
{
    NSMutableArray *parsedJSONArray = [NSMutableArray new];
    if ([JSONType isEqualToString:@"post"]) {
        for (NSDictionary *currentPost in JSON) {
            JWCRedditPost *newPost = [JWCRedditPost new];
            NSDictionary *postData = [currentPost objectForKey:@"data"];
            newPost.author = [postData objectForKey:@"author"];
            newPost.created = (NSInteger)[postData objectForKey:@"created"];
            newPost.downs = (NSInteger)[postData objectForKey:@"downs"];
            newPost.ups = (NSInteger)[postData objectForKey:@"ups"];
            newPost.postID = [postData objectForKey:@"id"];
            newPost.numberOfcomments = (NSInteger)[postData objectForKey:@"num_comments"];
            newPost.commentsLink = [postData objectForKey:@"permalink"];
            newPost.subreddit = [postData objectForKey:@"subreddit"];
            newPost.thumbnailURL = [NSURL URLWithString:[postData objectForKey:@"thumbnail"]];
            newPost.title = [postData objectForKey:@"title"];
            newPost.url = [postData objectForKey:@"url"];
            
            [parsedJSONArray addObject:newPost];
        }
    }
    
    if ([JSONType isEqualToString:@"subreddit"]) {
        for (NSDictionary *currentSubreddit in JSON) {
            JWCSubreddit *newSubreddit = [JWCSubreddit new];
            NSDictionary *subredditData = [currentSubreddit objectForKey:@"data"];
            newSubreddit.created = (NSInteger)[subredditData objectForKey:@"created"];
            newSubreddit.description = [subredditData objectForKey:@"description"];
            newSubreddit.displayName = [subredditData objectForKey:@"display_name"];
            newSubreddit.headerImage = [subredditData objectForKey:@"header_img"];
            newSubreddit.publicDescription = [subredditData objectForKey:@"public_description"];
            newSubreddit.title = [subredditData objectForKey:@"title"];
            newSubreddit.subscribers = (NSInteger)[subredditData objectForKey:@"subscribers"];
            newSubreddit.url = [subredditData objectForKey:@"url"];
            
            [parsedJSONArray addObject:newSubreddit];
        }
    }
    
    return  parsedJSONArray;
}

@end
