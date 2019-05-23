//
//  AppDelegate.m
//  OSX
//
//  Created by 李振彪 on 2017/5/24.
//  Copyright © 2017年 李振彪. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWCtrl.h"

@interface AppDelegate ()
{
    
}
/** <#Description#> */
@property (nonatomic, strong) MainWCtrl *mainWC;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    self.mainWC = [[MainWCtrl alloc] initWithWindowNibName:@"MainWCtrl"];
    [self setWindow:self.mainWC.window];

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


/**
 “关闭 window 时终止应用”

 @param application <#application description#>
 @return 保证当关闭最后一个window或者关闭应用唯一的一个window时应用自动退出。
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
    NSLog(@"最后一个窗口被关闭之后，是否终止应用");
    return NO;
}


/**
 “应用关闭后 点击 Dock 菜单再次打开应用”
 
 摘录来自: @剑指人心. “MacDev”。 iBooks.

 @param sender <#sender description#>
 @param flag <#flag description#>
 @return  window
 */
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self.window makeKeyAndOrderFront:self];
    return YES;
}




@end
