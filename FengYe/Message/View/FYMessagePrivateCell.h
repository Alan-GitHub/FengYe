//
//  FYMessagePrivate.h
//  FengYe
//
//  Created by Alan Turing on 2018/4/19.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYMessagePrivateCell : UITableViewCell

//私信用户的头像
@property(nonatomic, retain) UIImageView* privMsgUserHeadIcon;
//私信用户的用户名
@property(nonatomic, retain) UILabel* privMsgUsername;
//私信内容
@property(nonatomic, retain) UILabel* privMsgContent;
//私信时间
@property(nonatomic, retain) UILabel* privMsgTime;

@end
