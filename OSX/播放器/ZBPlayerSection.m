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
    NSInteger leftgap = 20;
    NSInteger topGap = 5;
    NSInteger rowHeight = ZBPlayerSectionHeight - 5 * 2;
    
    self.imageV = [[NSImageView alloc]initWithFrame:NSMakeRect(leftgap+leftgap*level, topGap, rowHeight, rowHeight)];
    self.imageV.wantsLayer = YES;
    self.imageV.layer.backgroundColor = [NSColor greenColor].CGColor;
    self.imageV.image = [NSImage imageNamed:@"list_hide"];
    //    self.imageV.action = @selector(imageViewAction:);
    //    self.imageV.target = self;
    //    self.imageV.editable = YES;
    [self addSubview:self.imageV];
    
    self.textV = [[NSTextField alloc]initWithFrame:NSMakeRect(leftgap+leftgap*level+rowHeight,topGap*2, 420, rowHeight-topGap*2)];
    self.textV.textColor = [NSColor whiteColor];
//    self.textV.wantsLayer = YES;
//    self.textV.layer.backgroundColor = [NSColor orangeColor].CGColor;
    self.textV.alignment = NSTextAlignmentLeft;
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
    [self imageViewAction];

}


-(void)setModel:(TreeNodeModel *)model{
    _model = model;
    self.textV.stringValue = model.name;
    
}

-(void)mouseDown:(NSEvent *)event{
    [NSApp sendAction:@selector(imageViewAction) to:self.imageV from:self];
}

-(void)imageViewAction{
    NSLog(@"self.model.isExpand_%d",self.model.isExpand);
    if (self.model.isExpand == NO) {
        self.imageV.image = [NSImage imageNamed:@"list_show"];
    }else{
        self.imageV.image = [NSImage imageNamed:@"list_hide"];
    }
}


@end
