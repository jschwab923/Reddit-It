//
//  NSString+JWCSizeOfString.h
//  Reddit It
//
//  Created by Jeff Schwab on 4/12/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JWCSizeOfString)

+ (CGSize)sizeOfString:(NSString *)string
         withCellWidth:(NSInteger)width
            labelWidth:(NSInteger)labelWidth
                  font:(NSString *)fontType
              fontSize:(NSInteger)fontSize;

@end
