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
- (void)finishedLoadingSubredditList:(NSArray *)subreddits withAfter:(NSString *)after;
@end

@interface JWCRedditController : NSObject

@property (unsafe_unretained) id<JWCRedditControllerDelegate> delegate;

@property (nonatomic) NSString *oauthCode;
@property (nonatomic) NSString *state;

//- (NSURL *)oauthURL;
//- (void)requestAccessToken;

- (void)getListOfSubreddits:(NSString *)nextParameter;

@end
