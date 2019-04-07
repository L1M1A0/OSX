//
//  OutlineWCtrl.m
//  OSX
//
//  Created by 李振彪 on 2018/3/13.
//  Copyright © 2018年 李振彪. All rights reserved.
//

//层级列表，可收起和展开

#import "OutlineWCtrl.h"
#import "Masonry.h"
#import "OutlineTableRowView.h"
#import "OutlineTableRowView2.h"
#import "OutlineIndexModel.h"


#define itemNode(superNode,currentNode,index)


@interface OutlineWCtrl ()<NSOutlineViewDelegate,NSOutlineViewDataSource>

@property (nonatomic, strong) NSOutlineView *outlineView;
@property (nonatomic, strong) TreeNodeModel *treeModel;
@property (nonatomic, strong) NSScrollView *tableViewScrollView;
@property (nonatomic, strong) OutlineIndexModel *indexModel;
@property (nonatomic, assign) NSInteger tempSperNodeIndex;



@end

@implementation OutlineWCtrl

- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)viewInWindow{

    [self initData];

    self.outlineView = [[NSOutlineView alloc]initWithFrame:NSMakeRect(0, 0, 0, 0)];
    self.outlineView.delegate = self;
    self.outlineView.dataSource = self;
    self.outlineView.wantsLayer = YES;
    self.outlineView.backgroundColor = [NSColor purpleColor];
//    self.outlineView.layer.backgroundColor = [NSColor blueColor].CGColor;
//    [self.window.contentView addSubview:self.outlineView];
//    self.outlineView.outlineTableColumn.hidden = YES;
    NSTableColumn *column1=[[NSTableColumn alloc]initWithIdentifier:@"name"];
    column1.title = @"可创建一个空的，不创建的话，内容会跑到bar底下";
    [self.outlineView addTableColumn:column1];
    
    _tableViewScrollView = [[NSScrollView alloc] init];
    [_tableViewScrollView setHasVerticalScroller:NO];
    [_tableViewScrollView setHasHorizontalScroller:NO];
    [_tableViewScrollView setFocusRingType:NSFocusRingTypeNone];
    [_tableViewScrollView setAutohidesScrollers:YES];
    [_tableViewScrollView setBorderType:NSBezelBorder];
    [_tableViewScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableViewScrollView setDocumentView:self.outlineView];
    [self.window.contentView addSubview:self.tableViewScrollView];
    
    //使用Masony做Autolayout布局设置
    [self.tableViewScrollView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.window.contentView.mas_top).with.offset(50);
        make.bottom.equalTo(self.window.contentView.mas_bottom).with.offset(-50);
        make.left.equalTo(self.window.contentView.mas_left).with.offset(50);
        make.right.equalTo(self.window.contentView.mas_right).with.offset(-50);
    }];
    
    [self.outlineView reloadData];
    [self btn:NSMakeRect(20, 0, 60, 50) title:@"增加" tag:0];
    [self btn:NSMakeRect(80, 0, 60, 50) title:@"移除" tag:0];

}

-(void)btn:(NSRect)rect title:(NSString *)title tag:(NSInteger)tag{
    NSButton *btn = [NSButton buttonWithTitle:title target:self action:@selector(btn:)];
    btn.frame = rect;
    btn.tag = tag;
    [self.window.contentView addSubview:btn];
}

-(void)btn:(NSButton *)sender{
    if (sender.tag == 0) {
        [self addNodeAction:@"ta"];
    }else if (sender.tag == 1){
        [self removeNodeAction:@"dd"];
    }else{
        
    }
}

#pragma mark - 数据源
-(void)initData{
    self.indexModel = [[OutlineIndexModel alloc]init];
    
    //根节点
    TreeNodeModel *rootNode1 = [self node:@"公司1" level:0];
    TreeNodeModel *rootNode2 = [self node:@"公司2" level:0];
    TreeNodeModel *rootNode3 = [self node:@"公司3" level:0];
//    self.treeModel = rootNode1;
//    [self.treeModel.childNodes addObject:rootNode1];
    [self.treeModel.childNodes addObjectsFromArray:@[rootNode1,rootNode2,rootNode3]];

    //2级节点
    TreeNodeModel *level11Node = [self node:@"电商" level:1];
    TreeNodeModel *level12Node = [self node:@"游戏" level:1];
    TreeNodeModel *level13Node = [self node:@"音乐" level:1];
    [rootNode1.childNodes addObjectsFromArray:@[level11Node,level12Node,level13Node]];
    [rootNode2.childNodes addObjectsFromArray:@[level11Node,level12Node,level13Node]];
    [rootNode3.childNodes addObjectsFromArray:@[level11Node,level12Node,level13Node]];
    
    //3级节点
    [level11Node.childNodes addObjectsFromArray:[self subNodeKeyStr:level11Node.name count:5 level:2]];
    [level12Node.childNodes addObjectsFromArray:[self subNodeKeyStr:level12Node.name count:2 level:2]];
    [level13Node.childNodes addObjectsFromArray:[self subNodeKeyStr:level13Node.name count:10 level:2]];
}
- (TreeNodeModel*)treeModel {
    if(!_treeModel){
        _treeModel = [[TreeNodeModel alloc]init];
    }
    return _treeModel;
}

-(TreeNodeModel *)node:(NSString *)text level:(NSInteger)level{
    TreeNodeModel *nod = [[TreeNodeModel alloc]init];
    nod.name = text;
    nod.isExpand = NO;
    nod.nodeLevel = level;
    return nod;
}
-(NSMutableArray *)subNodeKeyStr:(NSString *)keyStr count:(NSInteger)count level:(NSInteger)level{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 1; i < count+1; i++) {
        TreeNodeModel *tempNode = [self node:[NSString stringWithFormat:@"%@ %d",keyStr,i] level:level];
        [arr addObject:tempNode];
    }
    return arr;
//    NSTreeController
}



//3.实现数据源协议
#pragma mark - NSOutlineViewDataSource
-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    //当item为空时表示根节点.
    if(!item){
        return [self.treeModel.childNodes count];
    }
    else{
        TreeNodeModel *nodeModel = item;
        return [nodeModel.childNodes count];
    }
}


-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if(!item){
        return self.treeModel.childNodes[index];
    }
    else{
        TreeNodeModel *nodeModel = item;
        return nodeModel.childNodes[index];
    }
}


-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(nonnull id)item{
    //count 大于0表示有子节点,需要允许Expandable
    if(!item){
        return [self.treeModel.childNodes count] > 0 ? YES : NO;
    } else {
//        TreeNodeModel *model = (TreeNodeModel *)item;
//        BOOL result = model.childNodes.count > 0;
        return [self checkItem:item];
    }
}
-(BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item{
    return [self checkItem:item];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item{
    return [self checkItem:item];
}
-(BOOL)checkItem:(id)item{
    TreeNodeModel *model = (TreeNodeModel *)item;
    BOOL result = model.childNodes.count > 0 ? YES : NO;
    return result;
}

-(NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item{
    TreeNodeModel *nodeModel = item;
    //使用分级来做标识符更节省内存
    NSString *idet = [NSString stringWithFormat:@"%ld",nodeModel.nodeLevel];

    if (nodeModel.nodeLevel == 2) {
        OutlineTableRowView2 *rowView = [outlineView makeViewWithIdentifier:idet owner:self];
        
        if (rowView == nil) {
            rowView = [[OutlineTableRowView2 alloc]initWithLevel:nodeModel.nodeLevel];
            rowView.identifier = idet;
        }
        rowView.model = nodeModel;
        return rowView;
    }else{
        OutlineTableRowView *rowView = [outlineView makeViewWithIdentifier:idet owner:self];

        if (rowView == nil) {
            rowView = [[OutlineTableRowView alloc]initWithLevel:nodeModel.nodeLevel];
            rowView.identifier = idet;
        }
        rowView.model = nodeModel;
        return rowView;
    }
}

//4.实现代理方法,绑定数据到节点视图
-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
 
    NSView *result  =  [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    NSArray *subviews = [result subviews];
//    NSImageView *imageView = subviews[0];
    NSTextView *field = subviews[1];
    TreeNodeModel *model = item;
    field.string = model.name;

    return result;
}

-(CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
    return 50;
}



//“5.节点选择的变化事件通知
//
//实现代理方法 outlineViewSelectionDidChange获取到选择节点后的通知

-(void)outlineViewSelectionDidChange:(NSNotification *)notification{
//-(void)outlineViewSelectionIsChanging:(NSNotification *)notification{
    NSOutlineView *treeView = notification.object;
    NSInteger row = [treeView selectedRow];
    TreeNodeModel *model = (TreeNodeModel*)[treeView itemAtRow:row];
    BOOL isExpand = [treeView isItemExpanded:model];
    if(isExpand == YES){
        model.isExpand = NO;
        [treeView collapseItem:model collapseChildren:NO];//“collapseChildren 参数表示是否收起所有的子节点。”
    }else{
        model.isExpand = YES;
        [treeView expandItem:model expandChildren:NO];//“expandChildren 参数表示是否展开所有的子节点。”
    }
    
    //    NSIndexSet *indexset = [treeView selectedRowIndexes];
    //    NSInteger inlevel = treeView.indentationPerLevel;
    //    NSIndexSet *hidenrowIndexSets = [treeView hiddenRowIndexes];
    
    //获取当前item的层级序号
    NSInteger levelForRow  = [treeView levelForRow:row];
    NSInteger levelForItem = [treeView levelForItem:model];
    NSInteger childIndexForItem = [treeView childIndexForItem:model];
    NSLog(@"row=%ld，name=%@，levelForRow=%ld，levelForItem=%ld，childIndexForItem=%ld，isItemExpanded=%d",row,model.name,levelForRow,levelForItem,childIndexForItem,isExpand);
    
    //获取指定层级下指定位置的item
    //1. 获取当前item的父层级 [treeView parentForItem:model];
    //2. 获取当前item所在父层级中的index [treeView childIndexForItem:model];
    id parent = [treeView parentForItem:model];
    TreeNodeModel *childItemInMainItem = (TreeNodeModel *)[treeView child:childIndexForItem ofItem:parent];

    
    //为完成，位置计算逻辑错误，无法完成两层级以上计算
    OutlineIndexModel *childIndexModel = [[OutlineIndexModel alloc]init];
    childIndexModel.level = levelForItem;
    childIndexModel.index = childIndexForItem;//
    if (self.tempSperNodeIndex != levelForItem) {
        childIndexModel.section = childIndexForItem;
    }else{
        childIndexModel.section = self.tempSperNodeIndex;
    }
    
    
    NSLog(@"childItemInMainItem = %@，level=%ld，section=%ld，index=%ld",childItemInMainItem.name,childIndexModel.level,childIndexModel.section,childIndexModel.index);

//    self.indexModel.section = levelForItem;
//    self.indexModel.row = childIndexForItem;
//    self.indexModel.childNode =
    
}


#pragma mark - 增减列表


//6.动态增加节点
//1) 创建节点模型对象实例item
//2) 获取选中的节点item做为父节点，将新创建的节点增加到父节点的子节点数组对象中。
//3) outlineView reloadData 重新加载
-(void)addNodeAction:(id)sender {
    NSInteger selectedRow =[self.outlineView selectedRow];
    //如果没有节点选中 则返回
    if(selectedRow < 0){
        return;
    }
    //获取增加的节点的名称
    NSString *nodeName = @"增加节点";//self.nodeNameField.stringValue;
    if(nodeName.length<=0){
        return;
    }
    TreeNodeModel *item = [self.outlineView itemAtRow:selectedRow];
    NSMutableArray *childNodes = [NSMutableArray arrayWithArray:[item childNodes]];
    
    TreeNodeModel *addNode = [[TreeNodeModel alloc]init];
    addNode.name = nodeName;
    [childNodes addObject:addNode];
    item.childNodes = childNodes;
    [self.outlineView reloadData];
    
}

//7.动态删除节点
//1) 获取选中的row对应的模型对象item
//2) 获取item的父节点,从父节点删除item
//3) outlineView reloadData 重新加载

- (void)removeNodeAction:(id)sender {
    NSInteger selectedRow =[self.outlineView selectedRow];
    //如果没有节点选中 则返回
    if(selectedRow < 0){
        return;
    }
    
    id item = [self.outlineView itemAtRow:selectedRow];
    TreeNodeModel *parentItem = [self.outlineView parentForItem:item];
    if(!parentItem){
        self.treeModel = nil;
        [self.outlineView reloadData];
    }
    else{
        
        NSMutableArray *childNodes =[NSMutableArray arrayWithArray:[parentItem childNodes]];
        [childNodes removeObject:item];
        parentItem.childNodes = childNodes;
        [self.outlineView reloadData];
    }
}

@end
