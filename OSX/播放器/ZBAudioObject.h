//
//  ZBAudioObject.h
//  OSX
//
//  Created by LiZhenbiao on 2019/5/8.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBAudioObject : NSObject


/**
 遍历之后获得的文件数组
 */
@property (nonatomic, strong) NSMutableArray *audios;


/**
 通过路径 获取本地音频文件（实现获取子文件中的文件）

 @param filePath 本地基础路径
 */
-(void)audioInPath:(NSString *)filePath;

/**
 根据文件基础路径，遍历该路径下的文件
 
 @param basePath 基础路径
 @param folder  子文件夹名字，可以是空字符串：@"",
 @param block  isFolder：是否是文件夹。basePath：当前基础路径。folder：子文件夹名字
 */
-(void)enumerateAudio:(NSString *)basePath folder:(NSString *)folder block:(void(^)(BOOL isFolder,NSString *basePath,NSString *folder))block;

/**
 根据扩展名，判断是不是音频文件

 @param extension 扩展名
 @return YES:音频文件
 */
-(BOOL)isAudioFile:(NSString *)extension;

/**
 是否是AVAudioPlayer支持的格式
 
 @param extension 格式
 @return YES：AVAudioPlayer支持的格式
 */
-(BOOL)isAVAudioPlayerMode:(NSString *)extension;
@end

NS_ASSUME_NONNULL_END
