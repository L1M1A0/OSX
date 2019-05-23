//
//  ZBAudioObject.m
//  OSX
//
//  Created by LiZhenbiao on 2019/5/8.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import "ZBAudioObject.h"
#import "ZBAudioModel.h"
#import "FHFileManager.h"


@implementation ZBAudioObject

-(NSMutableArray *)audios{
    if (!_audios) {
        _audios = [NSMutableArray array];
    }
    return _audios;
}



/**
 通过路径 获取本地音频文件（实现获取子文件中的文件）
 
 @param filePath 本地基础路径
 */
-(void)audioInPath:(NSString *)filePath{
    
    //Objective-C get list of files and subfolders in a directory 获取某路径下的所有文件，包括子文件夹中的所有文件https://stackoverflow.com/questions/19925276/objective-c-get-list-of-files-and-subfolders-in-a-directory
    //    NSString *sourcePath = self.localMusicBasePath.length == 0 ? @"/Volumes/mac biao/music/日系/" : [NSString stringWithFormat:@"%@/",self.localMusicBasePath];
    //遍历文件夹，包括子文件夹中的文件。直至遍历完所有文件。此处嵌套了10层，嵌套层级越深，获取的目录层级越深。
    [self enumerateAudio:filePath folder:@"" block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
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


/**
 根据文件基础路径，遍历该路径下的文件
 
 @param basePath 基础路径
 @param folder  子文件夹名字，可以是空字符串：@"",
 @param block  isFolder：是否是文件夹。basePath：当前基础路径。folder：子文件夹名字
 */
-(void)enumerateAudio:(NSString *)basePath folder:(NSString *)folder block:(void (^)(BOOL, NSString * _Nonnull, NSString * _Nonnull))block{
    //Objective-C get list of files and subfolders in a directory 获取某路径下的所有文件，包括子文件夹中的所有文件https://stackoverflow.com/questions/19925276/objective-c-get-list-of-files-and-subfolders-in-a-directory
    
    NSFileManager *fileManager = [NSFileManager defaultManager] ;
    NSString *newPath = [NSString stringWithFormat:@"%@/%@",basePath,folder];
    NSArray  *newDirs = [fileManager contentsOfDirectoryAtPath:newPath error:NULL];
    __weak ZBAudioObject * weakSelf = self;
    [newDirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];//文件格式
        if ([weakSelf isAudioFile:extension]  == YES) {
            
            //路径解码比较耗时间
            NSString *filePath = [newPath stringByAppendingPathComponent:filename];
            if([filePath containsString:@"file://"]){
                //去除file://
                filePath = [filePath substringFromIndex:7];
            }
            //url编码 解码路劲（重要）
            filePath = [filePath stringByRemovingPercentEncoding];
            
            NSLog(@"正在导入：%@",filename);
            ZBAudioModel *model = [[ZBAudioModel alloc]init];
            model.title = filename;
            model.path = filePath;
            model.extension = extension;
            //拼接路径
            [weakSelf.audios addObject:model];
        }else if(extension.length == 0){
            //如果是文件夹，那就继续遍历子文件夹中的
            block(YES,newPath,obj);
        }
    }];
}

/**
 根据扩展名，判断是不是音频文件
 
 @param extension 扩展名
 @return YES:音频文件
 */
-(BOOL)isAudioFile:(NSString *)extension{
    //@[@"mp3",@"flac",@"wav",@"aac",@"m4a",@"wma",@"ape",@"ogg",@"alac"]
    if ([extension isEqualToString:@"mp3"] || [extension isEqualToString:@"flac"] ||//AVAudioPlayer
        [extension isEqualToString:@"wav"] || [extension isEqualToString:@"aac"] ||
        [extension isEqualToString:@"m4a"] ||
        [extension isEqualToString:@"wma"] || [extension isEqualToString:@"ape"] ||//VLCKit
        [extension isEqualToString:@"ogg"] || [extension isEqualToString:@"tta"] ||
        [extension isEqualToString:@"alac"]) {
        return YES;
    }else{
        return NO;
    }
}


/**
 是否是AVAudioPlayer支持的格式

 @param extension 格式
 @return YES：AVAudioPlayer支持的格式
 */
-(BOOL)isAVAudioPlayerMode:(NSString *)extension{
    if ([extension isEqualToString:@"mp3"] || [extension isEqualToString:@"flac"] ||
        [extension isEqualToString:@"wav"] || [extension isEqualToString:@"aac"] ||
        [extension isEqualToString:@"m4a"] ) {
        return YES;
    }else{
        return NO;
    }
}

/**
 获取本地列表 在初始化播放列表之后，保存列表路径到本地，用于初始化程序的时候可以初始化列表
 
 @return 播放列表
 */
+ (NSMutableArray *)getPlayList {
    return [FHFileManager unarchiverAtPath:kPATH_DOCUMENT fileName:@"ZBAudioList" encodeObjectKey:@"ZBAudioListKey"];
}

/**
 保存播放列表到本地
 */
+ (void)savePlayList:(NSMutableArray *)list {
    [FHFileManager archiverAtPath:kPATH_DOCUMENT fileName:@"ZBAudioList" object:list encodeObjectKey:@"ZBAudioListKey"];
}

@end
