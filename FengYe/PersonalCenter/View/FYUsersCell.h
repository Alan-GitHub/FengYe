//
//  FYUsersCell.h
//  FengYe
//
//  Created by Alan Turing on 2018/3/17.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYUsersCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userHeadIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *fansNums;

@end
