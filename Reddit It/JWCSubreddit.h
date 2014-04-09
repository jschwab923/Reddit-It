//
//  JWCSubreddit.h
//  Reddit It
//
//  Created by Jeff Schwab on 4/9/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JWCSubreddit : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *displayName;
@property (nonatomic) NSString *headerImage;
@property (nonatomic) NSString *description;
@property (nonatomic) NSString *publicDescription;
@property (nonatomic) NSInteger subscribers;
@property (nonatomic) NSInteger created;
@property (nonatomic) NSString *url;

@end
