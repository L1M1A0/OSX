//
//  ZBPlayerSplitView.m
//  OSX
//
//  Created by LiZhenbiao on 2019/4/16.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import "ZBPlayerSplitView.h"

@implementation ZBPlayerSplitView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)drawDividerInRect:(NSRect)rect{
//    NSRect selectionRect = NSMakeRect(rect.origin.x, rect.origin.y, 20, rect.size.height);//NSInsetRect(rect, 1, 1);
    
    [[NSColor colorWithWhite:0.9 alpha:1] setStroke];
    [[NSColor colorWithCalibratedRed:0x22/255.0 green:0x22/255.0 blue:0x22/255.0 alpha:0xFF/255.0] setFill];
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    [path fill];
    [path stroke];
}

@end
