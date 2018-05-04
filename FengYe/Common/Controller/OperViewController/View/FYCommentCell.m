//
//  FYCommentCell.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/16.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYCommentCell.h"
#import "CommonAttr.h"
#import <Masonry.h>
#import "UIView+Frame.h"

#define CommentUserHeadIconHeight 40
#define Spacing 10

@implementation FYCommentCell

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
        [self.contentView addSubview:self.commentUserHeadIcon];
        self.commentUserHeadIcon.backgroundColor = [UIColor greenColor];
        [self.commentUserHeadIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(Spacing);
            make.left.equalTo(self.contentView.mas_left).with.offset(Spacing);
            make.width.mas_equalTo(CommentUserHeadIconHeight);
            make.height.mas_equalTo(CommentUserHeadIconHeight);
        }];

        //用户名
        [self.contentView addSubview:self.commentUsername];
        self.commentUsername.backgroundColor = [UIColor redColor];
        [self.commentUsername mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.commentUserHeadIcon.mas_top).with.offset(0);
            make.left.equalTo(self.commentUserHeadIcon.mas_right).with.offset(Spacing*2);
            make.right.equalTo(self.contentView.mas_right).with.offset(0);
            make.height.mas_equalTo(Spacing);
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

        //内容
        [self.contentView addSubview:self.commentText];
        self.commentText.numberOfLines = 0;
        self.commentText.backgroundColor = [UIColor yellowColor];
        [self.commentText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.commentUsername.mas_bottom).with.offset(5);
            make.left.equalTo(self.commentUsername.mas_left).with.offset(0);
            make.bottom.equalTo(self.commentTime.mas_top).with.offset(-5);
            make.right.equalTo(self.commentUsername.mas_right).with.offset(0);
        }];
        
    }
    return self;
}

//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//
//    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//
//        //头像
//        [self.contentView addSubview:self.commentUserHeadIcon];
//        self.commentUserHeadIcon.backgroundColor = [UIColor greenColor];
//        [self.commentUserHeadIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.contentView.mas_top).with.offset(Spacing);
//            make.left.equalTo(self.contentView.mas_left).with.offset(Spacing);
//            make.width.mas_equalTo(CommentUserHeadIconHeight);
//            make.height.mas_equalTo(CommentUserHeadIconHeight);
//        }];
//
//        //用户名
//        [self.contentView addSubview:self.commentUsername];
//        self.commentUsername.backgroundColor = [UIColor redColor];
//        [self.commentUsername mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.commentUserHeadIcon.mas_top).with.offset(0);
//            make.left.equalTo(self.commentUserHeadIcon.mas_right).with.offset(Spacing*2);
//            make.right.equalTo(self.contentView.mas_right).with.offset(0);
//            make.height.mas_equalTo(Spacing);
//        }];
//
//        //内容
//        [self.contentView addSubview:self.commentText];
//        self.commentText.numberOfLines = 0;
//        self.commentText.backgroundColor = [UIColor yellowColor];
//        [self.commentText mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.commentUsername.mas_bottom).with.offset(Spacing);
//            make.left.equalTo(self.commentUsername.mas_left).with.offset(0);
//            make.right.equalTo(self.commentUsername.mas_right).with.offset(0);
//            make.height.mas_equalTo(Spacing*3);
//        }];
//
//        //时间
//        [self.contentView addSubview:self.commentTime];
//        self.commentTime.backgroundColor = [UIColor grayColor];
//        [self.commentTime mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.commentText.mas_bottom).with.offset(Spacing);
//            make.left.equalTo(self.commentUsername.mas_left).with.offset(0);
//            make.right.equalTo(self.commentUsername.mas_right).with.offset(0);
//            make.height.mas_equalTo(Spacing);
//        }];
//    }
//    return self;
//}

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

//评论内容
- (UILabel*) commentText{
    
    if (!_commentText) {
        
        _commentText = [[UILabel alloc] init];
    }
    
    return _commentText;
    
}

//评论时间
- (UILabel*) commentTime{
    
    if (!_commentTime) {
        
        _commentTime = [[UILabel alloc] init];
    }
    
    return _commentTime;
    
}

@end
