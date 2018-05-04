//
//  FYDrawboardCellAdd.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/25.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYDrawboardCellAdd.h"

@implementation FYDrawboardCellAdd

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    //设置cell的边框颜色
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1;
}

@end
