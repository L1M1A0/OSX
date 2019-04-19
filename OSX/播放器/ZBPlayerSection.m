//
//  ZBPlayerSection.m
//  OSX
//
//  Created by LiZhenbiao on 2019/4/7.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import "ZBPlayerSection.h"
#import "Masonry.h"

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
    
    self.imageV = [[NSImageView alloc]initWithFrame:NSZeroRect];
    self.imageV.wantsLayer = YES;
    self.imageV.layer.backgroundColor = [NSColor greenColor].CGColor;
    self.imageV.image = [NSImage imageNamed:@"list_hide"];
    //    self.imageV.action = @selector(imageViewAction:);
    //    self.imageV.target = self;
    //    self.imageV.editable = YES;
    [self addSubview:self.imageV];
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(leftgap+leftgap*level);
        make.top.equalTo(self.mas_top).offset(topGap);
        make.width.mas_equalTo(rowHeight);
        make.bottom.equalTo(self.mas_bottom).offset(-topGap);
    }];

    
    self.textV = [[NSTextField alloc]initWithFrame:NSZeroRect];
    self.textV.textColor = [NSColor whiteColor];
    self.textV.alignment = NSTextAlignmentLeft;
    [self.textV setBezeled:NO];
    [self.textV setDrawsBackground:NO];
    [self.textV setEditable:NO];
//    [[self.textV cell] setLineBreakMode:NSLineBreakByCharWrapping];
//    [[self.textV cell] setTruncatesLastVisibleLine:YES];
//    self.textV.wantsLayer = YES;
//    self.textV.layer.backgroundColor = [NSColor orangeColor].CGColor;
//    self.textV.stringValue = @"";
//    self.textV.backgroundColor = [NSColor cyanColor];
    [self addSubview:self.textV];
    
    [self.textV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topGap*2);
        make.left.equalTo(self.imageV.mas_right).offset(topGap);
        make.height.mas_equalTo(rowHeight-topGap*2);
        make.right.equalTo(self.mas_right).offset(-10);
    }];

    
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
