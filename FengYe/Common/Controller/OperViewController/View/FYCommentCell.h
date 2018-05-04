//
//  FYCommentCell.h
//  FengYe
//
//  Created by Alan Turing on 2018/4/16.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYCommentCell : UITableViewCell

//评论用户的头像
@property(nonatomic, retain) UIImageView* commentUserHeadIcon;
//评论用户的用户名
@property(nonatomic, retain) UILabel* commentUsername;
//评论内容
@property(nonatomic, retain) UILabel* commentText;
//评论时间
@property(nonatomic, retain) UILabel* commentTime;

@end
