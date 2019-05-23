//
//  OutlineTableRowView.h
//  OSX
//
//  Created by 李振彪 on 2018/3/14.
//  Copyright © 2018年 李振彪. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TreeNodeModel.h"

@interface OutlineTableRowView : NSTableRowView{
    
}

@property (nonatomic, strong) NSImageView *imageV;
@property (nonatomic, strong) NSTextView *textV;
@property (nonatomic, strong) TreeNodeModel *model;
-(instancetype)initWithLevel:(NSInteger)level;
@end
