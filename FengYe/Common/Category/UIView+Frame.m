//
//  UIView+Frame.m
//  ImitateBaiSi
//
//  Created by Alan.Turing on 17/5/1.
//  Copyright © 2017年 HYH. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (CGFloat) fy_x
{
    return self.frame.origin.x;
}

- (void) setFy_x:(CGFloat)fy_x
{
    CGRect rect = self.frame;
    rect.origin.x = fy_x;
    
    self.frame = rect;
}

- (CGFloat) fy_y
{
    return self.frame.origin.y;
}

- (void) setFy_y:(CGFloat)fy_y
{
    CGRect rect = self.frame;
    rect.origin.y = fy_y;
    
    self.frame = rect;
}

- (CGFloat) fy_centerX
{
    return self.center.x;
}

- (void) setFy_centerX:(CGFloat)fy_centerX
{
    CGPoint center = self.center;
    center.x = fy_centerX;
    
    self.center = center;
}

- (CGFloat) fy_centerY
{
    return self.center.y;
}

- (void) setFy_centerY:(CGFloat)fy_centerY
{
    CGPoint center = self.center;
    center.y = fy_centerY;
    
    self.center=  center;
}

- (CGFloat) fy_width
{
    return self.frame.size.width;
}

- (void) setFy_width:(CGFloat)fy_width
{
    CGRect rect = self.frame;
    rect.size.width = fy_width;
    
    self.frame = rect;
}

- (CGFloat) fy_height
{
    return self.frame.size.height;
}

- (void) setFy_height:(CGFloat)fy_height
{
    CGRect rect = self.frame;
    rect.size.height = fy_height;
    
    self.frame = rect;
}


@end
