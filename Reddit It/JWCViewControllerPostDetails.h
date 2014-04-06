//
//  JWCViewControllerPostDetails.h
//  Reddit It
//
//  Created by Jeff Schwab on 4/6/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWCViewControllerPostDetails : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webViewPost;
@property (strong, nonatomic) NSURL *postURL;

@end
