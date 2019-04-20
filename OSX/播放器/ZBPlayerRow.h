//
//  ZBPlayerRow.h
//  OSX
//
//  Created by LiZhenbiao on 2019/4/7.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TreeNodeModel.h"
#import "ZBTextFieldCell.h"
NS_ASSUME_NONNULL_BEGIN
#define ZBPlayerRowHeight 40

@protocol ZBPlayerRowDelegate;

@interface ZBPlayerRow : NSTableRowView

@property (nonatomic, strong) NSImageView *imageView;
@property (nonatomic, strong) NSTextField *textField;//ZBTextFieldCell
@property (nonatomic, strong) NSButton *moreBtn;//打开更多
@property (nonatomic, strong) TreeNodeModel *model;
@property (nonatomic, weak) id <ZBPlayerRowDelegate> delegate;
-(instancetype)initWithLevel:(NSInteger)level;
@end


@protocol ZBPlayerRowDelegate

-(void)playerRow:(ZBPlayerRow *)playerRow didSelectRowForModel:(TreeNodeModel *)model;
-(void)playerRowMoreBtn:(ZBPlayerRow *)playerRow;

@end

NS_ASSUME_NONNULL_END
