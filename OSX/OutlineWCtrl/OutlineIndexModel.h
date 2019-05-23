//
//  OutlineIndexModel.h
//  OSX
//
//  Created by 李振彪 on 2018/3/16.
//  Copyright © 2018年 李振彪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutlineIndexModel : NSObject

/**父层级所在的层级的index，如果点前选择的item和上一次选中的item的层级不位于同一层级，就记录下来，作为下一个item的父层级*/

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, assign) NSInteger section;
/**
 当前item所在层级的row
 */
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) OutlineIndexModel *childNode;
@end
