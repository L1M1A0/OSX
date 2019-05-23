//
//  ZBKrc.h
//  OSX
//
//  Created by LiZhenbiao on 2019/5/6.
//  Copyright © 2019 李振彪. All rights reserved.
//
//---------------------
//作者：zengconggen
//来源：CSDN
//原文：https://blog.csdn.net/zengconggen/article/details/7823786
//版权声明：本文为博主原创文章，转载请附上博文链接！
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBKrc : NSObject{
    //FileStream fs;
    
    //头部4字节
    NSMutableData * HeadBytes;
    
    //异或加密内容
    NSMutableData * EncodedBytes;
    
    //解异或加密后ZIP数据
    NSMutableData * ZipBytes;
    
    //UNZIP后数据
    NSData * UnzipBytes;
}

- (NSString *)decodeInfilePath: (NSString * )filePath;


@end

NS_ASSUME_NONNULL_END
