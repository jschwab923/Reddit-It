//
//  JWCRedditPost.h
//  Reddit It
//
//  Created by Jeff Schwab on 4/9/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JWCRedditPost : NSObject

@property (nonatomic) NSNumber *postID;
@property (nonatomic) NSInteger created;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *url;

@property (nonatomic) UIImage *thumbnail;
@property (nonatomic) NSURL *thumbnailURL;

@property (nonatomic) NSString *author;
@property (nonatomic) NSString *subreddit;

@property (nonatomic) NSInteger numberOfcomments;
@property (nonatomic) NSInteger ups;
@property (nonatomic) NSInteger downs;

@property (nonatomic) NSString *commentsLink;

@end
