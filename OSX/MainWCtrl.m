//
//  MainWCtrl.m
//  OSX
//
//  Created by 李振彪 on 2017/5/24.
//  Copyright © 2017年 李振彪. All rights reserved.
//

#import "MainWCtrl.h"
#import "ZBMacOSObject.h"
#import <AVFoundation/AVFoundation.h>
#import "PopoverViewController.h"
#import "PopoverVCtrl.h"
#import "TableViewWCtrl.h"
#import "OutlineWCtrl.h"
#import "ZBPlayer.h"



#ifdef DEBUG

#define NSLog(format,...) printf("\n[%s] %s [第%d行] %s\n",__TIME__,__FUNCTION__,__LINE__,[[NSString stringWithFormat:format,## __VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif


@interface MainWCtrl ()<NSApplicationDelegate,NSTextFieldDelegate,NSTextViewDelegate,NSComboBoxDelegate,NSComboBoxDataSource,NSTabViewDelegate,NSToolbarDelegate,NSSplitViewDelegate>{
    NSArray *comboBoxItemValue;
    NSTextField *textField;
}

@property (nonatomic, strong) ZBMacOSObject *macOsObject;

/** <#Description#> */
@property (nonatomic, assign) CGFloat x;
/** <#Description#> */
@property (nonatomic, strong) NSPopover *popover;
/** <#Description#> */
@property (nonatomic, strong) NSPanel *panel;
/** <#Description#> */
@property (nonatomic, strong) NSAlert *alert;

/** <#Description#> */
@property (nonatomic, strong) NSMenu *myMenu;


@property (nonatomic, strong) ZBPlayer *zbPlayer;

@property (nonatomic, strong) NSTextView *textView;

/** <#Description#> */
@property (nonatomic, strong) TableViewWCtrl *tableView;
@property (nonatomic, strong) OutlineWCtrl *outlineWC;

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
    
    self.macOsObject = [[ZBMacOSObject alloc]init];
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
    
    //如果设置minSize后拉动窗口有明显的大小变化，需要在MainWCtrl.xib中勾选Mininum content size
    //self.window.minSize = NSMakeSize(700, 600);
    self.window.maxSize = NSMakeSize(900, 700);
    //self.window.contentMinSize = NSMakeSize(700, 600);
    
    
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
    button.target = self;
    button.action = @selector(registerBtnAction:);
    [titleView addSubview:button];
}

-(void)registerBtnAction:(NSButton *)sender{
    [self.window beginSheet:self.panel completionHandler:^(NSModalResponse returnCode) {
        NSLog(@"nspanel__show,%ld",returnCode);
    }];
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
//    [NSApp setDelegate:self];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(windowStatusChange) name:NSWindowWillCloseNotification object:self.window];
    
    //窗口关闭时退出应用程序 方法2 在AppDelegate中设置
    //    - (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
    //        NSLog(@"appdelgate_applicationShouldTerminateAfterLastWindowClosed");
    //        return YES;
    //    }
    
    
}

-(void)windowStatusChange{
    NSLog(@"窗口关闭，程序将退出");
    
}


#pragma mark - 添加窗口控件
-(void)addViewToWindow{
    
    //    NSCell *cell = [[NSCell alloc]init];
    //    NSControl *con = [[NSControl alloc]init];
    
    //NSScrollView-----------------
    [self scrollView];
    [self saveSelfAsImage];
    
    
    //NSView-----------------------
    [self.macOsObject view:NSMakeRect(0, 0, 100, 100) superView:self.window.contentView];
    
    self.x = CGRectGetMaxX(self.window.contentView.frame)-200;
    //NSTextField------------------
    textField = [self textFied:self.x];
    
    //NSTextView-------------------
    self.textView = [self textView:NSMakeRect(self.x, 80, 200, 50)];
    
    //NSSearchField----------------
    [self searchField:self.x];
    
    //label------------------------
    [self label];
    
    //NSButton---------------------
    //一组相关的 Radio Button 关联到同样的 action 方法即可，另外要求同一组 Radio Button 拥有相同的父视图。
    [self button:NSMakeRect(0, 150, 150, 40) superView:self.window.contentView title:@"显示NSAlert" tag:1 type:NSButtonTypeRadio];
    [self button:NSMakeRect(0, 200, 150, 40) superView:self.window.contentView title:@"显示NSPopover" tag:2 type:NSButtonTypeRadio];
    
    
    //NSSegmentedControl-----------
    [self.macOsObject segmentedControl:NSMakeRect(0, 240, 200, 30) labels:@[@"232",@"423",@"432",@"3422"] target:self superView:self.window.contentView];
    
    //NSComboBox-------------------
    [self comboBox];
    
    //NSPopUpButton----------------
    [self.macOsObject popUpButton:NSMakeRect(0, 310, 200, 30) superView:self.window.contentView];
    
    //NSSlider---------------------
    [self slider:NSSliderTypeLinear frame:NSMakeRect(230, 0, 150, 30) superView:self.window.contentView];
    [self slider:NSSliderTypeCircular frame:NSMakeRect(230, 35, 50, 50) superView:self.window.contentView];
    
    //NSDatePicker-----------------
    [self datePicker];
    
    
    //NSStepper--------------------
    NSStepper *stepper = [self.macOsObject stepper:NSMakeRect(300, 50, 50, 30)superView:self.window.contentView];
    stepper.target = self;
    stepper.action = @selector(stepperAction:);
    
    //NSProgressIndicator----------
    [self.macOsObject progressIndicator:NSMakeRect(230, 90, 50, 45)  style:NSProgressIndicatorSpinningStyle superView:self.window.contentView];
    [self.macOsObject progressIndicator:NSMakeRect(290, 90, 150, 45) style:NSProgressIndicatorBarStyle superView:self.window.contentView];
    
    //NSBox------------------------
    [self box];
    
    //NSSplitView------------------
    [self splitView];
    
    //NSCollectionView-------------未实现
    [self collectionView];
    
    //NSTabView--------------------
    [self tabView];
    
    //NSPanel----------------------
    [self pannel];
    
    //NSAlert----------------------
    [self nsAlert];
    
    //-----------------------------New Window-------------------
    [self button:NSMakeRect(250, 350, 200, 50) superView:self.window.contentView title:@"新窗口显示tableview" tag:3 type:NSButtonTypePushOnPushOff];
    
    [self button:NSMakeRect(250, 380, 100, 50) superView:self.window.contentView title:@"OutlineWCtrl" tag:4 type:NSButtonTypePushOnPushOff];

    [self button:NSMakeRect(350, 380, 100, 50) superView:self.window.contentView title:@"ZBPlayer" tag:5 type:NSButtonTypePushOnPushOff];

    
}

#pragma mark - NSScrollView

-(NSScrollView *)scrollView{
    NSScrollView *scrollView =  [[NSScrollView alloc]initWithFrame:[self.window.contentView bounds]];
    NSImage *image =  [NSImage imageNamed:@"screen.jpg"];
    
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
    
    return scrollView;
}


/**
 保存界面截图结束后 Finder 中自动定位到文件路径(保存后自动打开文件目录)
 */
- (void)saveSelfAsImage {
    [self.window.contentView lockFocus];
    NSImage *image = [[NSImage alloc]initWithData:[self.window.contentView dataWithPDFInsideRect:self.window.contentView.bounds]];
    [self.window.contentView unlockFocus];
    NSData *imageData = image.TIFFRepresentation;
    
    //创建文件v
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = @"/Users/vae/Documents/myCapture.png";
    [fm createFileAtPath:path contents:imageData attributes:nil];
    
    //保存结束后 Finder 中自动定位到文件路径(保存后自动打开文件目录)
    //    NSURL *fileURL = [NSURL fileURLWithPath: path];
    //    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ fileURL ]];
}

#pragma mark - NSTextField
- (NSTextField *)textFied:(CGFloat)x{
    NSTextField *textf = [[NSTextField alloc]initWithFrame:NSMakeRect(x, 10, 200, 50)];
    textf.wantsLayer = YES;
    textf.layer.backgroundColor = [NSColor yellowColor].CGColor;
    textf.textColor = [NSColor redColor];
    textf.font = [NSFont systemFontOfSize:30];
    textf.delegate  = self;
    [self.window.contentView addSubview:textf];
    return textf;
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
-(NSTextView *)textView:(NSRect)frame{
    NSTextView *textV = [[NSTextView alloc]initWithFrame:frame];
    //textV.wantsLayer = YES;//YES 的时候显示在窗口上面，
    //textV.layer.backgroundColor = [NSColor blueColor].CGColor;
    textV.backgroundColor = [NSColor greenColor];
    textV.delegate = self;
    [self.window.contentView addSubview:textV];
    return textV;
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
    NSTextField *label = [[NSTextField alloc]initWithFrame:NSMakeRect(0, 100, 200, 30)];
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
    NSSearchField *searchF =  [[NSSearchField alloc]initWithFrame:NSMakeRect(x, 140, 150, 20)];
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
- (NSButton *)button:(NSRect)frame superView:(NSView *)superView title:(NSString *)title tag:(NSInteger)tag type:(NSButtonType)type{
    
    NSButton *btn = [self.macOsObject button:frame title:title tag:tag type:type target:self superView:superView];
    btn.action = @selector(btnAction:);
    return btn;
}

#pragma mark NSButton action 按钮响应方法集合
-(void)btnAction:(NSButton *)sender{
    NSLog(@"点击了按钮_%@,%@,%ld",sender.title,sender.stringValue,sender.tag);
    if (sender.tag == 1) {
        
        [self.alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
            NSLog(@"alert_returnCode_%ld",returnCode);
        }];
    }else if (sender.tag == 3){//打开新的窗口
        [self showNewWindow:self.tableView.window];
    }else if (sender.tag == 4){
        //显示节点列表 窗口
        [self showNewWindow:self.outlineWC.window];
    }else if (sender.tag == 5){
        //显示ZBPlayer 播放器 综合学习
        [self showNewWindow:self.zbPlayer.window];
    }
    else{
        [self.popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSRectEdgeMaxX];
    }
    

}



#pragma mark - NSComboBox 组合框
-(void)comboBox{
    comboBoxItemValue = @[@"1",@"e",@"3",@"4",@"23",@"1",@"9",@"rqw",@"e3",@"323"];
    NSComboBox *comBox = [[NSComboBox alloc]initWithFrame:NSMakeRect(0, 280, 200, 25)];
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

#pragma mark - NSSlider
-(void)slider:(NSSliderType)sliderType frame:(CGRect)frame superView:(NSView *)superView{
    [self.macOsObject slider:sliderType frame:frame superView:superView target:self action: @selector(sliderAction:)];
}
-(void)sliderAction:(NSSlider *)sender{
    
    NSLog(@"sliderValue_%ld,%f,%@",sender.integerValue,sender.floatValue,sender.stringValue);
    textField.stringValue = sender.stringValue;
    
    for (id control in self.window.contentView.subviews) {
        if ([control isKindOfClass:[NSProgressIndicator class]]){
            NSProgressIndicator *c = (NSProgressIndicator*)control;
            c.doubleValue = [sender.stringValue doubleValue];
        }
        if ([control isKindOfClass:[NSSlider class]]){
            if (![control isEqualTo:sender]) {
                NSSlider *sli = (NSSlider *)control;
                sli.stringValue = sender.stringValue;
            }
        }
    }
}

#pragma mark - NSDatePicker
- (void)datePicker{
    NSDatePicker *datePicker = [[NSDatePicker alloc]initWithFrame:NSMakeRect(230, 200, 300, 300)];
    //设置当前日期为初始值
    datePicker.dateValue = [NSDate date];
    //界面类型，以下style默认显示日历和时钟
    datePicker.datePickerStyle = NSClockAndCalendarDatePickerStyle;
    //显示日历
    //datePicker.datePickerElements = NSYearMonthDayDatePickerElementFlag;
    //显示时钟
    //datePicker.datePickerElements = NSHourMinuteSecondDatePickerElementFlag;
    
    
    //背景色仅对 Graphical 样式的 NSDatePicker 有效
    datePicker.wantsLayer = YES;
    datePicker.backgroundColor = [NSColor cyanColor];
    //文字颜色仅仅对 Textual,Textual With Stepper 2种 UI 样式的 NSDatePicker 有效。
    datePicker.textColor = [NSColor blueColor];
    
    datePicker.target = self;
    datePicker.action = @selector(datePickerAction:);
    [self.window.contentView addSubview:datePicker];
}

-(void)datePickerAction:(NSDatePicker *)sender{
    
    NSLog(@"datePicker_%@",sender.dateValue);
    //    textField.stringValue = ]
    
}

- (void)stepperAction:(NSStepper *)sender{
    textField.stringValue = sender.stringValue;
}


#pragma mark - NSBox

-(void)box{
    
    NSBox *box = [[NSBox alloc]initWithFrame:NSMakeRect(self.x, 200, 150, 150)];
    box.title = @"NSBox";
    box.titlePosition = NSAtTop;//标题位置
    box.boxType = NSBoxPrimary;
    
    //设置背景色无效
    //    box.wantsLayer = YES;
    //    box.layer.backgroundColor  = [NSColor greenColor].CGColor;
    box.contentView.wantsLayer = YES;
    box.contentView.layer.backgroundColor = [NSColor orangeColor].CGColor;
    [self.window.contentView addSubview:box];
    
    //设置边距margin,contentView中子视图到边线的距离
    NSSize margin = NSMakeSize(20, 30);
    box.contentViewMargins = margin;
    [self slider:NSSliderTypeCircular frame:NSMakeRect(0, 0, 50, 50) superView:box.contentView];
}

#pragma mark - NSSplitView
- (void)splitView{
    NSSplitView *splitView = [[NSSplitView alloc]initWithFrame:NSMakeRect(0, 350, 200, 100)];
    splitView.dividerStyle = NSSplitViewDividerStyleThick;
    splitView.vertical   = YES;//水平分割 or 垂直分割
    splitView.wantsLayer = YES;
    splitView.delegate = self;
    splitView.layer.backgroundColor = [NSColor redColor].CGColor;
    
    //view1.frame.size.width-20
    NSRect rect1 = NSMakeRect(30, 30,50 , 50);
    NSRect rect2 = NSMakeRect(30, 30,100 , 50);
    NSView *view1 = [self viewForSplitView:[NSColor greenColor] frame:rect1];
    NSView *view2 = [self viewForSplitView:[NSColor blueColor]  frame:rect2];
    NSView *view3 = [self viewForSplitView:[NSColor yellowColor]  frame:rect2];

    //增加左右视图。可以任意加，每加一个，就多一个分栏
    [splitView addSubview:view1];
    [splitView addSubview:view2];
    [splitView addSubview:view3];

    //    [splitView insertArrangedSubview:[self viewForSplitView:[NSColor orangeColor]] atIndex:1];
    
    //    [splitView drawDividerInRect:NSMakeRect(80, 0, 50, 50)];
    //    [splitView setPosition:80 ofDividerAtIndex:0];
    [self.window.contentView addSubview:splitView];
}

- (NSView *)viewForSplitView:(NSColor *)color frame:(NSRect)frame{
    NSView *leftView = [[NSView alloc]initWithFrame:NSZeroRect];
    leftView.autoresizingMask = NSViewMinXMargin;
    leftView.wantsLayer = YES;
    leftView.layer.backgroundColor = color.CGColor;
    [leftView setAutoresizesSubviews:YES];
    [self slider:NSSliderTypeLinear frame:frame superView:leftView];
    
    return leftView;
}
#pragma mark NSSplitViewDelegate
/** 设置每个栏的最小值，可以根据dividerIndex单独设置 */
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return 80;
}
/** 设置每个栏的最大值，可以根据dividerIndex单独设置 */
-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
    return 120;
}

#pragma mark - NSCollectionView

- (void)collectionView{
    //    NSCollectionView *collectionView = [[NSCollectionView alloc]initWithFrame:NSMakeRect(230, 350, 250, 200)];
    //    collectionView.backgroundView.wantsLayer = YES;
    //    collectionView.backgroundView.layer.backgroundColor = [NSColor greenColor].CGColor;
    //
    //    [self.window.contentView addSubview:collectionView];
}

#pragma mark - NSTabView

-(void)tabView{
    NSTabView *tabView = [[NSTabView alloc]initWithFrame:NSMakeRect(0, 440, 200, 120)];
    tabView.tabViewType = NSTopTabsBezelBorder;//tab的位置
    //    tabView.tabViewItems = @[@"2",@"wew",@"re"];
    [tabView addTabViewItem:[self tabViewItemTitle:@"1" bColor:[NSColor redColor]]];
    [tabView addTabViewItem:[self tabViewItemTitle:@"2" bColor:[NSColor greenColor]]];
    [tabView addTabViewItem:[self tabViewItemTitle:@"3" bColor:[NSColor blueColor]]];
    [tabView addTabViewItem:[self tabViewItemTitle:@"4" bColor:[NSColor orangeColor]]];
    [tabView addTabViewItem:[self tabViewItemTitle:@"5" bColor:[NSColor purpleColor]]];
    
    tabView.delegate = self;
    //    tabView.selectedTabViewItem = tabView.tabViewItems[1];
    [self.window.contentView addSubview:tabView];
}

#pragma mark NSTabViewItem
- (NSTabViewItem *)tabViewItemTitle:(NSString *)title bColor:(NSColor *)color{
    NSTabViewItem *tabViewItem = [[NSTabViewItem alloc]initWithIdentifier:@"Untitled"];
    tabViewItem.label = title;
    
    NSView *view = [[NSView alloc]initWithFrame:NSZeroRect];
    [view setAutoresizesSubviews:YES];
    [view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable ];
    view.wantsLayer = YES;
    view.layer.backgroundColor = color.CGColor;
    tabViewItem.view = view;
    
    return tabViewItem;
}

#pragma mark delegate
-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem{
    NSLog(@"tabViewItem_%@",tabViewItem.label);
    
    if ([tabViewItem.label isEqualToString:@"2"]) {
        [self openPanel];
    }else if ([tabViewItem.label isEqualToString:@"3"]){
        [self savePanel];
    }else if ([tabViewItem.label isEqualToString:@"4"]){
        [self colorPanel];
    }else if ([tabViewItem.label isEqualToString:@"5"]){
        [self fontManager];
    }
    else{
        
    }
    
    
}


#pragma mark - NSPopover

-(NSPopover *)popover{
    if(!_popover){
        //NSPopoverBehaviorApplicationDefined:NSPopover的关闭需要App自己负责控制
        //NSPopoverBehaviorTransient:只要点击到NSPopover显示的窗口之外就自动关闭
        //NSPopoverBehaviorSemitransient:,只要点击到NSPopover显示的窗口之外就自动关闭,但是点击到当前App 窗口之外不会关闭。
        //xib
        //PopoverVCtrl *vc = [[PopoverVCtrl alloc]initWithNibName:@"PopoverVCtrl" bundle:nil];
        //纯代码
        PopoverViewController *vc = [[PopoverViewController alloc]initWithNibName:nil bundle:nil];
        _popover = [[NSPopover alloc]init];
        _popover.contentViewController = vc;
        _popover.behavior = NSPopoverBehaviorTransient;
        _popover.animates = YES;
        _popover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
        //[_popover close];
    }
    return _popover;
}


#pragma mark - 面板：NSPanel

- (void)pannel{
    NSPanel *panel = [[NSPanel alloc]initWithContentRect:NSMakeRect(0, 0, 300, 200) styleMask:NSWindowStyleMaskHUDWindow backing:NSBackingStoreRetained defer:YES];
    panel.title = @"nspanel";
    NSButton *btn = [self button:NSMakeRect(30, 30, 100, 100) superView:panel.contentView title:@"NSPanel" tag:30 type:NSButtonTypePushOnPushOff];
    btn.target =self;
    btn.action = @selector(panelBtnAction:);
    
    self.panel = panel;
}

-(void)panelBtnAction:(NSButton *)sender{
    [self.window endSheet:self.panel];
}

#pragma mark - 面板：NSOpenPanel 读取电脑文件 获取文件名，路径
- (void)openPanel{
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseFiles = YES ;//----------“是否允许选择文件”
    openDlg.canChooseDirectories = YES;//-----“是否允许选择目录”
    openDlg.allowsMultipleSelection = YES;//--“是否允许多选”
    openDlg.allowedFileTypes = @[@"mp3",@"flac",@"wav",@"aac",@"m4a",@"ape",@"ogg",@"alac"];//---“允许的文件名后缀”
    openDlg.treatsFilePackagesAsDirectories = YES;
    //openDlg.URL = @"";////“保存用户选择的文件/文件夹路径path”
    [openDlg beginWithCompletionHandler: ^(NSInteger result){
        if(result==NSFileHandlingPanelOKButton){
            NSArray *fileURLs = [openDlg URLs];//“保存用户选择的文件/文件夹路径path”
            for(NSURL *url in fileURLs) {
                NSError *error;
                NSString *string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
                if(!error){
                    textField.stringValue = string;
                }
            }
            
            NSString *pa = [fileURLs.firstObject path];

//            NSFileManager
            NSLog(@"获取本地文件的路径：%@,,%@",fileURLs,pa);
        }
    }];
    
}



#pragma mark - 面板： NSSavePanel

/**
 保存文件面板
 */
- (void)savePanel{
    NSSavePanel *savePanel = [[NSSavePanel alloc]init];
    savePanel.title = @"save Panel";
    savePanel.message = @"热";
    savePanel.allowedFileTypes = @[@"txt"];
    savePanel.nameFieldStringValue = @"默认文件名";
    [savePanel beginWithCompletionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton){
            NSURL *url = [savePanel URL];
            NSLog(@"文件路径_url_%@",url);
            NSString *text = textField.stringValue;
            NSError *error;
            [text writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"保存文件失败——%@",error);
            }
        }
    }];
}

#pragma mark - 面板： NSColorPanel
- (void)colorPanel{
    NSColorPanel *colorPanel = [NSColorPanel sharedColorPanel];
    [colorPanel setAction:@selector(changeColor:)];
    [colorPanel setTarget:self];
    [colorPanel orderFront:nil];
}
//- (void)changeColor:(NSColorPanel *)sender{
//    textField.textColor = sender.color;
//}

-(void)changeColor:(id)sender{
    NSColorPanel *panel = (NSColorPanel *)sender;
    
    textField.textColor = panel.color;
}
#pragma mark - 面板： NSFontManager
-(void)fontManager{
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    //    [fontManager setDelegate:self];
    [fontManager setTarget:self];
    [fontManager orderFrontFontPanel:self];
    
}


-(void)changeFont:(id)sender{
    NSFontManager *font = (NSFontManager *)sender;
    textField.font = [font convertFont:textField.font];
    NSLog(@"font_%f,%@,%@",textField.font.pointSize,textField.font.fontName,textField.font.familyName);
}


#pragma mark - NSAlert

- (void)nsAlert{
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = @"标题";
    alert.informativeText = @"详细内容";
    //alert.icon =//对应的一个图标，可以不设置为空。为空时根据下面的alertStyle样式决定使用默认的图标。
    alert.alertStyle = NSAlertStyleWarning;
    //新增按钮，最多为3个，存储在buttons属性中
    [alert addButtonWithTitle:@"1"];
    [alert addButtonWithTitle:@"2"];
    [alert addButtonWithTitle:@"3"];
    //    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
    //
    //        NSLog(@"alert_returnCode_%ld",returnCode);
    //
    //    }];
    self.alert = alert;
}

//- (void)alertHide{
//    self.alert eshe
//}





#pragma mark - NSToolbar
- (NSToolbar *)toolbar{
    //Toolbar 和左上角控制窗口关闭、最小化和全屏的三个按钮在同一行，这个特性需要10.10及以上的系统。
    NSToolbar *toolbar = [[NSToolbar alloc]initWithIdentifier:@"newWindowToolbar"];
    toolbar.visible = YES;
    toolbar.sizeMode = NSToolbarSizeModeRegular;
    toolbar.allowsUserCustomization = NO;
    toolbar.autosavesConfiguration = NO;
    toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
    toolbar.delegate = self;
    return toolbar;
}



#pragma mark NSToolbarDelegate

-(NSArray<NSString *> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar{
    return @[@"FontSetting",@"Save"];
}
-(NSArray<NSString *> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar{
    return @[@"FontSetting",@"Save"];
}
-(NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag{
    
#pragma mark NSToolbarItem
    NSToolbarItem *toolbarItem = [[NSToolbarItem alloc]initWithItemIdentifier:itemIdentifier];
    
    if([itemIdentifier isEqualToString:@"FontSetting"]){
        toolbarItem.label = @"Font";
        toolbarItem.paletteLabel = @"Font";//在xib的设计模式下toolbaritem显示的文本
        toolbarItem.toolTip = @"格式";//悬停同事文字
        toolbarItem.image = [NSImage imageNamed:@"FontSetting"];//图标图片
        toolbarItem.tag  = 1;
        
    }else if ([itemIdentifier isEqualToString:@"Save"]){
        toolbarItem.label = @"Save";
        toolbarItem.paletteLabel = @"Save";
        toolbarItem.toolTip = @"保存";
        toolbarItem.image = [NSImage imageNamed:@"Save"];
        toolbarItem.tag  = 2;
        
    }else{
        toolbarItem = nil;
    }
    
    toolbarItem.minSize = CGSizeMake(25, 25);
    toolbarItem.maxSize = CGSizeMake(100, 100);
    toolbarItem.target = self;
    toolbarItem.action = @selector(toolbarItemAction:);
    //当使用标准的image/lable模式的toolbaritem时,可以嵌入一个其他的控件,这个view做为它的容器视图。
    toolbarItem.view.wantsLayer = YES;
    toolbarItem.view.layer.backgroundColor = [NSColor yellowColor].CGColor;
    
    return toolbarItem;
    
}
- (void)toolbarItemAction:(NSToolbarItem *)sender{
    NSLog(@"toolbarItem_%ld",sender.tag);
    if (sender.tag == 1) {//增加一行
        [self.tableView insertRowAtIndex];
    }else if (sender.tag == 2){//删除一行
        [self.tableView removeRowAtIndexs:YES];
        //        [self.secondWindow selectRow];
    }else{
        
    }
    
}



#pragma mark - NSMenu (未完成)
-(void)menununu{
//    NSButton *button = (NSButton *)sender;
//    NSPoint point = button.frame.origin;
//    point.x += button.frame.size.width;
//    point.y = point.y ;
//    [self.myMenu popUpMenuPositioningItem:nil atLocation:point inView:self.window.contentView];
}
-(NSMenu *)myMenu{
    if(!_myMenu){
        _myMenu = [[NSMenu alloc]initWithTitle:@"菜单_myMenu"];
        [_myMenu insertItem:[self menuItem:@"1"] atIndex:1];
        [_myMenu insertItem:[self menuItem:@"2"] atIndex:2];
        [_myMenu insertItem:[self menuItem:@"3"] atIndex:3];
    }
    return _myMenu;
}

- (NSMenuItem *)menuItem:(NSString *)title{
    NSMenuItem *item = [[NSMenuItem alloc]initWithTitle:title action:@selector(menuItemAction:) keyEquivalent:@""];
    return item;
}
-(void)menuItemAction:(NSMenuItem *)sender{
    
}


#pragma mark - NSWindowController &  ZBPlayer - 新窗口
-(ZBPlayer *)zbPlayer{
    if(!_zbPlayer){
        _zbPlayer= [[ZBPlayer alloc]init];
        _zbPlayer.window = [self window:NSMakeRect(0,0,1000,500) title:@"ZBPlayer" bgColor:[NSColor whiteColor]];
        [_zbPlayer viewInWindow];
    }
    return _zbPlayer;
}



#pragma mark - NSWindowController &  NSOutlineView - 新窗口
-(OutlineWCtrl *)outlineWC{
    if(!_outlineWC){
        _outlineWC= [[OutlineWCtrl alloc]init];
        _outlineWC.window = [self window:NSMakeRect(0,0,500,500) title:@"outlineview" bgColor:[NSColor redColor]];
        [_outlineWC viewInWindow];
    
    }
    return _outlineWC;
}
#pragma mark - NSWindowController & NSTableView - 新窗口

-(TableViewWCtrl *)tableView{
    if(!_tableView){
        _tableView = [[TableViewWCtrl alloc]init];
        _tableView.window = [self window:NSMakeRect(0,0,500,500) title:@"表格视图" bgColor:[NSColor orangeColor]];
        
        [self button:NSMakeRect(10, 10, 100, 50) superView:self.tableView.window.contentView title:@"显示pop窗口" tag:0 type:NSButtonTypePushOnPushOff];
        
        //Toolbar 和左上角控制窗口关闭、最小化和全屏的三个按钮在同一行，这个特性需要10.10及以上的系统。
        self.tableView.window.toolbar = [self toolbar];;
        self.tableView.window.titleVisibility =  NSWindowTitleHidden;
        [_tableView viewInWindow];
    }
    return _tableView;
}


-(NSWindow *)window:(NSRect)frame title:(NSString *)title bgColor:(NSColor *)bgColor{
    //    NSRect frame = NSMakeRect(0,0,500,500);
    NSUInteger style =  NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;
    NSWindow *window = [[NSWindow alloc]initWithContentRect:frame styleMask:style backing:NSBackingStoreBuffered defer:YES];
    window.title = title;
    window.backgroundColor = bgColor;
    return window;
}
-(void)showNewWindow:(NSWindow*)window{
    //窗口显示
    [window makeKeyAndOrderFront:self];
    //窗口居中
    [window center];
    
    //[self.secondWindow.window canBecomeMainWindow];
    //[self.secondWindow.window makeKeyWindow];
    
    //[self.secondWindow.window  orderFront:self];
    //关闭窗口
    //[self.window orderOut:self];
}



@end

