//
//  JWCCollectionViewCellSubreddit.h
//  Reddit It
//
//  Created by Jeff Schwab on 4/5/14.
//  Copyright (c) 2014 Jeff Writes Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWCCollectionViewCellSubreddit : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageViewHeaderImage;
@property (strong, nonatomic) IBOutlet UILabel *labelSubredditTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;

@end
