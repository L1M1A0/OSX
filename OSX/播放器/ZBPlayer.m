//
//  ZBPlayer.m
//  OSX
//
//  Created by LiZhenbiao on 2019/4/7.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import "ZBPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "ZBMacOSObject.h"
#import "ZBPlayerSection.h"
#import "ZBPlayerRow.h"
#import "ZBAudioModel.h"

#ifdef DEBUG

#define NSLog(format,...) printf("\n[%s] %s [第%d行] %s\n",__TIME__,__FUNCTION__,__LINE__,[[NSString stringWithFormat:format,## __VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif

@interface ZBPlayer ()<NSOutlineViewDelegate,NSOutlineViewDataSource,AVAudioPlayerDelegate>

@property (nonatomic, strong) ZBMacOSObject *object;

#pragma mark - 常用功能
/** 上一曲 */
@property (nonatomic, strong) NSButton *lastBtn;
/** 播放 or 暂停 */
@property (nonatomic, strong) NSButton *playBtn;
/** 下一曲 */
@property (nonatomic, strong) NSButton *nextBtn;
/** 艺术家头像 */
@property (nonatomic, strong) NSImageView *artistImage;
/** 音频格式 */
@property (nonatomic, strong) NSTextField *formatTF;
/** 音频文件名字 */
@property (nonatomic, strong) NSTextField *audioNameTF;
/** 播放时长 */
@property (nonatomic, strong) NSTextField *durationTF;
/** 播放进度条 */
@property (nonatomic, strong) NSSlider *progressSlider;
/** 歌词按钮 */
@property (nonatomic, strong) NSButton *lyricBtn;
/** 播放循环模式：列表循环，单曲循环，随机播放，跨列表播放 */
@property (nonatomic, strong) NSButton *playModelBtn;
/** 音量按钮 */
@property (nonatomic, strong) NSButton *volumeBtn;

#pragma mark - 主功能
/** 创建列表 */
@property (nonatomic, strong) NSButton *createListBtn;
/** 选择文件目录，添加歌曲到列表 */
@property (nonatomic, strong) NSButton *addAudioBtn;

#pragma mark - 主界面
/** 播放器主活动界面 左边存放歌曲列表，右边显示歌词等其他界面 */
@property (nonatomic, strong) NSSplitView *playerMainBoard;
/** 歌曲列表层级页面 */
@property (nonatomic, strong) NSOutlineView *audioListOutlineView;
/** 歌曲列表层级页面 的背景页面 */
@property (nonatomic, strong) NSScrollView *audioListScrollView;


#pragma mark - 数据
/** 所有的音频路径(注：暂时只支持一个列表) */
@property (nonatomic, strong) NSMutableArray *localMusics;
/** 音频的名称 */
@property (nonatomic, strong) NSArray *musicFileNames;

#pragma mark - 播放器控制
/** 播发器 */
@property (nonatomic, strong) AVAudioPlayer *player;
/** 当前播放的歌曲在总列表中的index (注：暂时只支持一个列表) */
@property (nonatomic, assign) NSInteger currentTrackIndex;
/** 本地音乐基础路径 */
@property (nonatomic, copy) NSString *localMusicBasePath;
/** 是否是随机数 */
@property (nonatomic, assign) BOOL isRandom;



#pragma mark - 临时
@property (nonatomic, strong) TreeNodeModel *treeModel;


@end

@implementation ZBPlayer

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)viewInWindow{
    
    self.object = [[ZBMacOSObject alloc]init];
    [self initData];
    
    //注：似乎没法使用懒加载，只能手动调用了
    [self playerMainBoard];
    [self audioListOutlineView];
    [self audioListScrollView];
    [self btn];
    [self musicPlayer];
 
    
    NSView *view1 = [self viewForSplitView:[NSColor orangeColor] frame:NSMakeRect(50, 30,400 , 400)];
    [view1 addSubview:_audioListScrollView];
    [_audioListScrollView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view1.mas_top).with.offset(0);
        make.bottom.equalTo(view1.mas_bottom).with.offset(0);
        make.left.equalTo(view1.mas_left).with.offset(0);
        make.right.equalTo(view1.mas_right).with.offset(0);
    }];

    //增加左右视图
    [_playerMainBoard addSubview:view1];
    
    [_audioListOutlineView reloadData];
}

- (NSView *)viewForSplitView:(NSColor *)color frame:(NSRect)frame{
    NSView *leftView = [[NSView alloc]initWithFrame:NSZeroRect];
    leftView.autoresizingMask = NSViewMinXMargin;
    leftView.wantsLayer = YES;
    leftView.layer.backgroundColor = color.CGColor;
    [leftView setAutoresizesSubviews:YES];
    return leftView;
}


#pragma mark - UI

/**
 播发器主面板

 @return <#return value description#>
 */
-(NSSplitView *)playerMainBoard{
    if(!_playerMainBoard){
        _playerMainBoard = [[NSSplitView alloc]init];
        _playerMainBoard.dividerStyle = NSSplitViewDividerStyleThick;
        _playerMainBoard.vertical = YES;
        _playerMainBoard.wantsLayer = YES;
        _playerMainBoard.layer.backgroundColor = [NSColor greenColor].CGColor;
        [self.window.contentView addSubview:_playerMainBoard];
        [_playerMainBoard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.window.contentView.mas_top).offset(0);
            make.bottom.equalTo(self.window.contentView.mas_bottom).offset(-80);
            make.left.equalTo(self.window.contentView.mas_left).offset(0);
            make.right.equalTo(self.window.contentView.mas_right).offset(0);
        }];
        
        //增加左右视图
//        [_playerMainBoard addSubview:view1];
//        [_playerMainBoard addSubview:view2];
//        //    [splitView insertArrangedSubview:[self viewForSplitView:[NSColor orangeColor]] atIndex:1];
//
//        //    [splitView drawDividerInRect:NSMakeRect(80, 0, 50, 50)];
            [_playerMainBoard setPosition:80 ofDividerAtIndex:0];
    }
    return _playerMainBoard;
}



-(NSOutlineView *)audioListOutlineView{
    if (!_audioListOutlineView) {
     
        _audioListOutlineView = [[NSOutlineView alloc]init];
        _audioListOutlineView.delegate = self;
        _audioListOutlineView.dataSource = self;
        _audioListOutlineView.wantsLayer = YES;
        _audioListOutlineView.backgroundColor = [NSColor yellowColor];
        //    _audioListOutlineView.layer.backgroundColor = [NSColor blueColor].CGColor;
        //    [self.window.contentView addSubview:s_audioListOutlineView];
        //    _audioListOutlineView.outlineTableColumn.hidden = YES;
        NSTableColumn *column1=[[NSTableColumn alloc]initWithIdentifier:@"name"];
        column1.title = @"可创建一个空的，不创建的话，内容会跑到bar底下";
        [_audioListOutlineView addTableColumn:column1];

    }
    
    return _audioListOutlineView;
}

-(NSScrollView *)audioListScrollView{
    if(!_audioListScrollView){
        _audioListScrollView = [[NSScrollView alloc] init];
        [_audioListScrollView setHasVerticalScroller:NO];
        [_audioListScrollView setHasHorizontalScroller:NO];
        [_audioListScrollView setFocusRingType:NSFocusRingTypeNone];
        [_audioListScrollView setAutohidesScrollers:YES];
        [_audioListScrollView setBorderType:NSBezelBorder];
        [_audioListScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_audioListScrollView setDocumentView:_audioListOutlineView];
    }
    return _audioListScrollView;
}

-(void)btn{

    [self button:NSMakeRect(10, 10, 70, 50) title:@"暂停" tag:0];
    self.lastBtn      = [self button:NSMakeRect(100, 10, 70, 50)  title:@"上一曲" tag:1];
    self.playBtn      = [self button:NSMakeRect(190, 10, 70, 50) title:@"播放"   tag:2];
    self.nextBtn      = [self button:NSMakeRect(270, 10, 70, 50) title:@"下一曲" tag:3];
    self.addAudioBtn  = [self button:NSMakeRect(350, 10, 70, 50) title:@"导入"   tag:4];
    self.playModelBtn = [self button:NSMakeRect(430, 10, 70, 50) title:@"随机"   tag:5];

}


- (NSButton *)button:(NSRect)frame title:(NSString *)title tag:(NSInteger)tag {
    NSButton *btn = [self.object button:frame title:title tag:tag type:NSButtonTypePushOnPushOff target:self superView:self.window.contentView];
    btn.wantsLayer = YES;
    btn.layer.backgroundColor = [NSColor greenColor].CGColor;
    btn.action = @selector(btnAction:);
    return btn;
}
-(void)btnAction:(NSButton *)sender{
    if(sender.tag == 0){
        //暂停
        [self.player pause];
    }else if(sender.tag == 1){
        //上一曲
        if (self.currentTrackIndex == 0) {
            self.currentTrackIndex = self.localMusics.count;
        }else{
            self.currentTrackIndex--;
        }
        [self.player prepareToPlay];
        [self startPlaying];        
    }else if(sender.tag == 2){
        //播放
        if (self.currentTrackIndex > self.localMusics.count) {
            self.currentTrackIndex = 0;
        }
        [self.player prepareToPlay];
        [self startPlaying];
    }else if(sender.tag == 3){
        //下一曲
        if (self.currentTrackIndex == self.localMusics.count) {
            self.currentTrackIndex = 0;
        }else{
            self.currentTrackIndex++;
        }
        [self.player prepareToPlay];
        [self startPlaying];
    }else if(sender.tag == 4){
        [self openPanel];
    }else if(sender.tag == 5){
        self.isRandom = YES;
        u_int32_t  num = (u_int32_t)self.localMusics.count;
        u_int32_t a = arc4random_uniform(num);
        self.currentTrackIndex = a;
        [self.player prepareToPlay];
        [self startPlaying];
//        u_int32_t arc4random_uniform();
    }
    
    
    
}


//8********************************

#pragma mark - 数据源
-(void)initData{
    self.treeModel = [[TreeNodeModel alloc]init];
    //根节点
    TreeNodeModel *rootNode1 = [self node:@"播放列表1" level:0];
    
    //2级节点
    for(int i = 0; i< self.localMusics.count; i++){
        ZBAudioModel *audio = self.localMusics[i];
        TreeNodeModel *childNode = [self node:audio.title level:1];
        [rootNode1.childNodes addObject:childNode];
    }
    [self.treeModel.childNodes addObjectsFromArray:@[rootNode1]];
}

-(TreeNodeModel *)node:(NSString *)text level:(NSInteger)level{
    TreeNodeModel *nod = [[TreeNodeModel alloc]init];
    nod.name = text;
    nod.isExpand = NO;
    nod.nodeLevel = level;
    return nod;
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
    
    if (nodeModel.nodeLevel == 1) {
        ZBPlayerRow *rowView = [outlineView makeViewWithIdentifier:idet owner:self];
        
        if (rowView == nil) {
            rowView = [[ZBPlayerRow alloc]initWithLevel:nodeModel.nodeLevel];
            rowView.identifier = idet;
        }
        rowView.model = nodeModel;
        return rowView;
    }else{
        ZBPlayerSection *rowView = [outlineView makeViewWithIdentifier:idet owner:self];
        
        if (rowView == nil) {
            rowView = [[ZBPlayerSection alloc]initWithLevel:nodeModel.nodeLevel];
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
    NSTextField *field = subviews[1];
    TreeNodeModel *model = item;
    field.stringValue = model.name;
    
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
    if (levelForRow == 1) {
        if(self.currentTrackIndex != childIndexForItem){
            self.currentTrackIndex = childIndexForItem;
            [self.player prepareToPlay];
            [self startPlaying];
            NSLog(@"正在播放：%@",model.name);

        }else{
            NSLog(@"正在播放：%@",model.name);
        }
    }

    
}





#pragma mark - 面板：NSOpenPanel 读取电脑文件 获取文件名，路径
- (void)openPanel{
    self.localMusics = [NSMutableArray array];
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseFiles = YES ;//----------“是否允许选择文件”
    openDlg.canChooseDirectories = YES;//-----“是否允许选择目录”
    openDlg.allowsMultipleSelection = YES;//--“是否允许多选”
    openDlg.allowedFileTypes = @[@"mp3",@"flac",@"wav",@"aac",@"m4a",@"wma",@"ape",@"ogg",@"alac"];//---“允许的文件名后缀”
    openDlg.treatsFilePackagesAsDirectories = YES;
    //openDlg.URL = @"";////“保存用户选择的文件/文件夹路径path”
    [openDlg beginWithCompletionHandler: ^(NSInteger result){
        if(result==NSFileHandlingPanelOKButton){
            NSArray *fileURLs = [openDlg URLs];//“保存用户选择的文件/文件夹路径path”
            [_localMusics addObjectsFromArray:fileURLs];
            for(NSURL *url in fileURLs) {
                NSError *error;
                NSString *string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
                if(!error){
                    
                    
                }
            }
            
            self.localMusicBasePath = [fileURLs.firstObject path];
            [self loacalMusicInPath];//更新列表
            [self initData];
            [self.audioListOutlineView reloadData];
            
            //NSFileManager
            NSLog(@"获取本地文件的路径：%@,,%@",fileURLs,self.localMusicBasePath);
        }
    }];
    
}

#pragma mark - 音乐

-(void)musicPlayer{
    
    //    NSURL *playUrl = [NSURL URLWithString:@"http://baobab.wdjcdn.com/14573563182394.mp4"];
    //    self.player = [[AVPlayer alloc] initWithURL:playUrl];
    //    self.player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:@"/Users/vae/Documents/GitHub/OSX/OSX/松本晃彦 - 栄の活躍.mp3"]];
    // 1 初始化播放器需要指定音乐文件的路径
    NSString *path = [[NSBundle mainBundle]pathForResource:@"松本晃彦 - 栄の活躍" ofType:@"mp3"];
    // 2 将路径字符串转换成url，从本地读取文件，需要使用fileURL
    NSURL *url = [NSURL fileURLWithPath:path];
    // 3 初始化音频播放器
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    // 4 设置循环播放
    // 设置循环播放的次数
    // 循环次数=0，声音会播放一次
    // 循环次数=1，声音会播放2次
    // 循环次数小于0，会无限循环播放
    [self.player setNumberOfLoops:-1];
    [self.player setVolume:0.5];
    // 5 准备播放
    [self.player prepareToPlay];
    
    self.musicFileNames = @[@"松本晃彦 - 栄の活躍",@"吉田潔 - Potu",@"吉田潔 - Private Moon",@"吉田潔 - はるかな旅"];
    self.currentTrackIndex = 0;
    [self loacalMusicInPath];
    
    //        [self.player setVolume:sender.floatValue/100];

}


/**
 通过路径 获取本地音乐（实现获取子文件中的文件）
 */
-(void)loacalMusicInPath{
    
    //Objective-C get list of files and subfolders in a directory 获取某路径下的所有文件，包括子文件夹中的所有文件https://stackoverflow.com/questions/19925276/objective-c-get-list-of-files-and-subfolders-in-a-directory
    NSString *sourcePath = self.localMusicBasePath.length == 0 ? @"/Volumes/mac biao/music/日系/" : [NSString stringWithFormat:@"%@/",self.localMusicBasePath];
    self.localMusics = [NSMutableArray array];
    //遍历文件夹，包括子文件夹中的文件。直至遍历完所有文件。此处嵌套了10层，嵌套层级越深，获取的目录层级越深。
    [self enumerateAudio:sourcePath folder:@"" block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
        if (isFolder == YES) {
            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                if (isFolder == YES) {
                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                        if (isFolder == YES) {
                            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                if (isFolder == YES) {
                                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                        if (isFolder == YES) {
                                            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                                if (isFolder == YES) {
                                                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                                        if (isFolder == YES) {
                                                            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                                                if (isFolder == YES) {
                                                                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                                                        if (isFolder == YES) {
                                                                            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                                                                if (isFolder == YES) {
                                                                                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                                                                        if (isFolder == YES) {
                                                                                            
                                                                                        }
                                                                                    }];
                                                                                }
                                                                            }];
                                                                        }
                                                                    }];
                                                                }
                                                            }];
                                                        }
                                                    }];
                                                }
                                            }];
                                        }
                                    }];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];
}

-(BOOL)isAudioFormat:(NSString *)format{
    if ([format isEqualToString:@"mp3"] || [format isEqualToString:@"flac"] || [format isEqualToString:@"wav"] || [format isEqualToString:@"aac"] || [format isEqualToString:@"m4a"]) {
        return YES;
    }else{
        return NO;
    }
}


-(void)enumerateAudio:(NSString *)basePath folder:(NSString *)folder block:(void(^)(BOOL isFolder,NSString *basePath,NSString *folder))block{
    //Objective-C get list of files and subfolders in a directory 获取某路径下的所有文件，包括子文件夹中的所有文件https://stackoverflow.com/questions/19925276/objective-c-get-list-of-files-and-subfolders-in-a-directory
    
    NSFileManager *fileManager = [NSFileManager defaultManager] ;
    NSString *newPath = [NSString stringWithFormat:@"%@/%@",basePath,folder];
    NSArray  *newDirs = [fileManager contentsOfDirectoryAtPath:newPath error:NULL];
    [newDirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];//文件格式
        if ([self isAudioFormat:extension]  == YES) {
            
            //路径解码比较耗时间
            NSString *filePath = [newPath stringByAppendingPathComponent:filename];
            if([filePath containsString:@"file://"]){
                //去除file://
                filePath = [filePath substringFromIndex:7];
            }
            //url编码 解码路劲（重要）
            filePath = [filePath stringByRemovingPercentEncoding];
            
            NSLog(@"正在导入：%@",filePath);
            ZBAudioModel *model = [[ZBAudioModel alloc]init];
            model.title = filename;
            model.path = filePath;
            model.extension = extension;
            //拼接路径
            [self.localMusics addObject:model];
        }else if(extension.length == 0){
            //如果是文件夹，那就继续遍历子文件夹中的
            block(YES,newPath,obj);
        }
    }];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //切歌
    if (flag) {
        if (self.localMusics == nil || self.localMusics.count == 0) {
            if (self.currentTrackIndex < [self.musicFileNames count] - 1) {
                self.currentTrackIndex ++;
                [self startPlaying];
            }
        }else{
            if (self.currentTrackIndex < [self.localMusics count] - 1) {
                self.currentTrackIndex ++;
                [self startPlaying];
            }
        }
    }
}

//开始播放
- (void)startPlaying{
    
    if (self.localMusics == nil || self.localMusics.count == 0) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[[NSString alloc] initWithString:[self.musicFileNames  objectAtIndex:self.currentTrackIndex]] ofType:@"mp3"]] error:NULL];
        _player.delegate = self;
        [_player play];
    }else{
        
#pragma mark 播放本地音乐
        /*
         
         *参考:AVPlayer 为什么不能播放本地音乐~ http://www.cocoachina.com/bbs/read.php?tid-1743038.html
         1.要将target->capabilities->app sandbox->network->outgoing connection(clinet)勾选
         1.1 注：使用FileManager方式读取文件，似乎不用打开（待确实验证）
         
         2.如果遇到errors encountered while discovering extensions: Error Domain=PlugInKit Code=13 "query cancelled" UserInfo={NSLocalizedDescription=query cancelled}，只能加载部分文件就中断了。参考：https://my.oschina.net/rainwz/blog/2218590
         2.1 打开 Product > Scheme > Edit Scheme，在run或者其他地方的arguments下的Enviroment Variables下添加环境变量：OS_ACTIVITY_MODE 值：disable
         2.2 如果没法打印日志，那全局添加以下代码
         #ifdef DEBUG
         
         #define NSLog(format,...) printf("\n[%s] %s [第%d行] %s\n",__TIME__,__FUNCTION__,__LINE__,[[NSString stringWithFormat:format,## __VA_ARGS__] UTF8String]);
         #else
         #define NSLog(format, ...)
         #endif
         
         */
        
        //        for(int i = 0; i<self.localMusics.count;i++){
        //            NSString *str  = [NSString stringWithFormat:@"%@",[self.localMusics objectAtIndex:i]];
        //            NSString *decodeURL = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //            NSLog(@"已选中%ld：%@",self.localMusics.count,decodeURL);
        //        }
        
        if (self.isRandom == YES) {
            u_int32_t  num = (u_int32_t)self.localMusics.count;
            u_int32_t a = arc4random_uniform(num);
            self.currentTrackIndex = a;
        }
        NSLog(@"已选中 %ld 个音频文件",self.localMusics.count);
//        NSString *str  = [NSString stringWithFormat:@"%@",[self.localMusics objectAtIndex:self.currentTrackIndex]];
//        if([str containsString:@"file://"]){
//            str = [str substringFromIndex:7];//去除file://
//        }
//
//        //url编码 解码（重要）
//        NSString *decodeURL = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        ZBAudioModel *audio = [self.localMusics objectAtIndex:self.currentTrackIndex];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audio.path] error:NULL];
        _player.delegate = self;
        [_player play];
        
    }
}

- (void)restart:(id)sender
{
    //    [[AFSoundManager sharedManager] restart];
    //    _player = nil;
    //    currentTrackNumber = 0;
    //    [self startPlaying];
}

#pragma mark 获取音频文件的元数据 ID3
/**
 获取音频文件的元数据 ID3
 */
-(void)mDefineUpControl{
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"松本晃彦 - 栄の活躍" ofType:@"mp3"];//[self.wMp3URL objectAtIndex: 0 ];//随便取一个，说明
    //文件管理，取得文件属性
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *dictAtt = [fm attributesOfItemAtPath:filePath error:nil];
    
    
    //取得音频数据
    NSURL *fileURL=[NSURL fileURLWithPath:filePath];
    AVURLAsset *mp3Asset=[AVURLAsset URLAssetWithURL:fileURL options:nil];
    
    NSString *singer;//歌手
    NSString *song;//歌曲名
    NSImage *songImage;//图片
    NSString *albumName;//专辑名
    NSString *fileSize;//文件大小
    NSString *voiceStyle;//音质类型
    NSString *fileStyle;//文件类型
    NSString *creatDate;//创建日期
    NSString *savePath; //存储路径
    
    for (NSString *format in [mp3Asset availableMetadataFormats]) {
        for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
            if([metadataItem.commonKey isEqualToString:@"title"]){
                song = (NSString *)metadataItem.value;//歌曲名
                
            }else if ([metadataItem.commonKey isEqualToString:@"artist"]){
                singer = [NSString stringWithFormat:@"%@",metadataItem.value];//歌手
            }
            //专辑名称
            else if ([metadataItem.commonKey isEqualToString:@"albumName"])
            {
                albumName = (NSString *)metadataItem.value;
            }else if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                //                NSDictionary *dict=(NSDictionary *)metadataItem.value;
                //                NSData *data=[dict objectForKey:@"data"];
                //                image=[NSImage imageWithData:data];//图片
            }
            
        }
    }
    savePath = filePath;
    float tempFlo = [[dictAtt objectForKey:@"NSFileSize"] floatValue]/(1024*1024);
    fileSize = [NSString stringWithFormat:@"%.2fMB",[[dictAtt objectForKey:@"NSFileSize"] floatValue]/(1024*1024)];
    NSString *tempStrr  = [NSString stringWithFormat:@"%@", [dictAtt objectForKey:@"NSFileCreationDate"]] ;
    creatDate = [tempStrr substringToIndex:19];
    fileStyle = [filePath substringFromIndex:[filePath length]-3];
    if(tempFlo <= 2){
        voiceStyle = @"普通";
    }else if(tempFlo > 2 && tempFlo <= 5){
        voiceStyle = @"良好";
    }else if(tempFlo > 5 && tempFlo < 10){
        voiceStyle = @"标准";
    }else if(tempFlo > 10){
        voiceStyle = @"高清";
    }
    
    NSArray *tempArr = [[NSArray alloc] initWithObjects:@"歌手:",@"歌曲名称:",@"专辑名称:",@"文件大小:",@"音质类型:",@"文件格式:",@"创建日期:",@"保存路径:", nil];
    NSArray *tempArrInfo = [[NSArray alloc] initWithObjects:singer,song,albumName,fileSize,voiceStyle,fileStyle,creatDate,savePath, nil];
    
    NSMutableString *mstr = [NSMutableString string];
    for(int i = 0;i < [tempArr count]; i ++){
        NSString *strTitle = [tempArr objectAtIndex:i];
        NSString *strInfo  = [tempArrInfo objectAtIndex:i];
        [mstr appendString:[NSString stringWithFormat:@"%@%@\n",strTitle,strInfo]];
    }
}




@end
