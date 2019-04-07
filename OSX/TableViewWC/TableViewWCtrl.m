//
//  SecondWCtrl.m
//  OSX
//
//  Created by 李振彪 on 2017/6/14.
//  Copyright © 2017年 李振彪. All rights reserved.
//

#import "TableViewWCtrl.h"
#import "Masonry.h"
#import "BSTableRowView.h"
#import "BSTableCellView.h"
#import <AVFoundation/AVFoundation.h>

#define XXXTableViewDragDataTypeName @"XXXTableViewDragDataTypeName"

@interface TableViewWCtrl ()<NSTableViewDelegate,NSTableViewDataSource>

@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic,strong) NSTableView *tableView;
@property (nonatomic,strong) NSScrollView *tableViewScrollView;
@end

@implementation TableViewWCtrl

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
    NSArray *arr = @[
                   @{@"name":@"john",@"address":@"USA"},
                   @{@"name":@"mary",@"address":@"China"},
                   @{@"name":@"park",@"address":@"Japan"},
                   @{@"name":@"Daba",@"address":@"Russia"},
                   @{@"name":@"john",@"address":@"WUK"},
                   @{@"name":@"mary",@"address":@"ZHANK"},
                   @{@"name":@"park",@"address":@"NAM"},
                   @{@"name":@"Daba",@"address":@"JU"},
                   @{@"name":@"john",@"address":@"KC"},
                   @{@"name":@"mary",@"address":@"WGG"},
                   @{@"name":@"park",@"address":@"JCC"},
                   @{@"name":@"Daba",@"address":@"RUC"},
                   @{@"name":@"john",@"address":@"CIN"},
                   @{@"name":@"mary",@"address":@"XN"},
                   @{@"name":@"park",@"address":@"JK"},
                   @{@"name":@"Daba",@"address":@"VA"},
                   @{@"name":@"john",@"address":@"DK"},
                   @{@"name":@"mary",@"address":@"CHJ"},
                   @{@"name":@"park",@"address":@"JCM"},
                   ];
    
    self.datas = [NSMutableArray arrayWithArray:arr];
    _tableView = [[NSTableView alloc] init];
    [_tableView setAutoresizesSubviews:YES];
    [_tableView setFocusRingType:NSFocusRingTypeNone];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //设置网格线样式（水平线、垂直线，实线、虚线、无），以及颜色
    _tableView.gridStyleMask = NSTableViewSolidVerticalGridLineMask|NSTableViewSolidHorizontalGridLineMask;
    _tableView.gridColor = [NSColor yellowColor];
    _tableView.backgroundColor = [NSColor redColor];
    _tableView.usesAlternatingRowBackgroundColors = YES;//设置背景颜色交替之后，设置backgroundColor将会失效
    _tableView.allowsMultipleSelection = YES;//允许多行选中
    _tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;//此为表格行默认选中样式

    //“2.表格双击事件 配置doubleAction到双击事件方法
    self.tableView.doubleAction = @selector(doubleAction:);
    //“注册NSTableView的拖放事件,XXXTableViewDragDataTypeName为一个自定义的字符串key，用来关联存储拖放事件发生时的数据，对于NSTableView来说，存储拖放的行索引序号。”
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObject:XXXTableViewDragDataTypeName]];
  
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
        make.top.equalTo(self.window.contentView.mas_top).with.offset(10);
        make.bottom.equalTo(self.window.contentView.mas_bottom).with.offset(-50);
        make.left.equalTo(self.window.contentView.mas_left).with.offset(20);
        make.right.equalTo(self.window.contentView.mas_right).with.offset(-50);
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
        [textField setEditable:YES];
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

#pragma mark - 数据拖放
//将表格行编号copy到剪切板对象
-(BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard{
    // Copy the row numbers to the pasteboard.
    NSData *zNSIndexSetData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:XXXTableViewDragDataTypeName] owner:self];
    [pboard setData:zNSIndexSetData forType:XXXTableViewDragDataTypeName];
    return YES;
}

//拖放结束后,从剪切板对象获取到拖放的dragRow
- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:XXXTableViewDragDataTypeName];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    
    //重置数据源(单条数据)
//    NSInteger dragRow = [rowIndexes firstIndex];
//    NSDictionary *dragData = self.datas[dragRow];
//    [self.datas removeObjectAtIndex:dragRow];
//    [self.datas insertObject:dragData atIndex:row];
//    [self.tableView reloadData];
//    NSLog(@"dragRow_%@__%ld__%ld__info：%@，%ld",rowIndexes,dragRow,row,info,self.tableView.numberOfSelectedRows);

    
    //重置数据源(多条数据)
    NSArray *arr = [self.datas mutableCopy];
    NSArray *result = [arr objectsAtIndexes:rowIndexes];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
        NSInteger index = [self.datas indexOfObject:obj];
        NSLog(@"objct_%ld_%@,newindex_%ld",idx,obj,index);
        [self.datas removeObjectAtIndex:index];//注：如果出现数据相同的数据，会出现问题
        
        //防止越界
        NSInteger tempRow = row;
        if (tempRow > self.datas.count) {
            tempRow = self.datas.count;
        }
        [self.datas insertObject:obj atIndex:tempRow];
        NSLog(@"self.data_count_%ld",self.datas.count);
        [self.tableView reloadData];
    }];
    

    
    if(operation == NSTableViewDropOn){
        //替换
    }else if (operation == NSTableViewDropAbove){
        //插入
    }else{
        NSLog (@"unexpected operation (%ld) in %s", operation, __FUNCTION__);
    }

    return YES;
 
}

-(NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation{
    //设置row拖拽的类型：插入、替换
    [tableView setDropRow:row dropOperation: dropOperation];
    NSDragOperation dragOp = NSDragOperationCopy;
    return dragOp;

}


-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    //将row数据转化为可修改的字典对象
    NSMutableDictionary *editData = [NSMutableDictionary dictionaryWithDictionary:self.datas[row]];
    
    //表格列的标识
    NSString *key = tableColumn.identifier;
    
    //更新字典key对应的值为用户编辑的内容
    editData[key] = object;
    
    //更新row数据区
    self.datas[row] = [editData copy];
}


/**
 增加一行数据
 */
-(void)insertRowAtIndex{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"name"]=@"miao";
    data[@"address"]=@"bb";
    
    //增加数据到datas数据区
    [self.datas addObject:data];
    //刷新表数据
    [self.tableView reloadData];
    
    //定位光标到新添加的行
    [self.tableView editColumn:0 row:([self.datas count] - 1) withEvent:nil select:YES];
}


/**
  删除光标所在位置的row以及数据（删除多行数据）
 注：else中的方法适用性更广泛
 */
-(void)removeRowAtIndexs:(BOOL)isMore{
    
    if (isMore == YES) {
        //表格当前选择的行
        NSInteger  row = self.tableView.selectedRow;
        //如果row小于0表示没有选择行
        if(row<0){
            return;
        }
        //从数据区删除选择的行的数据
        [self.datas removeObjectAtIndex:row];
        [self.tableView reloadData];
    }else{
        NSIndexSet  *rowIndexes = self.tableView.selectedRowIndexes;
        if(!rowIndexes){
            return;
        }
        [self.tableView beginUpdates];
        [self.tableView removeRowsAtIndexes:rowIndexes withAnimation:NSTableViewAnimationSlideUp];
        [self.tableView endUpdates];
        
        //从数据区删除选择的行的数据
        [self.datas removeObjectsAtIndexes:rowIndexes];
        
    }
    
}


/**
 设置选中行
 “即使 NSTableView 的 allowsMultipleSelection 属性设置为 NO 也不影响代码控制选中多行。allowsMultipleSelection 为 NO 只影响鼠标多行的选中控制。”
 
 摘录来自: @剑指人心. “MacDev”。 iBooks.
 */
-(void)selectRow{
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc]init];
    [indexSet addIndex:0];
    [indexSet addIndex:1];
    [self.tableView selectRowIndexes:indexSet byExtendingSelection:YES];

}


/**
 设置选中的row的属性，如颜色等（子类重写drawSelectionInRect:方法）

 @param tableView <#tableView description#>
 @param row <#row description#>
 @return <#return value description#>
 */
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
//    BSTableRowView *rowView = [[BSTableRowView alloc] init];
//    return rowView;
    
    BSTableRowView *rowView = [tableView makeViewWithIdentifier:@"rowView" owner:self];
    if (rowView == nil) {
        rowView = [[BSTableRowView alloc]init];
        rowView.identifier = @"rowView";
    }
    return rowView;
}





/**
 双击事件

 @param sender <#sender description#>
 */
- (void)doubleAction:(id)sender {
    
//    NSLog(@"tableView_row 双击事件：%@",NSClassFromString(sender));
}


@end
