//
//  FYScrollView.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/17.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYScrollView.h"

@implementation FYScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{

    return YES;
}

@end
