//
//  FYMessagePrivateDetailCell.h
//  FengYe
//
//  Created by Alan Turing on 2018/4/21.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYMessagePrivateDetailCell : UITableViewCell

//留言用户的头像
@property(nonatomic, retain) UIImageView* privMsgUserHeadIcon;

//留言内容
@property(nonatomic, retain) UILabel* privMsgContent;

//我的头像
@property(nonatomic, retain) UIImageView* myUserHeadIcon;

//cell上部占位视图
@property(nonatomic, retain) UILabel* placeholderView1;
//cell下部占位视图
@property(nonatomic, retain) UILabel* placeholderView2;

@end
