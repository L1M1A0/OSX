//
//  SecondWCtrl.m
//  OSX
//
//  Created by 李振彪 on 2017/6/14.
//  Copyright © 2017年 李振彪. All rights reserved.
//

#import "SecondWCtrl.h"

@interface SecondWCtrl ()

@end

@implementation SecondWCtrl

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    
//    NSRect frame = CGRectMake(0,0,200,200);
//    NSUInteger style =  NSTitledWindowMask | NSClosableWindowMask |NSMiniaturizableWindowMask | NSResizableWindowMask;
//    self.window = [[NSWindow alloc]initWithContentRect:frame styleMask:style backing:NSBackingStoreBuffered defer:YES];
//    self.window.title = @"New Create Window";
//    self.window.backgroundColor = [NSColor redColor];
//    //窗口显示
//    [self.window makeKeyAndOrderFront:self];
//    //窗口居中
//    [self.window center];
    
    [self addView];

}

-(void)addView{
//    [self button:NSMakeRect(100, 100, 100, 100) superView:self.window.contentView tag:0 type:NSButtonTypePushOnPushOff];
    
}
#pragma mark - NSButton
- (NSButton *)button:(NSRect)frame superView:(NSView *)superView tag:(NSInteger)tag type:(NSButtonType)type{
    NSButton *btn = [[NSButton alloc]init];
    btn.frame = frame;//NSRectMake
    btn.alignment = NSTextAlignmentCenter;
    btn.toolTip = @"这是一个按钮";
    btn.bezelStyle = NSBezelStyleRounded;
    btn.tag = tag;
    btn.target = self;
    btn.action = @selector(btnAction:);
    [superView addSubview:btn];
    
    //以下设置中，随着title和image的代码位置不同，在界面上的显示效果也不同
    btn.bordered = YES;//是否带边框
    btn.title = @"NSButton哦";

    [btn setButtonType:type];//             = 6,
    //设置按钮初始选中状态，1：选中
    //    btn.state = 1;
    
    return btn;
}

#pragma mark NSButton action
-(void)btnAction:(NSButton *)sender{
    
}
@end
