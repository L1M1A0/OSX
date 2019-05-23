//
//  ZBKrc.m
//  OSX
//
//  Created by LiZhenbiao on 2019/5/6.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import "ZBKrc.h"
//#import "GTMNSData+zlib.h"

@implementation ZBKrc

//异或加密 密钥
//- (NSString *)decodeInfilePath: (NSString * )filePath
//{
//    NSString * EncKey = @"@Gaw^2tGQ61-ÎÒni";
//    //char EncKey[] = { '@', 'G', 'a', 'w', '^', '2', 't', 'G', 'Q', '6', '1', '-', 'Î', 'Ò', 'n', 'i' };
//    
//    NSData * totalBytes = [[NSMutableData alloc] initWithContentsOfFile:filePath];
//    //HeadBytes = [[NSMutableData alloc] initWithData:[totalBytes subdataWithRange:NSMakeRange(0, 4)]];
//    EncodedBytes = [[NSMutableData alloc] initWithData:[totalBytes subdataWithRange:NSMakeRange(4, totalBytes.length - 4)]];
//    
//    ZipBytes = [[NSMutableData alloc] initWithCapacity:EncodedBytes.length];
//    
//    Byte * encodedBytes = EncodedBytes.mutableBytes;
//    
//    int EncodedBytesLength = EncodedBytes.length;
//    
//    for (int i = 0; i < EncodedBytesLength; i++)
//    {
//        int l = i % 16;
//        char c = [EncKey characterAtIndex:l];
//        
//        Byte b = (Byte)((encodedBytes[i]) ^ c);
//        
//        [ZipBytes appendBytes:&b length:1];
//        
//    }
//    UnzipBytes = [NSData gtm_dataByInflatingData:ZipBytes];
//    
//    NSString * s = [[NSString alloc] initWithData:UnzipBytes encoding:NSUTF8StringEncoding];
//    
//    return s;
//}

@end
