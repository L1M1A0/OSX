//
//  SecondWCtrl.m
//  OSX
//
//  Created by 李振彪 on 2017/6/14.
//  Copyright © 2017年 李振彪. All rights reserved.
//

#import "SecondWCtrl.h"
#import "Masonry.h"

@interface SecondWCtrl ()<NSTableViewDelegate,NSTableViewDataSource>

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic,strong) NSTableView *tableView;
@property (nonatomic,strong) NSScrollView *tableViewScrollView;
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
    

//    [self viewInWindow];
    
    
}


-(void)viewInWindow{
    self.datas = @[
                   @{@"name":@"john",@"address":@"USA"},
                   @{@"name":@"mary",@"address":@"China"},
                   @{@"name":@"park",@"address":@"Japan"},
                   @{@"name":@"Daba",@"address":@"Russia"},
                   ];
    
    _tableView = [[NSTableView alloc] init];
    [_tableView setAutoresizesSubviews:YES];
    [_tableView setFocusRingType:NSFocusRingTypeNone];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //“2.表格双击事件 配置doubleAction到双击事件方法
    self.tableView.doubleAction = @selector(doubleAction:);
    
    NSTableColumn *column1=[[NSTableColumn alloc]initWithIdentifier:@"name"];
    column1.title = @"name";
    [self.tableView addTableColumn:column1];
    
    NSTableColumn *column2=[[NSTableColumn alloc]initWithIdentifier:@"address"];
    column2.title = @"address";
    [self.tableView addTableColumn:column2];
    
    _tableViewScrollView = [[NSScrollView alloc] init];
    [_tableViewScrollView setHasVerticalScroller:NO];
    [_tableViewScrollView setHasHorizontalScroller:NO];
    [_tableViewScrollView setFocusRingType:NSFocusRingTypeNone];
    [_tableViewScrollView setAutohidesScrollers:YES];
    [_tableViewScrollView setBorderType:NSBezelBorder];
    [_tableViewScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableViewScrollView setDocumentView:self.tableView];
    
    [self.window.contentView addSubview:self.tableViewScrollView];
    //使用Masony做Autolayout布局设置
    [self.tableViewScrollView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.window.contentView.mas_top).with.offset(0);
        make.bottom.equalTo(self.window.contentView.mas_bottom).with.offset(-50);
        make.left.equalTo(self.window.contentView.mas_left).with.offset(0);
        make.right.equalTo(self.window.contentView.mas_right).with.offset(0);
    }];
    
    
}

#pragma mark-  NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    //获取row数据
    NSDictionary *data = self.datas[row];
    //表格列的标识
    NSString *identifier = tableColumn.identifier;
    //单元格数据
    NSString *value = data[identifier];
    
    
    
    //根据表格列的标识,创建单元视图
    NSView *view = [tableView makeViewWithIdentifier:identifier owner:self];
    NSTextField *textField;
    
    //如果不存在,创建新的textField
    if(!view){
        textField =  [[NSTextField alloc]init];
        [textField setBezeled:NO];
        [textField setDrawsBackground:NO];
        [textField setEditable:NO];
        textField.identifier = identifier;
        view = textField ;
    }
    else{
        textField = (NSTextField*)view;
    }
    
    if(value){
        //更新单元格的文本”
        textField.stringValue = value;
    }
    return view;
}

#pragma mark-  NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    //返回表格共有多少行数据
    return [self.datas count];
}

//“1.表格点击选中事件
//点击表格行触发表代理方法，使用表格的selectedRow获取当前选中的行
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [notification.object selectedRow];
    NSInteger column = [notification.object selectedColumn];//失效
    NSLog(@"点击了tableView_row_%ld,column_%ld",row,column);
}


- (void)doubleAction:(id)sender {
    
//    NSLog(@"tableView_row 双击事件：%@",NSClassFromString(sender));
}


@end
