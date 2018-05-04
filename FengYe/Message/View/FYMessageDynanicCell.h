//
//  FYMessageDynanic.h
//  FengYe
//
//  Created by Alan Turing on 2018/4/18.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYMessageDynanicCell : UITableViewCell

//评论用户的头像
@property(nonatomic, retain) UIImageView* commentUserHeadIcon;
//评论用户的用户名
@property(nonatomic, retain) UILabel* commentUsername;
//评论时间
@property(nonatomic, retain) UILabel* commentTime;
//被评论用户的头像
@property(nonatomic, retain) UIImageView* myHeadIcon;
@end
