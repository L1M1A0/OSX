//
//  TreeNodeModel.m
//  OSX
//
//  Created by 李振彪 on 2018/3/14.
//  Copyright © 2018年 李振彪. All rights reserved.
//

#import "TreeNodeModel.h"

@implementation TreeNodeModel

-(instancetype)init{
    if(self = [super init]){
        self.name = @"";
        self.childNodes = [NSMutableArray array];
        self.isExpand = NO;
    }
    return self;
}


//
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:self.audio forKey:@"audio"];
//    [aCoder encodeObject:self.name forKey:@"name"];
//    [aCoder encodeObject:self.childNodes forKey:@"childNodes"];
////    [aCoder encodeObject:self.isExpand forKey:@"isExpand"];
////    [aCoder encodeObject:self.nodeLevel forKey:@"nodeLevel"];
////    [aCoder encodeObject:self.superLevel forKey:@"superLevel"];
////    [aCoder encodeObject:self.sectionIndex forKey:@"sectionIndex"];
////    [aCoder encodeObject:self.rowIndex forKey:@"rowIndex"];
//
////    @property (nonatomic, strong) ZBAudioModel *audio;
////    @property (nonatomic, strong) NSString *name;
////    @property (nonatomic, strong) NSMutableArray *childNodes;//
////    @property (nonatomic, assign) BOOL isExpand;
////    @property (nonatomic, assign) NSInteger nodeLevel;//当前层级
////    //附加
////    @property (nonatomic, assign) NSInteger superLevel;//父层级
////    @property (nonatomic, assign) NSInteger sectionIndex;
////    @property (nonatomic, assign) NSInteger rowIndex;
//}
//
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    if (self) {
//        self.audio = [aDecoder decodeObjectForKey:@"audio"];
//        self.name = [aDecoder decodeObjectForKey:@"name"];
//        self.childNodes = [aDecoder decodeObjectForKey:@"childNodes"];
////        self.name = [aDecoder decodeObjectForKey:@"name"];
////        self.name = [aDecoder decodeObjectForKey:@"name"];
////        self.name = [aDecoder decodeObjectForKey:@"name"];
////        self.name = [aDecoder decodeObjectForKey:@"name"];
////        self.name = [aDecoder decodeObjectForKey:@"name"];
//
//    }
//    return self;
//}


@end
