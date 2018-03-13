//
//  SecondWCtrl.h
//  OSX
//
//  Created by 李振彪 on 2017/6/14.
//  Copyright © 2017年 李振彪. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TableViewWCtrl : NSWindowController

-(void)viewInWindow;
-(void)insertRowAtIndex;
-(void)removeRowAtIndexs:(BOOL)isMore;
-(void)selectRow;

@end
