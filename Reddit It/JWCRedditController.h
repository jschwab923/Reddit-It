//
//  JWCRedditController.h
//  Reddit It
//
//  Created by Jeff Schwab on 4/5/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JWCRedditControllerDelegate <NSObject>

@required
- (void)finishedLoadingJSON:(NSArray *)JSON withAfter:(NSString *)after;

@optional
- (void)finishedDownloadingImageWithData:(NSData *)imageData andID:(NSString *)id;

@end

@interface JWCRedditController : NSObject

@property (unsafe_unretained) id<JWCRedditControllerDelegate> delegate;

@property (nonatomic) NSString *oauthCode;
@property (nonatomic) NSString *state;

//- (NSURL *)oauthURL;
//- (void)requestAccessToken;

- (void)getListOfSubredditsWithType:(NSString *)type after:(NSString *)afterParameter count:(NSInteger)count;
- (void)searchSubredditsWithQuery:(NSString *)query;
- (void)getListOfPostsFromSubreddit:(NSString *)subreddit;
- (void)downloadThumbnailImage:(NSDictionary *)JSON;

@end
