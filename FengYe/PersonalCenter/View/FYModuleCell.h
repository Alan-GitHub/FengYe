//
//  FYModuleCell.h
//  FengYe
//
//  Created by Alan Turing on 2018/3/17.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYModuleCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *drawboardName;
@property (weak, nonatomic) IBOutlet UILabel *ownerUserName;

@end
