//
//  OutlineWCtrl.m
//  OSX
//
//  Created by 李振彪 on 2018/3/13.
//  Copyright © 2018年 李振彪. All rights reserved.
//

#import "OutlineWCtrl.h"

@interface TreeNodeModel : NSObject

@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSMutableArray *childNodes;

@end

@implementation TreeNodeModel
-(instancetype)init{
    if(self = [super init]){
        self = [super init];
        self.name = @"";
        self.childNodes = [NSMutableArray array];
    }
    return self;
}

@end


@interface OutlineWCtrl ()<NSOutlineViewDelegate,NSOutlineViewDataSource>

@property (nonatomic, strong) NSOutlineView *outlineView;
@property (nonatomic, strong) TreeNodeModel *treeModel;

@end

@implementation OutlineWCtrl

- (void)windowDidLoad {
    [super windowDidLoad];
    NSLog(@"窗口加载");
    
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)viewInWindow{
    


//    self.treeModel = [[TreeNodeModel alloc]init];
    
    //第一级根节点
    TreeNodeModel *rootNode = [[TreeNodeModel alloc]init];
    rootNode.name = @"公司";
    [self.treeModel.childNodes addObject:rootNode];
    
    //2级节点
    TreeNodeModel *level11Node = [[TreeNodeModel alloc]init];
    level11Node.name = @"电商";
    TreeNodeModel *level12Node = [[TreeNodeModel alloc]init];
    level12Node.name = @"游戏";
    TreeNodeModel *level13Node = [[TreeNodeModel alloc]init];
    level13Node.name = @"音乐";
    
    [rootNode.childNodes addObject:level11Node];
    [rootNode.childNodes addObject:level12Node];
    [rootNode.childNodes addObject:level13Node];
    
    //3级节点
    TreeNodeModel *level21Node = [[TreeNodeModel alloc]init];
    level21Node.name = @"研发";
    
    TreeNodeModel *level22Node = [[TreeNodeModel alloc]init];
    level22Node.name = @"运营";
    
    [level11Node.childNodes addObject:level21Node];
    [level11Node.childNodes addObject:level22Node];
    
    self.outlineView = [[NSOutlineView alloc]initWithFrame:NSMakeRect(0, 0, 300, 300)];
    self.outlineView.layer.backgroundColor = [NSColor blueColor].CGColor;
    self.outlineView.backgroundColor = [NSColor yellowColor];
    self.outlineView.delegate = self;
    self.outlineView.dataSource = self;
    [self.window.contentView addSubview:self.outlineView];
    [self.outlineView reloadData];
}

- (TreeNodeModel*)treeModel {
    if(!_treeModel){
        _treeModel = [[TreeNodeModel alloc]init];
    }
    return _treeModel;
}

//3.实现数据源协议
#pragma mark- NSOutlineViewDataSource
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
        return [self.treeModel.childNodes count]>0 ;
    }
    else {
        TreeNodeModel *nodeModel = item;
        return [nodeModel.childNodes count]>0;
    }
}
//4.实现代理方法,绑定数据到节点视图
-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    NSView *result  =  [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    NSArray *subviews = [result subviews];
    NSImageView *imageView = subviews[0];
    NSTextField *field = subviews[1];
    TreeNodeModel *model = item;
    field.stringValue = model.name;
    if([[model childNodes]count]<=0){
        imageView.image = [NSImage imageNamed:NSImageNameListViewTemplate];
    }
    return result;
}




//“5.节点选择的变化事件通知
//
//实现代理方法 outlineViewSelectionDidChange获取到选择节点后的通知

-(void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSOutlineView *treeView = notification.object;
    NSInteger row = [treeView selectedRow];
    TreeNodeModel *model = (TreeNodeModel*)[treeView itemAtRow:row];
    NSLog(@"name =%@",model.name);
}

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
    NSMutableArray *childNodes =[NSMutableArray arrayWithArray:[item childNodes]];
    
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
