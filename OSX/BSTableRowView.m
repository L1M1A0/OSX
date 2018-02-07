//
//  BSTableRowView.m
//  OSX
//
//  Created by 李振彪 on 2018/2/7.
//  Copyright © 2018年 李振彪. All rights reserved.
//

#import "BSTableRowView.h"

@implementation BSTableRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(void)drawSelectionInRect:(NSRect)dirtyRect{
//    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
//        NSRect selectionRect = NSInsetRect(self.bounds, 0, 0);
//        [[NSColor yellowColor] setFill];
//        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:0 yRadius:0];
//        [selectionPath fill];
//    }
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone ){
        NSRect selectionRect = NSInsetRect(self.bounds, 1, 1);
        
        [[NSColor colorWithWhite:0.9 alpha:1] setStroke];
        [[NSColor redColor] setFill];
        
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:selectionRect];
        [path fill];
        [path stroke];
    }
}

@end
