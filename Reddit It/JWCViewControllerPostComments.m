//
//  JWCViewControllerPostComments.m
//  Reddit It
//
//  Created by Jeff Schwab on 4/9/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import "JWCViewControllerPostComments.h"
#import "JWCRedditController.h"
#import "JWCCollectionViewCellPostComment.h"
#import "NSString+JWCSizeOfString.h"

@interface JWCViewControllerPostComments ()
<JWCRedditControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

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

#pragma UICollectionViewDatasource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JWCCollectionViewCellPostComment *currentCell = (JWCCollectionViewCellPostComment *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CommentCell" forIndexPath:indexPath];
    return currentCell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *text;
//    NSString *font;
//    NSInteger fontSize;
//    NSInteger heightAdjustment = 0;
//    
//    NSInteger width = CGRectGetWidth(self.col.frame);
//    font = @"Helvetica-Neue";
//    fontSize = 18;
//    
//    JWCCollectionViewCellPostComment *currentCommentCell = (JWCCollectionViewCellPostComment *)[collectionView cellForItemAtIndexPath:indexPath];
//    text = [NSString stringWithFormat:@"%@%@", currentCommentCell];
//    heightAdjustment = 20;
//    
//    CGSize size = [NSString sizeOfString:text withWidth:width font:font fontSize:fontSize];
//    if (size.height < 80) {
//        size.height = 90;
//    } else {
//        size.height += heightAdjustment;
//    }
//    size.width -= 10;
//    return size;
//}

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
