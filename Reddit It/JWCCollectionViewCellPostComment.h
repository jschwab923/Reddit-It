//
//  JWCCollectionViewCellPostComment.h
//  Reddit It
//
//  Created by Jeff Schwab on 4/12/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWCCollectionViewCellPostComment : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelCommentInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelCommentText;

@end
