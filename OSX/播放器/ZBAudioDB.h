//
//  ZBAudioDB.h
//  OSX
//
//  Created by LiZhenbiao on 2019/5/1.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreeNodeModel.h"
#import "FMDB.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZBAudioDB : NSObject
//建立单例对象
+(ZBAudioDB *)shareFMDataBase;

-(void)qunueCreatPeopleTable;
-(void)qunueInsertPeople:(TreeNodeModel *)people;
-(NSArray *)qunueGetPeople;
-(void)qunueDeleteAllPeople;

@end

NS_ASSUME_NONNULL_END
