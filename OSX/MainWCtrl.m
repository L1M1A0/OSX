//
//  MainWCtrl.m
//  OSX
//
//  Created by 李振彪 on 2017/5/24.
//  Copyright © 2017年 李振彪. All rights reserved.
//

#import "MainWCtrl.h"



@interface MainWCtrl ()<NSApplicationDelegate,NSTextFieldDelegate,NSTextViewDelegate>

@end

@implementation MainWCtrl

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self initWindow];
    [self addButtonToTitleBar];
    [self noticeWindowActiveStatuChange];
    [self addViewToWindow];
    [self saveSelfAsImage];
}


#pragma mark - 设置 window 的相关属性
/**
 设置 window 的相关属性
 */
- (void)initWindow{
    //----------1、titleBar-------
    //1、设置titlebar透明，实现titlebar的隐藏或显示效果
    self.window.titlebarAppearsTransparent = NO;
    
    //2、titlebar中的标题是否显示
    //self.window.titleVisibility = NSWindowTitleHidden;
    
    //3、设置窗口标题
    self.window.title = @"窗口的标题";
    
    //4、窗口的图标
    NSImage *titleBarImage = [NSImage imageNamed:@"titleBar.png"];
    [[self.window standardWindowButton:NSWindowDocumentIconButton] setHidden:NO];
    [[self.window standardWindowButton:NSWindowDocumentIconButton] setImage:titleBarImage];
    
    //窗口的风格 styleMask：按位表示的窗口风格参数”
    //    NSWindowStyleMaskBorderless = 0， //没有顶部titlebar边框
    //    NSWindowStyleMaskTitled = 1 << 0， //有顶部titlebar边框
    //    NSWindowStyleMaskClosable = 1 << 1，//带有关闭按钮
    //    NSWindowStyleMaskMiniaturizable = 1 << 2，//带有最小化按钮
    //    NSWindowStyleMaskResizable = 1 << 3，//恢复按钮
    //    NSWindowStyleMaskTexturedBackground = 1 << 8 //带纹理背景的window”
    self.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    
    
    //---------------2、window

    //是否不透明
    [self.window setOpaque:NO];
    
    //窗口背景颜色
    NSColor *windowBackgroundColor = [NSColor cyanColor];//[NSColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
    [self.window setBackgroundColor: windowBackgroundColor];
    
    //可移动的窗口背景
    self.window.movableByWindowBackground = YES;
    
    // Drag and drop
    [self.window registerForDraggedTypes:@[NSFilenamesPboardType]];
    
    
    //窗口显示
    //[self.window makeKeyAndOrderFront:self];
    
    //是否记住上一次窗口的位置,在要求打开窗口时居中的时候需要设置为NO
    //在设置窗口的位置的时候也要设置先为NO，然后再setFrame
    self.window.restorable = NO;
    //窗口居中
    [self.window center];
    
    
}



/**
 在titleBar上边添加视图，如：按钮
 */
- (void)addButtonToTitleBar {
    NSView *titleView = [self.window standardWindowButton:NSWindowCloseButton].superview;
    NSButton *button = [[NSButton alloc]init];
    button.title = @"Register";
    float x = self.window.contentView.frame.size.width  - 100;
    button.frame = NSMakeRect(x,0,80,24);
    button.bezelStyle = NSBezelStyleRounded;
    [titleView addSubview:button];
}


/**
 监听窗口的状态发生改变
 */
- (void)noticeWindowActiveStatuChange{
    //NSWindowDidBecomeKeyNotification:窗口成为keyWindow
    //NSWindowDidBecomeMainNotification:窗口成为mainWindow
    //NSWindowDidMoveNotification:窗口移动
    //NSWindowDidResignKeyNotification:窗口不再是keyWindow
    //NSWindowDidResignMainNotification:窗口不再是mainWindow
    //NSWindowDidResizeNotification:窗口大小改变
    //NSWindowWillCloseNotification:关闭窗口
    //NSWindowDidMiniaturizeNotification:窗口最小化
    
    //窗口关闭时退出应用程序 方法1
    //设置了这个代理之后，将不会在AppDelegate中执行方法2,(仅对当前窗口有效？)
    [NSApp setDelegate:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(windowStatusChange) name:NSWindowWillCloseNotification object:self.window];
    
    //窗口关闭时退出应用程序 方法2 在AppDelegate中设置
//    - (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
//        NSLog(@"appdelgate_applicationShouldTerminateAfterLastWindowClosed");
//        return YES;
//    }
    

}

-(void)windowStatusChange{
    NSLog(@"窗口关闭，程序将退出_%@",@"fasd");
    
}


#pragma mark - 添加窗口控件
-(void)addViewToWindow{
    
//    NSCell *cell = [[NSCell alloc]init];
//    NSControl *con = [[NSControl alloc]init];
    
    //NSScrollView
    NSScrollView *scrollView =  [[NSScrollView alloc]initWithFrame:[self.window.contentView bounds]];
    NSImage *image =  [NSImage imageNamed:@"screen.png"];
    
    //NSImageView
    NSImageView *imageView = [[NSImageView alloc]initWithFrame:scrollView.bounds];
    [imageView setFrameSize:image.size];
    imageView.image = image;
    scrollView.documentView = imageView;

    //“分别用来控制是否显示纵向和横向的滚动条。如果设置它们为 NO，只是不显示出来，并不是禁止了滚动的行为。 如果要禁止一个方向的滚动，需要子类化 NSScrollView，重载它的 scrollWheel 方法，判断 Y 轴方向的偏移量满足一定条件返回即可。”
    scrollView.hasVerticalScroller = YES;
    scrollView.hasHorizontalScroller = YES;
    //scrollView.borderType = NSNoBorder;//“滚动条显示的样式风格”
    [self.window.contentView addSubview:scrollView];

    //NSView
    NSView *view = [[NSView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    view.wantsLayer = YES;//设置layer属性时必须先设置为YES
    view.layer.backgroundColor = [NSColor redColor].CGColor;
    [self.window.contentView addSubview:view];
    
    //NSTextField
    CGFloat x = CGRectGetMaxX(self.window.contentView.frame)-200;
    NSTextField *textField = [[NSTextField alloc]initWithFrame:CGRectMake(x, 10, 200, 50)];
    textField.wantsLayer = YES;
    textField.layer.backgroundColor = [NSColor yellowColor].CGColor;
    textField.textColor = [NSColor greenColor];
    textField.delegate  = self;
    [self.window.contentView addSubview:textField];
    
    //
    NSTextView *textV = [[NSTextView alloc]initWithFrame:CGRectMake(x, 80, 200, 50)];
    //textV.wantsLayer = YES;//YES 的时候显示在窗口上面，
    //textV.layer.backgroundColor = [NSColor blueColor].CGColor;
    textV.backgroundColor = [NSColor greenColor];
    textV.delegate = self;
    [self.window.contentView addSubview:textV];
    
    //
    NSSearchField *searchF =  [[NSSearchField alloc]initWithFrame:CGRectMake(x, 140, 150, 20)];
    searchF.textColor = [NSColor blueColor];
    searchF.backgroundColor = [NSColor redColor];
    searchF.placeholderString = @"NSSearchField";
    [self.window.contentView addSubview:searchF];
    NSActionCell *searchButtonCell = [[searchF cell] searchButtonCell];
    NSActionCell *cancelButtonCell = [[searchF cell] cancelButtonCell];
    searchButtonCell.target = self;
    searchButtonCell.action = @selector(searchButtonClicked:);
    cancelButtonCell.target = self;
    cancelButtonCell.action = @selector(cancelButtonClicked:);
    
}


- (void)saveSelfAsImage {
    [self.window.contentView lockFocus];
    NSImage *image = [[NSImage alloc]initWithData:[self.window.contentView dataWithPDFInsideRect:self.window.contentView.bounds]];
    [self.window.contentView unlockFocus];
    NSData *imageData = image.TIFFRepresentation;
    
    //创建文件v
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = @"/Users/vae/Documents/myCapture.png";
    [fm createFileAtPath:path contents:imageData attributes:nil];
    
    //保存结束后 Finder 中自动定位到文件路径
    NSURL *fileURL = [NSURL fileURLWithPath: path];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ fileURL ]];
}

#pragma mark - NSTextFieldDelegate
//“光标进入输入框第一次输入得到事件通知。”
-(void)controlTextDidBeginEditing:(NSNotification *)obj{
    id textf = obj.object;
    if ([textf isKindOfClass:[NSTextField class]]){
        NSTextField *tw = (NSTextField *)textf;
        NSLog(@"controlTextDidBeginEditing_%@",tw.stringValue);

    }
    
    
}

//“光标离开输入框时得到事件通知。”
-(void)controlTextDidEndEditing:(NSNotification *)obj{
    NSLog(@"controlTextDidEndEditing_%@",obj.userInfo);
}

//“文本框正在输入，内容变化时得到事件通知。”
-(void)controlTextDidChange:(NSNotification *)obj{
    NSLog(@"controlTextDidEndEditing_%@",obj.userInfo);
    id textf = obj.object;
    if ([textf isKindOfClass:[NSTextField class]]){
        NSTextField *tw = (NSTextField *)textf;
        NSLog(@"controlTextDidChange_text_%@",tw.stringValue);
        
    }
}


#pragma mark - NSTextDelegate//nstextView

/**
 “注意 NSTextView 的 实际代理类为 NSTextViewDelegate 类型， 它继承自 NSTextDelegate 。”
 
 摘录来自: @剑指人心. “MacDev”。 iBooks.
 */
-(void)textDidBeginEditing:(NSNotification *)notification{
    
}
-(void)textDidEndEditing:(NSNotification *)notification{
    
}
-(void)textDidChange:(NSNotification *)notification{
    
}
-(BOOL)textShouldEndEditing:(NSText *)textObject{
    return YES;
}


#pragma mark - NSSearchField
-(void)searchButtonClicked:(NSSearchField *)sender{
    
    NSSearchField *searchField = sender;
    NSString *content = searchField.stringValue;
    NSLog(@"content %@",content);
}

-(void)cancelButtonClicked:(NSSearchField *)sender{
   
    NSSearchField *searchField = sender;
    NSString *content = searchField.stringValue;
    NSLog(@"content %@",content);
 }



@end
