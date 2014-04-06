//
//  JWCViewControllerOauth.m
//  Reddit It
//
//  Created by Jeff Schwab on 4/6/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import "JWCViewControllerOauth.h"
#import "JWCRedditController.h"

@interface JWCViewControllerOauth () <UIWebViewDelegate>

@property (nonatomic) JWCRedditController *redditController;
@property (strong, nonatomic) IBOutlet UIWebView *webViewOauth;

@end

@implementation JWCViewControllerOauth

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.redditController = [JWCRedditController new];
    
    self.webViewOauth.delegate = self;
    
    NSURL *oauthURL = [self.redditController oauthURL];
    
    NSURLRequest *oauthRequest = [NSURLRequest requestWithURL:oauthURL];
    [self.webViewOauth loadRequest:oauthRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSURL *url = self.webViewOauth.request.mainDocumentURL;
    NSString *urlQuery = [url query];
    
    NSString *urlHost = [url host];
    
    if ([urlHost isEqualToString:@"www.jeffwritescode.com"]) {
        NSMutableDictionary *queryDictionary = [NSMutableDictionary new];
        NSArray *splitURL = [urlQuery componentsSeparatedByString:@"&"];
        for (NSString *queryComponent in splitURL) {
            NSArray *keyAndValue = [queryComponent componentsSeparatedByString:@"="];
            [queryDictionary setObject:[keyAndValue lastObject] forKey:[keyAndValue firstObject]];
        }
        
        self.redditController.oauthCode = [queryDictionary objectForKey:@"code"];
        
        [self.redditController requestAccessToken];
    }
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
