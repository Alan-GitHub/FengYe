//
//  FYMessageDynanic.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/18.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYMessageDynanicCell.h"
#import <Masonry.h>

#define CommentUserHeadIconHeight 40
#define Spacing 10


@implementation FYMessageDynanicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//重写
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //评论用户头像
        [self.contentView addSubview:self.commentUserHeadIcon];
        self.commentUserHeadIcon.backgroundColor = [UIColor greenColor];
        [self.commentUserHeadIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(Spacing);
            make.left.equalTo(self.contentView.mas_left).with.offset(Spacing);
            make.width.mas_equalTo(CommentUserHeadIconHeight);
            make.height.mas_equalTo(CommentUserHeadIconHeight);
        }];
        
        //用户名关注
        [self.contentView addSubview:self.commentUsername];
        self.commentUsername.backgroundColor = [UIColor redColor];
        [self.commentUsername mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.commentUserHeadIcon.mas_top).with.offset(0);
            make.left.equalTo(self.commentUserHeadIcon.mas_right).with.offset(Spacing*2);
            make.right.equalTo(self.contentView.mas_right).with.offset(-CommentUserHeadIconHeight-Spacing*3);
            make.height.mas_equalTo(Spacing*2);
        }];
        
        //时间
        [self.contentView addSubview:self.commentTime];
        self.commentTime.backgroundColor = [UIColor grayColor];
        [self.commentTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.commentUsername.mas_left).with.offset(0);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-5);
            make.right.equalTo(self.commentUsername.mas_right).with.offset(0);
            make.height.mas_equalTo(Spacing);
        }];
        
        //被评论用户的头像
        [self.contentView addSubview:self.myHeadIcon];
        self.myHeadIcon.backgroundColor = [UIColor greenColor];
        [self.myHeadIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.commentUserHeadIcon.mas_top).with.offset(0);
            make.right.equalTo(self.contentView.mas_right).with.offset(-Spacing);
            make.width.mas_equalTo(CommentUserHeadIconHeight);
            make.height.mas_equalTo(CommentUserHeadIconHeight);
        }];
        
    }
    return self;
}

//评论用户的头像
- (UIImageView*) commentUserHeadIcon{
    
    if (!_commentUserHeadIcon) {
        
        _commentUserHeadIcon = [[UIImageView alloc] init];
    }
    
    return _commentUserHeadIcon;
}

//评论用户的用户名
- (UILabel*) commentUsername{
    
    if (!_commentUsername) {
        
        _commentUsername = [[UILabel alloc] init];
    }
    
    return _commentUsername;
}

//评论时间
- (UILabel*) commentTime{
    
    if (!_commentTime) {
        
        _commentTime = [[UILabel alloc] init];
    }
    
    return _commentTime;
}

//被评论用户的头像
- (UIImageView*) myHeadIcon{
    
    if (!_myHeadIcon) {
        
        _myHeadIcon = [[UIImageView alloc] init];
    }
    
    return _myHeadIcon;
}

@end
