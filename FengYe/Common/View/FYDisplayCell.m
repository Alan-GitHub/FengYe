//
//  FYDisplayCell.m
//  FengYe
//
//  Created by Alan Turing on 2017/12/17.
//  Copyright © 2017年 Alan Turing. All rights reserved.
//

#import "FYDisplayCell.h"

@interface FYDisplayCell()


@end

@implementation FYDisplayCell

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    //
    CGRect rect =  self.descriptionLabel.frame;
    rect.size = CGSizeMake(self.descriptionLabel.bounds.size.width, self.descriptionLabel.bounds.size.height);
    self.descriptionLabel.frame = rect;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
