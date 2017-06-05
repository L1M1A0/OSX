//
//  MainWCtrl.m
//  OSX
//
//  Created by 李振彪 on 2017/5/24.
//  Copyright © 2017年 李振彪. All rights reserved.
//

#import "MainWCtrl.h"



@interface MainWCtrl ()<NSApplicationDelegate,NSTextFieldDelegate,NSTextViewDelegate,NSComboBoxDelegate,NSComboBoxDataSource>{
    NSArray *comboBoxItemValue;
}

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
    NSColor *windowBackgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.5];//[NSColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
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
   
    //NSScrollView-----------------
    NSScrollView *scrollView = [self scrollView];

    //NSView-----------------------
    [self view];
    
    CGFloat x = CGRectGetMaxX(self.window.contentView.frame)-200;
    //NSTextField------------------
    [self textFied:x];
    
    //NSTextView-------------------
    [self textView:x];
    
    //NSSearchField----------------
    [self searchField:x];
    
    //label------------------------
    [self label];
    
    //NSButton---------------------
    //一组相关的 Radio Button 关联到同样的 action 方法即可，另外要求同一组 Radio Button 拥有相同的父视图。
    [self button:150 superView:self.window.contentView tag:1];
    [self button:200 superView:self.window.contentView tag:2];
    
    //NSSegmentedControl-----------
    [self segmentControll];
    
    //NSComboBox-------------------
    [self comboBox];
    
    //NSPopUpButton----------------
    [self popUpButton];
    
}

#pragma mark - NSScrollView

-(NSScrollView *)scrollView{
    NSScrollView *scrollView =  [[NSScrollView alloc]initWithFrame:[self.window.contentView bounds]];
    NSImage *image =  [NSImage imageNamed:@"screen.png"];
    
    //NSImageView-----------------
    NSImageView *imageView = [[NSImageView alloc]initWithFrame:scrollView.bounds];
    [imageView setFrameSize:image.size];
    imageView.image = image;
    scrollView.documentView = imageView;
    
    //“分别用来控制是否显示纵向和横向的滚动条。如果设置它们为 NO，只是不显示出来，并不是禁止了滚动的行为。 如果要禁止一个方向的滚动，需要子类化 NSScrollView，重载它的 scrollWheel 方法，判断 Y 轴方向的偏移量满足一定条件返回即可。”
    scrollView.hasVerticalScroller = YES;
    scrollView.hasHorizontalScroller = YES;
    //scrollView.borderType = NSNoBorder;//“滚动条显示的样式风格”
    [self.window.contentView addSubview:scrollView];
    
    [self saveSelfAsImage];
    
    return scrollView;

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
#pragma mark - NSView
-(void)view{
    
    NSView *view = [[NSView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    view.wantsLayer = YES;//设置layer属性时必须先设置为YES
    view.layer.backgroundColor = [NSColor redColor].CGColor;
    [self.window.contentView addSubview:view];
}

#pragma mark - NSTextField
- (void)textFied:(CGFloat)x{
    NSTextField *textField = [[NSTextField alloc]initWithFrame:CGRectMake(x, 10, 200, 50)];
    textField.wantsLayer = YES;
    textField.layer.backgroundColor = [NSColor yellowColor].CGColor;
    textField.textColor = [NSColor greenColor];
    textField.delegate  = self;
    [self.window.contentView addSubview:textField];
}


#pragma mark NSTextFieldDelegate
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
        NSTextField *tf = (NSTextField *)textf;
        NSLog(@"controlTextDidChange_text_%@",tf.stringValue);
        
    }
    if ([textf isKindOfClass:[NSComboBox class]]){
        NSComboBox *cb = (NSComboBox *)textf;
        [cb setCompletes:YES];//这个函数可以实现自动匹配功能
    }
}


#pragma mark - NSTextView
-(void)textView:(CGFloat)x{
    NSTextView *textV = [[NSTextView alloc]initWithFrame:CGRectMake(x, 80, 200, 50)];
    //textV.wantsLayer = YES;//YES 的时候显示在窗口上面，
    //textV.layer.backgroundColor = [NSColor blueColor].CGColor;
    textV.backgroundColor = [NSColor greenColor];
    textV.delegate = self;
    [self.window.contentView addSubview:textV];
}

#pragma mark NSTextDelegate//nstextView

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
#pragma mark - label
-(void)label{
    //“Label本质上是NSTextField类型的，去掉边框和背景，设置为不可编辑，不可以选择即可。”
    NSTextField *label = [[NSTextField alloc]initWithFrame:CGRectMake(0, 100, 200, 30)];
    [label setBezeled:NO];
    [label setDrawsBackground:NO];
    [label setEditable:NO];
    [self.window.contentView addSubview:label];
    
    //普通label
    //label.stringValue = @"Label";
    
    
    //富文本label
    NSString *text = @"please visit http://www.apple.com";
    NSMutableAttributedString *astr = [[NSMutableAttributedString alloc]initWithString:text];
    NSString *linkURLText = @"http://www.apple.com";
    NSURL *linkURL = [NSURL URLWithString:linkURLText];
    //“查找字符串的范围”
    NSRange selectRange = [text rangeOfString:linkURLText];
    
    [astr beginEditing];
    //设置链接属性
    [astr addAttribute:NSLinkAttributeName value:linkURL range:selectRange];
    //设置文字颜色
    [astr addAttribute:NSForegroundColorAttributeName  value:[NSColor blueColor] range:selectRange];
    //设置文本下拉线
    [astr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:selectRange];
    [astr endEditing];
    
    label.attributedStringValue = astr;
}

#pragma mark - NSSearchField
- (void)searchField:(CGFloat)x{
    NSSearchField *searchF =  [[NSSearchField alloc]initWithFrame:CGRectMake(x, 140, 150, 20)];
    searchF.textColor = [NSColor blueColor];
    searchF.backgroundColor = [NSColor redColor];
    searchF.placeholderString = @"NSSearchField";
    [self.window.contentView addSubview:searchF];
    //点击左侧放大镜 执行任务
    NSActionCell *searchButtonCell = [[searchF cell] searchButtonCell];
    searchButtonCell.target = self;
    searchButtonCell.action = @selector(searchButtonClicked:);
    //点击右侧删除 执行任务
    NSActionCell *cancelButtonCell = [[searchF cell] cancelButtonCell];
    cancelButtonCell.target = self;
    cancelButtonCell.action = @selector(cancelButtonClicked:);
}


#pragma mark NSSearchField action
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



#pragma mark - NSButton
- (void)button:(CGFloat)y superView:(NSView *)superView tag:(NSInteger)tag{
    NSButton *btn = [[NSButton alloc]init];
    btn.frame = CGRectMake(0, y, 100, 50);//NSRectMake
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
    //button中显示的图象。如果去掉button的边框和文字，设置完图象属性后，按钮就变成了一个图标按钮。”
//    btn.image = [NSImage imageNamed:@"docx"];
    
    //设置按钮类型，风格，强大
    //1.以下5种类型只有在点击的时候背景颜色发生变化,其他无明显区别
//    [btn setButtonType:NSButtonTypeMomentaryLight];//    = 0,
//    [btn setButtonType:NSButtonTypeToggle];//            = 2,
//    [btn setButtonType:NSButtonTypeMomentaryPushIn];//   = 7,
//    [btn setButtonType:NSButtonTypeAccelerator];//       = 8,
//    [btn setButtonType:NSButtonTypeMultiLevelAccelerator];// = 9,
    
    //2.默认的时候是（左复选框+右文字）的按钮，当设置了image之后，复选框变成了image
//    [btn setButtonType:NSButtonTypeSwitch];//            = 3,
    
    //3.默认的时候是（左单选框+右文字）的按钮，当设置了image之后，复选框变成了image
    //一组相关的 Radio Button 关联到同样的 action 方法即可，另外要求同一组 Radio Button 拥有相同的父视图。
//    [btn setButtonType:NSButtonTypeRadio];//            = 4,
    
    //4.点击的时候，title会变化（消失）
//    [btn setButtonType:NSButtonTypeMomentaryChange];//   = 5,
   
    //5.以下2种类型，stringValue=1有默认选中颜色，stringValue=0没选中无、颜色，
//    [btn setButtonType:NSButtonTypePushOnPushOff];//     = 1,
    [btn setButtonType:NSButtonTypeRadio];//             = 6,
    //设置按钮初始选中状态，1：选中
//    btn.state = 1;
}

#pragma mark NSButton action
-(void)btnAction:(NSButton *)sender{
    NSLog(@"点击了按钮_%@,%@,%ld",sender.title,sender.stringValue,sender.tag);
  
}


#pragma mark - NSSegmentedControl
-(void)segmentControll{
    NSSegmentedControl *seg = [[NSSegmentedControl alloc]init];
    seg = [NSSegmentedControl segmentedControlWithLabels:@[@"232",@"423",@"432",@"3422"] trackingMode:NSSegmentSwitchTrackingSelectOne target:self action:@selector(segmentAction:)];
    seg.frame = CGRectMake(0, 240, 200, 30);
    seg.wantsLayer = YES;
    seg.layer.backgroundColor = [NSColor redColor].CGColor;
//    seg.segmentCount = 3;//seg的item数量
//    seg.segmentStyle = NSSegmentStyleRounded;
//    seg.trackingMode = NSSegmentSwitchTrackingSelectOne;
//    seg.target = self;
//    seg.action = @selector(segmentAction:);
    [self.window.contentView addSubview:seg];
 
}

- (void)segmentAction:(NSSegmentedControl *)seg{
    
    NSLog(@"NSSegmentedControl_%ld",seg.selectedSegment);
    
}


#pragma mark - NSComboBox 组合框
-(void)comboBox{
    comboBoxItemValue = @[@"1",@"e",@"3",@"4",@"23",@"1",@"9",@"rqw",@"e3",@"323"];
    NSComboBox *comBox = [[NSComboBox alloc]initWithFrame:CGRectMake(0, 280, 200, 25)];
//    comBox.backgroundColor = [NSColor yellowColor];
    //在代理前设置usesDataSource，否则无效
    comBox.usesDataSource = YES;
    comBox.delegate = self;
    comBox.dataSource = self;//动态设置item的值
//    comBox.completes = true;//设置这个为true来启用comboBox的自动补全功能
    //设置固定的item的值，usesDataSource=YES时失效
//    [comBox addItemsWithObjectValues:comboBoxItemValue];
    [comBox selectItemAtIndex:0];
    [self.window.contentView addSubview:comBox];
//    [comBox reloadData];

}

#pragma mark comBox.dataSource
//返回item的个数
-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox{
    return comboBoxItemValue.count;
}
//每个index对应的item
-(id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index{
    return comboBoxItemValue[index];
}
//选择右侧下拉标时，默认选中的item的index位置
-(NSUInteger)comboBox:(NSComboBox *)comboBox indexOfItemWithStringValue:(NSString *)string{
    
    //方法1. 不足：当数据源中出现相同的数据，默认取第一个数据的index
    //NSInteger ind = [comboBoxItemValue indexOfObject:string];
    
    //方法2. 推荐
    return comboBox.indexOfSelectedItem;
}

#warning 20170605
//自动补全，未实现
//controlTextDidChange:代理执行的时候设置 comBox.completes = true时执行
-(NSString *)comboBox:(NSComboBox *)comboBox completedString:(NSString *)string{
    //找出数据源中包含当前输入框中的字符的数据，提示自动补全
    NSLog(@"completedString_%@",string);
    
//    NSString *str = comboBoxItemValue[comboBox.indexOfSelectedItem];
//    if ([string hasPrefix:str]) {
//        return str;
//    }else{
//        return string;//comboBoxItemValue[comboBox.indexOfSelectedItem];
//
//    }

    return string;
}
#pragma mark comBox.delegate

-(void)comboBoxWillPopUp:(NSNotification *)notification{
    
    
}
-(void)comboBoxWillDismiss:(NSNotification *)notification{
    
}

-(void)comboBoxSelectionDidChange:(NSNotification *)notification{
    NSComboBox *comboBox = notification.object;
    NSInteger selectedIndex = comboBox.indexOfSelectedItem;
    
    NSLog(@"comboBoxSelectionDidChange selected item %@",comboBoxItemValue[selectedIndex]);
}
-(void)comboBoxSelectionIsChanging:(NSNotification *)notification{
    NSComboBox *comboBox = notification.object;
    NSInteger selectedIndex = comboBox.indexOfSelectedItem;
    NSLog(@"comboBoxSelectionIsChanging selected item %@",comboBoxItemValue[selectedIndex]);
}


#pragma mark - NSPopUpButton
- (void)popUpButton{
    //pullsDown = YES,选中item不能同步值到输入框
    NSPopUpButton *popUpBtn = [[NSPopUpButton alloc]initWithFrame:CGRectMake(0, 310, 200, 30) pullsDown:NO];
    popUpBtn.wantsLayer = YES;
    popUpBtn.layer.backgroundColor = [NSColor greenColor].CGColor;
    [popUpBtn addItemsWithTitles:@[@"1",@"32",@"ASDF",@"FA"]];
    //[popUpBtn setButtonType:NSButtonTypePushOnPushOff];
//    [popUpBtn.cell setArrowPosition:NSPopUpNoArrow];//无箭头
//    [popUpBtn.cell setArrowPosition:NSPopUpArrowAtBottom];
    [popUpBtn.cell setArrowPosition:NSPopUpArrowAtCenter];
    [self.window.contentView addSubview:popUpBtn];
    
//    NSPopUpButtonCell *cel = [[NSPopUpButtonCell alloc]init];
    
}



@end
