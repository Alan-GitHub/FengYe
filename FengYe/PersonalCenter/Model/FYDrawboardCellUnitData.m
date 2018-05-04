//
//  FYDrawboardCellUnitData.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/23.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYDrawboardCellUnitData.h"

@implementation FYDrawboardCellUnitData

- (NSString *)description{
    
    NSMutableString* str = [NSMutableString string];
    
    [str appendFormat:@"coverImageURL=%@\n", self.coverImageURL];
    [str appendFormat:@"drawboardName=%@\n", self.drawboardName];
    [str appendFormat:@"descriptionText=%@\n", self.descriptionText];
    [str appendFormat:@"ownerHeadIcon=%@\n", self.ownerHeadIcon];
    [str appendFormat:@"ownerUserName=%@\n", self.ownerUserName];
    
    [str appendFormat:@"coverImageWidth=%zd\n", self.coverImageWidth];
    [str appendFormat:@"coverImageHeight=%zd\n", self.coverImageHeight];
    [str appendFormat:@"attentionNum=%zd\n", self.attentionNum];
//    [str appendFormat:@"forwardNum=%zd\n", self.forwardNum];
    [str appendFormat:@"picNums=%zd\n", self.picNums];
    
    return str;
}
@end
