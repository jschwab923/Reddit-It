//
//  NSString+JWCSizeOfString.m
//  Reddit It
//
//  Created by Jeff Schwab on 4/12/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import "NSString+JWCSizeOfString.h"

@implementation NSString (JWCSizeOfString)

+ (CGSize)sizeOfString:(NSString *)string
             withCellWidth:(NSInteger)width
                labelWidth:(NSInteger)labelWidth
                  font:(NSString *)fontType
              fontSize:(NSInteger)fontSize
{
    // Get height of text
    UIFont *font = [UIFont fontWithName:fontType size:fontSize];
    CGSize textSize = CGSizeMake(labelWidth, MAXFLOAT);
    
    CGRect boundingRect = [string boundingRectWithSize:textSize
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil] context:nil];
    
    CGSize roundedSize = CGSizeMake(width, ceil(boundingRect.size.height));
    
    return roundedSize;
}

@end
