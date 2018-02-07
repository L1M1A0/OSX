//
//  BSTableCellView.m
//  OSX
//
//  Created by 李振彪 on 2018/2/7.
//  Copyright © 2018年 李振彪. All rights reserved.
//

#import "BSTableCellView.h"

@implementation BSTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    [super setBackgroundStyle:backgroundStyle];
    if(backgroundStyle == NSBackgroundStyleDark)
    {
        self.layer.backgroundColor = [NSColor yellowColor].CGColor;
    }
    else
    {
        self.layer.backgroundColor = [NSColor whiteColor].CGColor;
    }
}

@end
