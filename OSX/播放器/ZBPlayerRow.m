//
//  ZBPlayerRow.m
//  OSX
//
//  Created by LiZhenbiao on 2019/4/7.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import "ZBPlayerRow.h"

@implementation ZBPlayerRow

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(instancetype)initWithLevel:(NSInteger)level{
    if(self = [super init]){
        [self creatViewWithLevel:level];
    }
    return self;
}



-(void)creatViewWithLevel:(NSInteger)level{
    self.imageV = [[NSImageView alloc]initWithFrame:NSMakeRect(30+30*level, 5, 50, 40)];
    self.imageV.wantsLayer = YES;
    self.imageV.layer.backgroundColor = [NSColor greenColor].CGColor;
    self.imageV.image = [NSImage imageNamed:@"docx.png"];
    [self addSubview:self.imageV];
    
    self.textV = [[NSTextField alloc]initWithFrame:NSMakeRect(30+30*level+50, 10, 420, 40)];
    self.textV.textColor = [NSColor blackColor];
    [self.textV setBezeled:NO];
    [self.textV setDrawsBackground:NO];
    [self.textV setEditable:NO];
    self.textV.stringValue = @"textView";
    //    self.textV.wantsLayer = YES;
    self.textV.backgroundColor = [NSColor cyanColor];
    [self addSubview:self.textV];
    

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
        [[NSColor greenColor] setFill];
        
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:selectionRect];
        [path fill];
        [path stroke];
    }
}


-(void)setModel:(TreeNodeModel *)model{
    _model = model;
    self.textV.stringValue = model.name;
    
}
@end
