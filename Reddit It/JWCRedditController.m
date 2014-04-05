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


#define SUBREDDIT_URL @"http://www.reddit.com/reddits/.json"
#define SUBREDDIT_AFTER_URL @"http://www.reddit.com/reddits/.json?after=%@"

@implementation JWCRedditController

//- (NSURL *)oauthURL
//{
//    self.state = @"stringthingstringping";
//
//    NSString *oauth = [NSString stringWithFormat:REDDIT_OAUTH, self.state, REDDIT_CLIENT_ID, REDDIT_REDIRECT_URI];
//    oauth = [oauth stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    NSURL *oauthURL = [NSURL URLWithString:oauth];
//    
//    return oauthURL;
//}
//
//- (void)requestAccessToken
//{
//    NSURL *accessTokenUrl = [NSURL URLWithString:@"https://ssl.reddit.com/api/v1/access_token?"];
//    
//    NSMutableURLRequest *accessTokenRequest = [NSMutableURLRequest requestWithURL:accessTokenUrl];
//    [accessTokenRequest setHTTPMethod:@"POST"];
////    [accessTokenRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
////    [accessTokenRequest setValue:self.state forHTTPHeaderField:@"state"];
////    [accessTokenRequest setValue:@"identity" forHTTPHeaderField:@"scope"];
////    [accessTokenRequest setValue:REDDIT_CLIENT_ID forHTTPHeaderField:@"client_id"];
////    [accessTokenRequest setValue:REDDIT_REDIRECT_URI forHTTPHeaderField:@"redirect_uri"];
////    [accessTokenRequest setValue:self.oauthCode forHTTPHeaderField:@"code"];
////    [accessTokenRequest setValue:@"authorization_code" forHTTPHeaderField:@"grant_type"];
//    
////    [accessTokenRequest setValue:REDDIT_CLIENT_ID forHTTPHeaderField:@"username"];
////    [accessTokenRequest setValue:REDDIT_SECRET forHTTPHeaderField:@"password"];
//
//    NSString *postDataString = [NSString stringWithFormat:@"grant_type=authorization_code&code=%@&redirect_uri=%@&username=%@&password=%@", self.oauthCode, REDDIT_REDIRECT_URI, REDDIT_CLIENT_ID, REDDIT_SECRET];
//    NSData *postData = [NSData dataWithBytes:[postDataString UTF8String]
//                                      length:[postDataString length]];
//    
//    [accessTokenRequest setHTTPBody:postData];
//    
//    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
//    
//    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:accessTokenRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        NSLog(@"%@ %@", responseJSON, error);
//    }];
//    [dataTask resume];
//}

- (void)getListOfSubreddits:(NSString *)afterParameter
{
    NSString *subbredditURL;
    if (afterParameter) {
        subbredditURL = [NSString stringWithFormat:SUBREDDIT_AFTER_URL, afterParameter];
    } else {
        subbredditURL = SUBREDDIT_URL;
    }
    
    NSURL *url = [NSURL URLWithString:subbredditURL];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            NSDictionary *dataDictionary = [responseJSON objectForKey:@"data"];
            NSArray *children = [dataDictionary objectForKey:@"children"];
            
            NSString *after = [dataDictionary objectForKey:@"after"];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate finishedLoadingSubredditList:children withAfter:after];
            });
        } else {
            NSLog(@"%@", error);
        }
    }];
    [dataTask resume];
    
}

@end
