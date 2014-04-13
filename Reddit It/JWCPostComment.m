//
//  JWCPostComment.m
//  Reddit It
//
//  Created by Jeff Schwab on 4/9/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import "JWCPostComment.h"

@implementation JWCPostComment

- (NSString *)description
{
    NSString *padding = [@"" stringByPaddingToLength:self.level withString:@"_" startingAtIndex:0];
    NSString *descriptionString = [NSString stringWithFormat:@"%@%@%@", padding, self.body, self.author];
    return descriptionString;
}

@end