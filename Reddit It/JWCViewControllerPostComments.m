//
//  JWCViewControllerPostComments.m
//  Reddit It
//
//  Created by Jeff Schwab on 4/9/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import "JWCViewControllerPostComments.h"
#import "JWCRedditController.h"

@interface JWCViewControllerPostComments () <JWCRedditControllerDelegate>

@property (nonatomic) JWCRedditController *redditController;
@property (nonatomic) NSMutableArray *comments;

@end

@implementation JWCViewControllerPostComments

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.redditController = [JWCRedditController new];
    self.redditController.delegate = self;
    
    [self.redditController getListOfCommentsFromPost:self.commentsURL];
    
    self.comments = [NSMutableArray new];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finishedLoadingJSON:(NSArray *)JSON withAfter:(NSString *)after
{
    [self.redditController parseCommentTree:JSON withLevel:0 andCommentsArray:self.comments];
    NSLog(@"%@", self.comments);    
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
