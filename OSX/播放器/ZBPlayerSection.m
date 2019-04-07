//
//  ZBPlayerSection.m
//  OSX
//
//  Created by LiZhenbiao on 2019/4/7.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import "ZBPlayerSection.h"

@implementation ZBPlayerSection

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
    self.imageV.image = [NSImage imageNamed:@"arrow_gray_right.png"];
    //    self.imageV.action = @selector(imageViewAction:);
    //    self.imageV.target = self;
    //    self.imageV.editable = YES;
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
    
    //    self.wantsLayer = YES;
    //    if(self.isSelected == YES){
    //        self.layer.backgroundColor = [NSColor brownColor].CGColor;
    //    }else{
    //        self.layer.backgroundColor = [NSColor orangeColor].CGColor;
    //    }
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


-(void)setModel:(TreeNodeModel *)model{
    _model = model;
    self.textV.stringValue = model.name;
    
}

-(void)mouseDown:(NSEvent *)event{
    [NSApp sendAction:@selector(imageViewAction) to:self.imageV from:self];
}

-(void)imageViewAction{
    if (self.model.isExpand == YES) {
        self.imageV.image = [NSImage imageNamed:@"arrow_gray_down.png"];
    }else{
        self.imageV.image = [NSImage imageNamed:@"arrow_gray_right.png"];
    }
    
}


@end
