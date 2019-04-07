//
//  ZBPlayerRow.h
//  OSX
//
//  Created by LiZhenbiao on 2019/4/7.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TreeNodeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZBPlayerRow : NSTableRowView

@property (nonatomic, strong) NSImageView *imageV;
@property (nonatomic, strong) NSTextField *textV;
@property (nonatomic, strong) TreeNodeModel *model;
-(instancetype)initWithLevel:(NSInteger)level;
@end

NS_ASSUME_NONNULL_END
