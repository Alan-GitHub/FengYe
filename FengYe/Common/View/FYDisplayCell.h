//
//  FYDisplayCell.h
//  FengYe
//
//  Created by Alan Turing on 2017/12/17.
//  Copyright © 2017年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYDisplayCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *workImage;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *zhuanCaiLabel;
@property (weak, nonatomic) IBOutlet UILabel *loveLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerIcon;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *workModuleLabel;

@property (weak, nonatomic) IBOutlet UIView *isOperation;

@end
