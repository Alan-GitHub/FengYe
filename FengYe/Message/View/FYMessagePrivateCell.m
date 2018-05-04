//
//  FYMessagePrivate.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/19.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYMessagePrivateCell.h"
#import <Masonry.h>

#define CommentUserHeadIconHeight 40
#define Spacing 10

@implementation FYMessagePrivateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //头像
        [self.contentView addSubview:self.privMsgUserHeadIcon];
//        self.privMsgUserHeadIcon.backgroundColor = [UIColor greenColor];
        [self.privMsgUserHeadIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(Spacing);
            make.left.equalTo(self.contentView.mas_left).with.offset(Spacing);
            make.width.mas_equalTo(CommentUserHeadIconHeight);
            make.height.mas_equalTo(CommentUserHeadIconHeight);
        }];
        
        //用户名
        [self.contentView addSubview:self.privMsgUsername];
//        self.privMsgUsername.backgroundColor = [UIColor redColor];
        [self.privMsgUsername mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.privMsgUserHeadIcon.mas_top).with.offset(0);
            make.left.equalTo(self.privMsgUserHeadIcon.mas_right).with.offset(Spacing*2);
            make.right.equalTo(self.contentView.mas_right).with.offset(0);
            make.height.mas_equalTo(15);
        }];
        
        //时间
        [self.contentView addSubview:self.privMsgTime];
//        self.privMsgTime.backgroundColor = [UIColor grayColor];
        [self.privMsgTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.privMsgUsername.mas_left).with.offset(0);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-5);
            make.right.equalTo(self.privMsgUsername.mas_right).with.offset(0);
            make.height.mas_equalTo(Spacing);
        }];
        
        //内容
        [self.contentView addSubview:self.privMsgContent];
//        self.privMsgContent.backgroundColor = [UIColor yellowColor];
        [self.privMsgContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.privMsgUsername.mas_bottom).with.offset(3);
            make.left.equalTo(self.privMsgUsername.mas_left).with.offset(0);
            make.bottom.equalTo(self.privMsgTime.mas_top).with.offset(-3);
            make.right.equalTo(self.privMsgUsername.mas_right).with.offset(0);
        }];
        
    }
    return self;
}

//私信用户的头像
- (UIImageView*) privMsgUserHeadIcon{
    
    if (!_privMsgUserHeadIcon) {
        
        _privMsgUserHeadIcon = [[UIImageView alloc] init];
    }
    
    return _privMsgUserHeadIcon;
}

//私信用户的用户名
- (UILabel*) privMsgUsername{
    
    if (!_privMsgUsername) {
        
        _privMsgUsername = [[UILabel alloc] init];
    }
    
    return _privMsgUsername;
}

//私信内容
- (UILabel*) privMsgContent{
    
    if (!_privMsgContent) {
        
        _privMsgContent = [[UILabel alloc] init];
    }
    
    return _privMsgContent;
}

//私信时间
- (UILabel*) privMsgTime{
    
    if (!_privMsgTime) {
        
        _privMsgTime = [[UILabel alloc] init];
    }
    
    return _privMsgTime;
}

@end
