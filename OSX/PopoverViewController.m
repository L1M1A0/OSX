//
//  PopoverViewController.m
//  OSX
//
//  Created by 李振彪 on 2017/6/9.
//  Copyright © 2017年 李振彪. All rights reserved.
//

#import "PopoverViewController.h"

@interface PopoverViewController ()

@end

@implementation PopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
 
    
    
}

-(void)loadView{
    NSView *view = [[NSView alloc]initWithFrame:NSMakeRect(0, 0, 300, 300)];
    view.wantsLayer = YES;
    view.layer.backgroundColor = [NSColor redColor].CGColor;
    self.view = view;
   
    NSButton *btn = [[NSButton alloc]initWithFrame:CGRectMake(50, 50, 200, 100)];
    btn.title = @"anniu";
    btn.wantsLayer = YES;
    btn.layer.backgroundColor = [NSColor yellowColor].CGColor;
    btn.target = self;
    btn.action = @selector(btnAction:);
    [self.view addSubview:btn];
    
    
//    [super loadView];
}



- (void)btnAction:(NSButton *)sender{
    NSLog(@"viewController中的按钮");
    
}



@end
