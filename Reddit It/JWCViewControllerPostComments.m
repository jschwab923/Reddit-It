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
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewComments;

@end

@implementation JWCViewControllerPostComments

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.redditController = [JWCRedditController new];
    self.redditController.delegate = self;
    
    [self.redditController getListOfCommentsFromPost:self.commentsURL];
    
    self.comments = [NSMutableArray new];
    
    self.collectionViewComments.dataSource = self;
    self.collectionViewComments.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finishedLoadingJSON:(NSArray *)JSON withAfter:(NSString *)after
{
    [self.redditController parseCommentTree:JSON withLevel:0 andCommentsArray:self.comments];
    [self.collectionViewComments reloadData];
    [self.collectionViewComments setNeedsLayout];
}

#pragma UICollectionViewDatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.comments count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JWCCollectionViewCellPostComment *currentCell = (JWCCollectionViewCellPostComment *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CommentCell" forIndexPath:indexPath];
    currentCell.clipsToBounds = NO;
    if ([self.comments count] > 0) {
        JWCPostComment *currentComment = self.comments[indexPath.row];
        NSInteger points = currentComment.ups - currentComment.downs;
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:currentComment.created] * -1;
        NSInteger created = interval/60/60;
        NSString *pointsString = [NSString stringWithFormat:@"%lu points %d hours ago", points, (int)created];
        NSString *commentInfo = [NSString stringWithFormat:@"%@ %@", currentComment.author, pointsString];
        
        currentCell.labelCommentInfo.text = commentInfo;
        currentCell.labelCommentText.text = currentComment.body;
        
//        int currentFarLeft;
//        switch (currentComment.level) {
//            case 0:
//                currentFarLeft = 0;
//                break;
//            default:
//                currentFarLeft = (CGRectGetWidth(self.collectionViewComments.frame)-CGRectGetWidth(currentCell.frame))/currentComment.level;
//                currentFarLeft *= -1;
//                break;
//        }
//        int count = 0;
//        for (int i = currentFarLeft; count < 3; i += 10, count++)
//        {
//            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(i, 0, 1, CGRectGetHeight(currentCell.frame)+10)];
//            line.backgroundColor = [UIColor colorWithRed:0.997 green:0.959 blue:1.000 alpha:1.000];
//            [currentCell addSubview:line];
//        }
    }
    return currentCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text;
    NSString *font;
    NSInteger fontSize;
    NSInteger heightAdjustment = 0;
    
    JWCPostComment *currentComment = self.comments[indexPath.row];
    
    NSInteger width = CGRectGetWidth(self.collectionViewComments.frame);
    font = @"Helvetica-Neue";
    fontSize = 18;
    
    JWCCollectionViewCellPostComment *currentCommentCell = (JWCCollectionViewCellPostComment *)[collectionView cellForItemAtIndexPath:indexPath];
    text = [NSString stringWithFormat:@"%@%@", currentCommentCell.labelCommentInfo, currentCommentCell.labelCommentText];
    heightAdjustment = 20;
    
    CGSize size = [NSString sizeOfString:text withCellWidth:width labelWidth:CGRectGetWidth(currentCommentCell.labelCommentText.frame) font:font fontSize:fontSize];
    if (size.height < 80) {
        size.height = 90;
    } else {
        size.height += heightAdjustment;
    }
    size.width -= 10 + currentComment.level*10;
    return size;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.collectionViewComments.collectionViewLayout invalidateLayout];
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
