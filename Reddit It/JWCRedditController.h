//
//  JWCRedditController.h
//  Reddit It
//
//  Created by Jeff Schwab on 4/5/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWCRedditPost.h"
#import "JWCSubreddit.h"
#import "JWCPostComment.h"

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


- (NSURL *)oauthURL;
- (void)requestAccessToken;

- (void)getListOfPostsWithSection:(NSString *)section after:(NSString *)after count:(NSInteger)count;
- (void)getListOfSubredditsWithType:(NSString *)type after:(NSString *)afterParameter count:(NSInteger)count;
- (void)searchSubredditsWithQuery:(NSString *)query;
- (void)getListOfPostsFromSubreddit:(NSString *)subreddit withAfter:(NSString *)after count:(NSInteger)count;
- (void)getListOfCommentsFromPost:(NSString *)commentsURL;

- (void)downloadThumbnailImage:(NSURL *)thumbnailURL andID:(NSNumber *)postID;
- (void)parseCommentTree:(NSArray *)JSON withLevel:(int)level andCommentsArray:(NSMutableArray *)comments;

- (NSMutableArray *)parseJSON:(NSArray *)JSON withType:(NSString *)JSONType;
@end
