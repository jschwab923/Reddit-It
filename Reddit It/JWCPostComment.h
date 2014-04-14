//
//  JWCPostComment.h
//  Reddit It
//
//  Created by Jeff Schwab on 4/9/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JWCPostComment : NSObject

@property (nonatomic) NSString *body;
@property (nonatomic) NSString *author;
@property (nonatomic) NSInteger ups;
@property (nonatomic) NSInteger downs;
@property (nonatomic) NSInteger created;
@property (nonatomic) int level;

@end
