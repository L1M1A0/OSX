//
//  ZBAudioDB.m
//  OSX
//
//  Created by LiZhenbiao on 2019/5/1.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import "ZBAudioDB.h"
@interface ZBAudioDB ()
{
    //声明一个数据库对象（用于操作数据库）
    FMDatabase *_dataBase;
    FMDatabaseQueue *_queue;
}
@end

@implementation ZBAudioDB
+(ZBAudioDB *)shareFMDataBase{
    static ZBAudioDB *mDB = nil;
    if (mDB == nil) {
        mDB = [[super alloc]init];
        [mDB myQueue];
    }
    
    
    return mDB;
}

-(void)myQueue{
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* filePath = [docsdir stringByAppendingPathComponent:@"FMDBTestDemo.sqlite"];
    _queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    NSLog(@"filePath:%@",filePath);
    
}

-(void)qunueCreatPeopleTable{
//    @property (nonatomic, strong) ZBAudioModel *audio;
//    @property (nonatomic, strong) NSString *name;
//    @property (nonatomic, strong) NSMutableArray *childNodes;//
//    @property (nonatomic, assign) BOOL isExpand;
//    @property (nonatomic, assign) NSInteger nodeLevel;//当前层级
//    //附加
//    @property (nonatomic, assign) NSInteger superLevel;//父层级
//    @property (nonatomic, assign) NSInteger sectionIndex;
//    @property (nonatomic, assign) NSInteger rowIndex;

//    NULL，值是NULL
//    INTEGER，值是有符号整形，根据值的大小以1,2,3,4,6或8字节存放
//    REAL，值是浮点型值，以8字节IEEE浮点数存放
//    TEXT，值是文本字符串，使用数据库编码（UTF-8，UTF-16BE或者UTF-16LE）存放
//    BLOB，二进制数据（iOS的NSData）
    
    NSString *creatTableString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS TreeNodeModel(model_name text, audio blob, car childNodes)"];
    [_queue inDatabase:^(FMDatabase *db) {
        BOOL b = [db executeUpdate:creatTableString];
        NSLog(@"create table is %d",b);
    }];
}
-(void)qunueInsertPeople:(TreeNodeModel *)model{
    
    NSData *childNodesData = [NSKeyedArchiver archivedDataWithRootObject:model.childNodes];
    NSData *audioData = [NSKeyedArchiver archivedDataWithRootObject:model.audio];
    
    [_queue inDatabase:^(FMDatabase *db) {
        BOOL insert = [db executeUpdate:@"INSERT INTO TreeNodeModel (model_name, audio, childNodes) VALUES (?,?,?)",model.name,audioData,childNodesData];
        
        if (insert) {
            NSLog(@"添加成员成功！！");
        }else{
            NSLog(@"添加成员失败！！");
        }
    }];
}
-(NSArray *)qunueGetPeople{
    __block NSMutableArray *dataArray = nil;
    
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *FROM TreeNodeModel"];
    
    [_queue inDatabase:^(FMDatabase *db) {
        dataArray = [NSMutableArray array];
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            //从表单中获取相应字段的value
            
            TreeNodeModel *tree = [TreeNodeModel new];
            tree.name = [result stringForColumn:@"model_name"];
            //pets
            NSData *childNodesData = [result dataForColumn:@"childNodes"];
            NSArray * childNodes  = [NSKeyedUnarchiver unarchiveObjectWithData:childNodesData];
            //car
            NSData *audioData = [result dataForColumn:@"audio"];
            ZBAudioModel *audio = [NSKeyedUnarchiver unarchiveObjectWithData:audioData];
            
            tree.audio = audio;
            tree.childNodes = [NSMutableArray arrayWithArray:childNodes];
            
            [dataArray addObject:tree];
        }
    }];
    return dataArray;
}
-(void)qunueDeleteAllPeople{
    
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM TreeNodeModel"];
    [_queue inDatabase:^(FMDatabase *db) {
        
        if (![db executeUpdate:sqlstr])
        {
            NSLog(@"Erase table 失败!");
        }else{
            NSLog(@"Erase table 成功!");
        }
    }];
}
@end
