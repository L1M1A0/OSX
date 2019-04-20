//
//  ZBSlider.m
//  OSX
//
//  Created by LiZhenbiao on 2019/4/20.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import "ZBSlider.h"

@implementation ZBSlider


- (void)drawBarInside:(NSRect)rect flipped:(BOOL)flipped {
    [super drawBarInside:rect flipped:flipped];
    rect.size.height = 110;
    // Bar radius

    CGFloat barRadius = 2.5;
    CGFloat value = ([self doubleValue] - [self minValue]) / ([self maxValue] - [self minValue]);
    CGFloat finalWidth = value * ([[self controlView] frame].size.height - 4);
    NSRect leftRect = rect;
    leftRect.size.height = finalWidth;
    leftRect.origin.y = 110 -(finalWidth);
    NSBezierPath* bg = [NSBezierPath bezierPathWithRoundedRect: rect xRadius: barRadius yRadius: barRadius];    [NSColor.lightGrayColor setFill];
    [bg fill];
    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:leftRect xRadius:barRadius yRadius:barRadius];  // 设置线的填充色
    [NSColor.greenColor setFill];
    [bezierPath fill];
    
}
    

@end
