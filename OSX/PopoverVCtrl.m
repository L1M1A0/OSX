//
//  PopoverVCtrl.m
//  OSX
//
//  Created by 李振彪 on 2017/6/9.
//  Copyright © 2017年 李振彪. All rights reserved.
//

#import "PopoverVCtrl.h"

@interface PopoverVCtrl ()

@end

@implementation PopoverVCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor redColor].CGColor;
}

@end
