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
#import "ZBPlayerSplitView.h"
#import <VLCKit/VLCKit.h>
#import "ISSoundAdditions.h"//音量管理
#import "ZBSliderViewController.h"

#ifdef DEBUG

#define NSLog(format,...) printf("\n[%s] %s [第%d行] %s\n",__TIME__,__FUNCTION__,__LINE__,[[NSString stringWithFormat:format,## __VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif

@interface ZBPlayer ()<NSSplitViewDelegate,NSOutlineViewDelegate,NSOutlineViewDataSource,AVAudioPlayerDelegate,VLCMediaPlayerDelegate,ZBPlayerSectionDelegate,ZBPlayerRowDelegate>
{
    VLCMediaPlayer *vclPlayer;
}
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
/** 音量窗口 */
@property (nonatomic, strong) NSPopover *volumePopover;

#pragma mark - 主功能
/** 创建列表 */
@property (nonatomic, strong) NSButton *createListBtn;


#pragma mark - 主界面
/** 播放器主活动界面 左边存放歌曲列表，右边显示歌词等其他界面 */
@property (nonatomic, strong) ZBPlayerSplitView *playerMainBoard;
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
/** 是否是随机播放 */
@property (nonatomic, assign) BOOL isRandom;
/** 是否正在播放  */
@property (nonatomic, assign) BOOL isPlaying;

/** 主色调 */
@property (nonatomic, strong) NSColor *mainColor;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CFRunLoopTimerRef timerForRemainTime;



#pragma mark - 临时
@property (nonatomic, strong) TreeNodeModel *treeModel;

/**
 是否是使用VCL框架播放模式，0：AVAudioPlayer，1:VCLPlayer
 */
@property (nonatomic, assign) BOOL isVCLPlayMode;



@end

@implementation ZBPlayer

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)viewInWindow{
    //窗口标题栏透明
    self.window.titlebarAppearsTransparent = YES;
    //窗口背景颜色
    /* 222222FF */
    self.mainColor = [NSColor colorWithCalibratedRed:0x22/255.0 green:0x22/255.0 blue:0x22/255.0 alpha:0xFF/255.0];//[NSColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
    [self.window setBackgroundColor: self.mainColor];
    
    self.object = [[ZBMacOSObject alloc]init];
    self.isVCLPlayMode = YES;
    [self initData];
    
    //注：似乎没法使用懒加载，只能手动调用了
    [self playerMainBoard];
    [self audioListOutlineView];
    [self audioListScrollView];
    [self musicPlayer];
    [self controllBar];
    [self vclPlayer];
    [self addNotification];


    NSView *view1 = [self viewForSplitView:[NSColor orangeColor]];
    [view1 addSubview:_audioListScrollView];
    [_audioListScrollView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view1.mas_top).with.offset(0);
        make.bottom.equalTo(view1.mas_bottom).with.offset(0);
        make.left.equalTo(view1.mas_left).with.offset(0);
        make.right.equalTo(view1.mas_right).with.offset(0);
    }];
    
    NSView *view2 = [self viewForSplitView:self.mainColor];
    
    //增加左右分栏视图,数量任意加
    [_playerMainBoard addSubview:view1];
    [_playerMainBoard addSubview:view2];
    
    [_audioListOutlineView reloadData];
}


- (NSView *)viewForSplitView:(NSColor *)color{
    //设置frame的值似乎没什么意义
    NSView *leftView = [[NSView alloc]initWithFrame:NSZeroRect];
    leftView.autoresizingMask = NSViewMinXMargin;
    leftView.wantsLayer = YES;
    leftView.layer.backgroundColor = color.CGColor;
    [leftView setAutoresizesSubviews:YES];
    return leftView;
}


#pragma mark - UI


#pragma mark - playerMainBoard
/**
 播发器主面板

 @return <#return value description#>
 */
-(ZBPlayerSplitView *)playerMainBoard{
    if(!_playerMainBoard){
        _playerMainBoard = [[ZBPlayerSplitView alloc]init];
        _playerMainBoard.dividerStyle = NSSplitViewDividerStyleThick;
        _playerMainBoard.vertical = YES;
        _playerMainBoard.delegate = self;
        _playerMainBoard.wantsLayer = YES;
        _playerMainBoard.layer.backgroundColor = [NSColor greenColor].CGColor;
        [_playerMainBoard adjustSubviews];
        [self.window.contentView addSubview:_playerMainBoard];
        [_playerMainBoard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.window.contentView.mas_top).offset(0);
            make.bottom.equalTo(self.window.contentView.mas_bottom).offset(-70);
            make.left.equalTo(self.window.contentView.mas_left).offset(0);
            make.right.equalTo(self.window.contentView.mas_right).offset(0);
        }];
        
        //增加左右视图
//        [_playerMainBoard addSubview:view1];
//        [_playerMainBoard addSubview:view2];
//        //    [splitView insertArrangedSubview:[self viewForSplitView:[NSColor orangeColor]] atIndex:1];
//
//        //    [splitView drawDividerInRect:NSMakeRect(80, 0, 50, 50)];
            [_playerMainBoard setPosition:100 ofDividerAtIndex:0];
    }
    return _playerMainBoard;
}



-(NSOutlineView *)audioListOutlineView{
    if (!_audioListOutlineView) {
     
        _audioListOutlineView = [[NSOutlineView alloc]init];
        _audioListOutlineView.delegate = self;
        _audioListOutlineView.dataSource = self;
        _audioListOutlineView.wantsLayer = YES;
        _audioListOutlineView.backgroundColor = [NSColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
        //    _audioListOutlineView.layer.backgroundColor = [NSColor blueColor].CGColor;
        //    [self.window.contentView addSubview:s_audioListOutlineView];
        //    _audioListOutlineView.outlineTableColumn.hidden = YES;
        NSTableColumn *column1 = [[NSTableColumn alloc]initWithIdentifier:@"name"];
        column1.title = @" ";//@"可创建一个空的，不创建的话，内容会跑到bar底下";
        [_audioListOutlineView addTableColumn:column1];
        
    }
    
    return _audioListOutlineView;
}

-(NSScrollView *)audioListScrollView{
    if(!_audioListScrollView){
        _audioListScrollView = [[NSScrollView alloc] init];
        [_audioListScrollView setHasVerticalScroller:YES];
        [_audioListScrollView setHasHorizontalScroller:NO];
        [_audioListScrollView setFocusRingType:NSFocusRingTypeNone];
        [_audioListScrollView setAutohidesScrollers:YES];
        [_audioListScrollView setBorderType:NSBezelBorder];
        [_audioListScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_audioListScrollView setDocumentView:_audioListOutlineView];
    }
    return _audioListScrollView;
}

-(void)controllBar{
    self.lastBtn = [self button:NSMakeRect(10, 15, 40, 40) title:@"上一曲" tag:1 image:@"statusBarPreviewSelected" alternateImage:@"statusBarPreview"];
    self.lastBtn = [self border:self.lastBtn];
    self.playBtn = [self button:NSMakeRect(60, 10, 50, 50) title:@"播放"   tag:2 image:@"statusBarPlaySelected" alternateImage:@"statusBarPlay"];
    self.playBtn = [self border:self.playBtn];
    self.nextBtn = [self button:NSMakeRect(120, 15, 40, 40) title:@"下一曲" tag:3 image:@"statusBarNextSelected" alternateImage:@"statusBarNext"];
    self.nextBtn = [self border:self.nextBtn];
    
    self.volumeBtn  = [self button:NSMakeRect(170, 15, 40, 40) title:@"音量" tag:4 image:@"volumeSelected" alternateImage:@"volumeSelected"];
    self.volumeBtn  = [self border:self.volumeBtn];
    [self volumePopover];//音量窗口
    
    self.playModelBtn = [self button:NSMakeRect(220, 15, 40, 40) title:@"模式" tag:5 image:@"" alternateImage:@""];
    self.playModelBtn = [self border:self.playModelBtn];

    self.progressSlider = [self.object slider:NSSliderTypeLinear frame:NSMakeRect(270, 15, 450, 8)  superView:self.window.contentView target:self action:@selector(progressAction:)];
    self.progressSlider.layer.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor;
//    self.progressSlider.numberOfTickMarks = 0;//标尺分节段数量，将无法设置线条颜色,且滑动指示器会变成三角模式
    self.progressSlider.appearance = [NSAppearance currentAppearance];
    self.progressSlider.trackFillColor = [NSColor redColor];//跟踪填充颜色，需要先设置appearance
    
    self.audioNameTF = [self textField:NSMakeRect(270, 23, 450, 20) holder:@"歌名" fontsize:12];
    self.durationTF  = [self textField:NSMakeRect(270, 43, 450, 15) holder:@"时长" fontsize:10];
}


- (NSButton *)button:(NSRect)frame title:(NSString *)title tag:(NSInteger)tag image:(NSString *)image alternateImage:(NSString *)alternateImage {
    NSButton *btn = [self.object button:frame title:title tag:tag type:NSButtonTypeMomentaryChange target:self superView:self.window.contentView];
    btn.wantsLayer = YES;
    btn.layer.backgroundColor = [NSColor colorWithCalibratedRed:0x2C/255.0 green:0x28/255.0 blue:0x2D/255.0 alpha:0xFF/255.0].CGColor;
    btn.action = @selector(btnAction:);
    
    //设置图片类型的按钮，不能设置标题，不能带边框，设置图片，可以添加鼠标悬浮提示
    btn.title = @"";
    btn.bordered = NO;//是否带边框
    btn.image = [NSImage imageNamed:image];//常态
    btn.alternateImage = [NSImage imageNamed:alternateImage];
    btn.toolTip = title;
    return btn;
}
- (NSButton *)border:(NSButton *)btn{
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = btn.frame.size.width/2;
    btn.layer.borderColor = [NSColor whiteColor].CGColor;
    btn.layer.borderWidth = 3;
    return btn;
}
-(void)btnAction:(NSButton *)sender{
    if(sender.tag == 0){
       
    }else if(sender.tag == 1){
        //上一曲
        if (self.currentTrackIndex == 0) {
            self.currentTrackIndex = self.localMusics.count;
        }else{
            self.currentTrackIndex--;
        }
        [self startPlaying];
    }else if(sender.tag == 2){
        if(self.isPlaying == NO){
            [self setIsPlaying:YES];
        }else{
            [self setIsPlaying:NO];
        }
        
    }else if(sender.tag == 3){
        //下一曲
        if (self.currentTrackIndex == self.localMusics.count) {
            self.currentTrackIndex = 0;
        }else{
            self.currentTrackIndex++;
        }
        [self startPlaying];
    }else if(sender.tag == 4){
        //音量控制
        [self.volumePopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSRectEdgeMaxY];
    }else if(sender.tag == 5){
        //播放模式
        self.isRandom = YES;
        u_int32_t  num = (u_int32_t)self.localMusics.count;
        u_int32_t a = arc4random_uniform(num);
        self.currentTrackIndex = a;
        [self startPlaying];
//        u_int32_t arc4random_uniform();
    }
    
}



-(void)setIsPlaying:(BOOL)isPlaying{
    _isPlaying = isPlaying;
    if(isPlaying == YES){
        //播放
        if (self.currentTrackIndex > self.localMusics.count || !self.currentTrackIndex) {
            self.currentTrackIndex = 0;
        }
        [self startPlaying];

    }else{
        //暂停
        if (self.isVCLPlayMode == YES) {
            [vclPlayer pause];
        }else{
            [self.player pause];
        }
        [self.playBtn setImage:[NSImage imageNamed:@"statusBarPlaySelected"]];
        [self.playBtn setAlternateImage:[NSImage imageNamed:@"statusBarPlay"]];
        CFRunLoopTimerInvalidate(self.timerForRemainTime);
    }
    
}

-(void)progressAction:(NSSlider *)slider{
    NSLog(@"sliderValue_%ld,%f,%@",slider.integerValue,slider.floatValue,slider.stringValue);
    if (self.isVCLPlayMode == true) {
        //秒转毫秒
        NSNumber *num = [NSNumber numberWithDouble:slider.doubleValue*1000];
        VLCTime *tmpTime = [VLCTime timeWithNumber:num];
        [vclPlayer setTime:tmpTime];
    }else{
        //AVAudionPlayer
        self.player.currentTime = slider.integerValue;
    }


}






-(NSTextField *)textField:(NSRect)frame holder:(NSString *)holder fontsize:(CGFloat)size{
    NSTextField *tf = [[NSTextField alloc]initWithFrame:frame];
    tf.textColor = [NSColor whiteColor];
    tf.alignment = NSTextAlignmentLeft;
    [tf setBezeled:NO];
    [tf setDrawsBackground:NO];
    [tf setEditable:NO];
    tf.font = [NSFont systemFontOfSize:size];
    tf.placeholderString = holder;

//    tf.wantsLayer = YES;
//    tf.layer.backgroundColor = [NSColor orangeColor].CGColor;
//    tf.stringValue = @"textView";

    [self.window.contentView addSubview:tf];
    return tf;
}

-(NSPopover *)volumePopover{
    if(!_volumePopover){
        //NSPopoverBehaviorApplicationDefined:NSPopover的关闭需要App自己负责控制
        //NSPopoverBehaviorTransient:只要点击到NSPopover显示的窗口之外就自动关闭
        //NSPopoverBehaviorSemitransient:,只要点击到NSPopover显示的窗口之外就自动关闭,但是点击到当前App 窗口之外不会关闭。
        //xib
        //PopoverVCtrl *vc = [[PopoverVCtrl alloc]initWithNibName:@"PopoverVCtrl" bundle:nil];
        //纯代码
        ZBSliderViewController *vc = [[ZBSliderViewController alloc]init];
        vc.defaltVolume = _player.volume;
        _volumePopover = [[NSPopover alloc]init];
        _volumePopover.contentViewController = vc;
        _volumePopover.behavior = NSPopoverBehaviorTransient;
        _volumePopover.animates = YES;
        _volumePopover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
        //[_popover close];

    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(volumeSliderIsChanging:) name:@"volumeSliderIsChanging" object:nil];
    return _volumePopover;
}


/** 修改音量*/
-(void)volumeSliderIsChanging:(NSNotification *)noti{
//    NSLog(@"volumeSliderIsChanging:%@",noti);
    //[self.player setVolume:sender.floatValue/100];
    self.player.volume = [noti.object[@"stringValue"] floatValue]/100;
    vclPlayer.audio.volume =  [noti.object[@"stringValue"] intValue];
}

#pragma mark - 计时器

/**
 设置定时器，暂时不知道怎么暂停
 */
-(void)runLoopTimerForRemainTime{
    if(!_timerForRemainTime){
        CGFloat timeInterVal = 1.0;
        __weak __typeof(self) weakSelf = self;
        CFRunLoopTimerRef timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + timeInterVal, timeInterVal, 0, 0, ^(CFRunLoopTimerRef timer) {
            if (weakSelf.isVCLPlayMode == true) {
                self.progressSlider.maxValue = [self countDuration:vclPlayer.media.length.stringValue];
                weakSelf.progressSlider.stringValue = [NSString stringWithFormat:@"%f",weakSelf.progressSlider.doubleValue + 1.0];
                
            }else {
                weakSelf.progressSlider.stringValue = [NSString stringWithFormat:@"%f",weakSelf.progressSlider.doubleValue + 1.0];
                NSString *allTime = [weakSelf countTime:weakSelf.player.duration];
                NSString *remaining = [weakSelf countTime:weakSelf.progressSlider.doubleValue];
                weakSelf.durationTF.stringValue = [NSString stringWithFormat:@"%@ / %@",remaining,allTime];
                
            }
        });
        
        _timerForRemainTime = timer;
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), _timerForRemainTime, kCFRunLoopCommonModes);
    }
    
   
}




//8********************************
#pragma mark -  NSSplitViewDelegate
/** 设置每个栏的最小值，可以根据dividerIndex单独设置 */
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0) {
        return 400;
    }else{
        return 600;
    }
    
}
/** 设置每个栏的最大值，可以根据dividerIndex单独设置 */
-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
    if (dividerIndex == 0) {
        return 400;
    }else{
        return 600;
    }
}


/**
 在缩放splitView的时候，控制指定DividerAtIndex代表的View的宽和高。
 此处，不随着splitView的尺寸变化而变化DividerAtIndex==0的viewc的尺寸
 @param oldSize 原来的尺寸，
 */
- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
    CGFloat oldWidth = splitView.arrangedSubviews.firstObject.frame.size.width;
    [splitView adjustSubviews];
    [splitView setPosition:oldWidth ofDividerAtIndex:0];
}
#pragma mark - 数据源
-(void)initData{
    self.treeModel = [[TreeNodeModel alloc]init];
    //根节点
    TreeNodeModel *rootNode1 = [self node:@"播放列表" level:0];
    
    //2级节点
    for(int i = 0; i< self.localMusics.count; i++){
        ZBAudioModel *audio = self.localMusics[i];
        TreeNodeModel *childNode = [self node:audio.title level:1];
        childNode.audio = audio;
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


-(float)countDuration:(NSString *)time{
    NSArray *arr = [time componentsSeparatedByString:@":"];
    double  duration  = 0;
    if (arr.count == 2) {
        duration = [arr[0] doubleValue] * 60 + [arr[1] doubleValue];
    }else if (arr.count == 3){
        duration = [arr[0] doubleValue] * 60 * 60 + [arr[1] doubleValue] * 60 + [arr[2] doubleValue];
    }else{
        //正常情况下不会出现这样的情况
        duration = [arr[0] doubleValue];
    }
    return duration;
}

/**
 将时间(单位：秒)转化为时分秒。如：115 -> 01:55
 */
-(NSString *)countTime:(float)duration{
    int h = duration/60/60;//时
    int m = (int)(duration/60)%60;//分,可能有问题 (duration/60)%60
    int s = (int)duration % 60;//n秒
    NSString *time = [NSString stringWithFormat:@"%@ : %@",[self fill0:m],[self fill0:s]];
    if (h > 0) {
        time = [NSString stringWithFormat:@"%@ : %@",[self fill0:h],time];
    }
    return time;
    
}

/**
 对小与10的数字补 @"0"，如：3 -> 03
 */
-(NSString *)fill0:(int)number{
    if (number < 10) {
        return [NSString stringWithFormat:@"0%d",number];
    }else{
        return [NSString stringWithFormat:@"%d",number];
    }
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

#pragma mark - NSOutlineViewDelegate

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
        rowView.delegate = self;
        return rowView;
    }else{
        ZBPlayerSection *rowView = [outlineView makeViewWithIdentifier:idet owner:self];
        
        if (rowView == nil) {
            rowView = [[ZBPlayerSection alloc]initWithLevel:nodeModel.nodeLevel];
            rowView.identifier = idet;
        }
        rowView.delegate = self;
        rowView.model = nodeModel;
        return rowView;
    }
}

//4.实现代理方法,绑定数据到节点视图
-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    NSView *result  =  [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    //可以通过这个代理填充数据，也可以通过NSTableRowView（可以自定义）中的drawRect:方法赋值。注：此处需要注意子控件的类型
    NSArray *subviews = [result subviews];
    //NSImageView *imageView = subviews[0];
    NSTextField *field = subviews[1];
    TreeNodeModel *model = item;
    field.stringValue = model.name;
    return result;
}

-(CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
    TreeNodeModel *model = item;
    if(model.nodeLevel == 0){
        return ZBPlayerSectionHeight;
    }else{
        return ZBPlayerRowHeight;
    }
}



//“5.节点选择的变化事件通知
//实现代理方法 outlineViewSelectionDidChange获取到选择节点后的通知
-(void)outlineViewSelectionDidChange:(NSNotification *)notification{
    NSOutlineView *treeView = notification.object;
    NSInteger row = [treeView selectedRow];
    TreeNodeModel *model = (TreeNodeModel*)[treeView itemAtRow:row];

    //    NSIndexSet *indexset = [treeView selectedRowIndexes];
    //    NSInteger inlevel = treeView.indentationPerLevel;
    //    NSIndexSet *hidenrowIndexSets = [treeView hiddenRowIndexes];

    //获取当前item的层级序号
    NSInteger levelForRow  = [treeView levelForRow:row];
    NSInteger levelForItem = [treeView levelForItem:model];
    NSInteger childIndexForItem = [treeView childIndexForItem:model];
    NSLog(@"row=%ld，name=%@，levelForRow=%ld，levelForItem=%ld，childIndexForItem=%ld",row,model.name,levelForRow,levelForItem,childIndexForItem);
    if(levelForRow == 0){
        //根列表，展开 or 关闭列表
        BOOL isExpand = [treeView isItemExpanded:model];
        if(isExpand == YES){
            model.isExpand = NO;
            [treeView collapseItem:model collapseChildren:NO];//“collapseChildren 参数表示是否收起所有的子节点。”
        }else{
            model.isExpand = YES;
            [treeView expandItem:model expandChildren:NO];//“expandChildren 参数表示是否展开所有的子节点。”
        }
    }else if (levelForRow == 1) {
        //列表第一层 播放
        if(self.currentTrackIndex != childIndexForItem){
            self.currentTrackIndex = childIndexForItem;
            self.isPlaying = YES;
        }else{
            NSLog(@"正在播放：%@",model.name);
        }
    }
}

- (void)outlineViewSelectionIsChanging:(NSNotification *)notification{

}

#pragma mark - ZBPlayerRowDelegate
-(void)playerRow:(ZBPlayerRow *)playerRow didSelectRowForModel:(TreeNodeModel *)model{
    
    NSLog(@"ZBPlayerRow__%@",model.name);
    NSInteger childIndexForItem = [self.audioListOutlineView childIndexForItem:model];
    if (model.nodeLevel == 1) {
        //列表第一层 播放
        if(self.currentTrackIndex != childIndexForItem){
            self.currentTrackIndex = childIndexForItem;
            self.isPlaying = YES;
        }else{
            NSLog(@"正在播放：%@",model.name);
        }
    }
}

-(void)playerRowMoreBtn:(ZBPlayerRow *)playerRow{
    //show file in finder 打开文件所在文件夹
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:playerRow.model.audio.path]]];
}
#pragma mark - ZBPlayerSectionDelegate
-(void)playerSectionMoreBtn:(ZBPlayerSection *)playerSection{
    [self openPanel];
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
//            for(NSURL *url in fileURLs) {
//                NSError *error;
//                NSString *string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
//                if(!error){
//                }else{
//                }
//            }
            
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
    
    self.musicFileNames = @[@"松本晃彦 - 栄の活躍"];
    self.currentTrackIndex = 0;
    [self loacalMusicInPath];
    [self initData];
    [self.audioListOutlineView reloadData];
    

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
    //@[@"mp3",@"flac",@"wav",@"aac",@"m4a",@"wma",@"ape",@"ogg",@"alac"]
    //暂时不支持以下格式，建议用ffmpeg、vlc、mpv的第三方： [format isEqualToString:@"wma"] || [format isEqualToString:@"ape"] || [format isEqualToString:@"ogg"] || [format isEqualToString:@"alac"] 
    if ([format isEqualToString:@"mp3"] || [format isEqualToString:@"flac"] || [format isEqualToString:@"wav"] || [format isEqualToString:@"aac"] || [format isEqualToString:@"m4a"] || [format isEqualToString:@"wma"] || [format isEqualToString:@"ape"] || [format isEqualToString:@"ogg"] || [format isEqualToString:@"alac"]) {
        return YES;
    }else{
        return NO;
    }
}


/**
 根据文件基础路径，遍历该路径下的文件

 @param basePath 基础路径
 @param folder  子文件夹名字，可以是空字符串：@"",
 @param block  isFolder：是否是文件夹。basePath：当前基础路径。folder：子文件夹名字
 */
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
    if (flag) {
        [self changeAudio];
    }
}


/** 切歌 */
- (void)changeAudio{
    //切歌
    if (self.localMusics == nil || self.localMusics.count == 0) {
        if (self.currentTrackIndex < [self.musicFileNames count] - 1) {
            self.currentTrackIndex ++;
            [self startPlaying];
        }
    }else{
        if (self.isRandom == YES) {
            u_int32_t  num = (u_int32_t)self.localMusics.count;
            u_int32_t a = arc4random_uniform(num);
            self.currentTrackIndex = a;
        }else{
            if (self.currentTrackIndex < [self.localMusics count] - 1) {
                self.currentTrackIndex ++;
            }
        }
        [self startPlaying];
    }
}

//开始播放
- (void)startPlaying{
    
    if(_player){
        _player = nil;
    }
    //播放工程目录下的文件
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
        
        ZBAudioModel *audio = [self.localMusics objectAtIndex:self.currentTrackIndex];
        NSError *error =  nil;
        
        if([audio.extension isEqualToString:@"mp3"] || [audio.extension isEqualToString:@"flac"] || [audio.extension isEqualToString:@"wav"] || [audio.extension isEqualToString:@"aac"] || [audio.extension isEqualToString:@"m4a"] ){
            self.isVCLPlayMode = false;
            [vclPlayer pause];
            //_player = [[AVAudioPlayer alloc] initWithData:self.audioData fileTypeHint:AVFileTypeMPEGLayer3 error:&error];
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audio.path] error:&error];
            _player.delegate = self;
            [_player prepareToPlay];
            [_player play];
            self.progressSlider.maxValue = _player.duration;
        }else{
            self.isVCLPlayMode = true;
            [self.player pause];
            
            VLCMedia *movie = [VLCMedia mediaWithURL:[NSURL fileURLWithPath:audio.path]];
            [vclPlayer setMedia:movie];
            [vclPlayer play];
        }
        NSLog(@"已选中 %ld 个音频文件,正在播放：%@，error__%@",self.localMusics.count,audio.title,error);
        self.progressSlider.integerValue = 0;
        [self runLoopTimerForRemainTime];
        [self.playBtn setImage:[NSImage imageNamed:@"statusBarPauseSelected"]];
        [self.playBtn setAlternateImage:[NSImage imageNamed:@"statusBarPause"]];
        self.audioNameTF.stringValue = audio.title;
        self.audioNameTF.toolTip = audio.title;
        //[self mDefineUpControl:audio.path];

    }
}



#pragma mark 获取音频文件的元数据 ID3
/**
 获取音频文件的元数据 ID3
 */
-(void)mDefineUpControl:(NSString *)filePath{
//    filePath = [[NSBundle mainBundle]pathForResource:@"松本晃彦 - 栄の活躍" ofType:@"mp3"];//[self.wMp3URL objectAtIndex: 0 ];//随便取一个，说明
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


#pragma mark - VCLKit
- (void)vclPlayer{
    //创建是特别卡顿
    
    //初始化列表的时候卡顿
//    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^{
//        // 追加任务1
//        vclPlayer = [[VLCMediaPlayer alloc]init];
//        [vclPlayer setDelegate:self];
//
//    });
    vclPlayer = [[VLCMediaPlayer alloc]init];
    [vclPlayer setDelegate:self];
//    CGFloat currentSound = [NSSound systemVolume];
}



#pragma mark - VLCMediaPlayerDelegate
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification{
    NSLog(@"mediaPlayerStateChanged_%@,%@",aNotification,VLCMediaPlayerStateToString(vclPlayer.state));
}
- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification{
//    NSLog(@"mediaPlayerTimeChanged_%@",aNotification);
    //,vclPlayer.remainingTime
//    NSLog(@"%@,%@,%d,%@",vclPlayer.time.stringValue,vclPlayer.time.value,vclPlayer.time.intValue,vclPlayer.time.verboseStringValue);
    self.durationTF.stringValue = [NSString stringWithFormat:@"%@ / %@",vclPlayer.time.stringValue,vclPlayer.media.length.stringValue];
    //出错：有些歌在最后几秒就停了
//    if ([vclPlayer.time.stringValue isEqualTo:vclPlayer.media.length.stringValue]) {
//        [self changeAudio];
//    }
    //解决有些歌在最后几秒就停了（解码出错），思路：剩余时长2秒的时候，手动切歌
    double all = [self countDuration:vclPlayer.media.length.stringValue];
    double cur = [self countDuration:vclPlayer.time.stringValue];
    if (all - cur < 1.5) {
        NSLog(@"%f,%f,%f",all,cur,all-cur);
        [self changeAudio];
    }
}




#pragma mark - 监听窗口变化

/**
 监听窗口变化
 */
-(void)addNotification{
    
    //    //观察窗口拉伸
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(screenResize) name:NSWindowDidResizeNotification object:nil];
    //    //即将进入全屏
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willEnterFull:) name:NSWindowWillEnterFullScreenNotification object:nil];
    //    //即将推出全屏
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willExitFull:) name:NSWindowWillExitFullScreenNotification object:nil];
    //    //已经推出全屏
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didExitFull:) name:NSWindowDidExitFullScreenNotification object:nil];
    //    //NSWindowDidMiniaturizeNotification
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didMiniaturize:) name:NSWindowDidMiniaturizeNotification object:nil];
    //    //窗口即将关闭
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willClose:) name:NSWindowWillCloseNotification object:nil];
}



@end
