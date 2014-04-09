//
//  JWCViewControllerPostDetails.m
//  Reddit It
//
//  Created by Jeff Schwab on 4/6/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import "JWCViewControllerPostDetails.h"

@interface JWCViewControllerPostDetails ()

@end

@implementation JWCViewControllerPostDetails

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURLRequest *postRequest = [NSURLRequest requestWithURL:self.postURL];
    self.webViewPost.scalesPageToFit = YES;
    [self.webViewPost loadRequest:postRequest];
    
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(backSwipe:)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.webViewPost addGestureRecognizer:backSwipe];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backSwipe:(UISwipeGestureRecognizer *)backSwipe
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
