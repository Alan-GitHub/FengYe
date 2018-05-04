//
//  FYDrawboardCell.h
//  FengYe
//
//  Created by Alan Turing on 2018/3/11.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYDrawboardCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *moduleCover;
@property (weak, nonatomic) IBOutlet UILabel *moduleName;
@property (weak, nonatomic) IBOutlet UILabel *worksNumsInModule;

@end
