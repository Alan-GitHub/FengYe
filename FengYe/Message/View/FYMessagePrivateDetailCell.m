//
//  FYMessagePrivateDetailCell.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/21.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYMessagePrivateDetailCell.h"
#import <Masonry.h>
#import "CommonAttr.h"

#define CommentUserHeadIconHeight 40
#define Spacing 10

@implementation FYMessagePrivateDetailCell

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
        
        //留言用户头像
        [self.contentView addSubview:self.privMsgUserHeadIcon];
//        self.privMsgUserHeadIcon.backgroundColor = [UIColor greenColor];
        [self.privMsgUserHeadIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(Spacing);
            make.left.equalTo(self.contentView.mas_left).with.offset(Spacing);
            make.width.mas_equalTo(CommentUserHeadIconHeight);
            make.height.mas_equalTo(CommentUserHeadIconHeight);
        }];
        
        //我的头像
        [self.contentView addSubview:self.myUserHeadIcon];
//        self.myUserHeadIcon.backgroundColor = [UIColor greenColor];
        [self.myUserHeadIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.privMsgUserHeadIcon.mas_top).with.offset(0);
            make.right.equalTo(self.contentView.mas_right).with.offset(-Spacing);
            make.width.mas_equalTo(CommentUserHeadIconHeight);
            make.height.mas_equalTo(CommentUserHeadIconHeight);
        }];
        
        //cell上部占位视图
        [self.contentView addSubview:self.placeholderView1];
//        self.placeholderView1.backgroundColor = [UIColor redColor];
        self.placeholderView1.numberOfLines = 0;
        [self.placeholderView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.privMsgUserHeadIcon.mas_top).with.offset(0);
            make.left.equalTo(self.privMsgUserHeadIcon.mas_right).with.offset(Spacing);
            make.right.equalTo(self.contentView.mas_right).with.offset((-CommentUserHeadIconHeight-Spacing*2));
            make.height.mas_equalTo(Spacing);
        }];
        
        //cell下部占位视图
        [self.contentView addSubview:self.placeholderView2];
//        self.placeholderView2.backgroundColor = [UIColor grayColor];
        [self.placeholderView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.placeholderView1.mas_left).with.offset(0);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-5);
            make.right.equalTo(self.placeholderView1.mas_right).with.offset(0);
            make.height.mas_equalTo(Spacing);
        }];
        
        //留言内容
        [self.contentView addSubview:self.privMsgContent];
//        self.privMsgContent.backgroundColor = [UIColor yellowColor];
        self.privMsgContent.numberOfLines = 0;
        [self.privMsgContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.placeholderView1.mas_bottom).with.offset(5);
            make.left.equalTo(self.placeholderView1.mas_left).with.offset(0);
            make.bottom.equalTo(self.placeholderView2.mas_top).with.offset(-5);
            make.width.mas_equalTo(ScreenWidth*2/3);
        }];
        
    }
    return self;
}

//我的头像
- (UIImageView*) myUserHeadIcon{
    
    if (!_myUserHeadIcon) {
        
        _myUserHeadIcon = [[UIImageView alloc] init];
    }
    
    return _myUserHeadIcon;
}

//留言用户的头像
- (UIImageView*) privMsgUserHeadIcon{
    
    if (!_privMsgUserHeadIcon) {
        
        _privMsgUserHeadIcon = [[UIImageView alloc] init];
    }
    
    return _privMsgUserHeadIcon;
}

//留言内容
- (UILabel*) privMsgContent{
    
    if (!_privMsgContent) {
        
        _privMsgContent = [[UILabel alloc] init];
    }
    
    return _privMsgContent;
}

//cell上部占位视图
- (UILabel*) placeholderView1{
    
    if (!_placeholderView1) {
        
        _placeholderView1 = [[UILabel alloc] init];
    }
    
    return _placeholderView1;
}

//cell下部占位视图
- (UILabel*) placeholderView2{
    
    if (!_placeholderView2) {
        
        _placeholderView2 = [[UILabel alloc] init];
    }
    
    return _placeholderView2;
}


@end
