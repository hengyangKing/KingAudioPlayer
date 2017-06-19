//
//  KingRemoteAudioFile.h
//  Example
//
//  Created by J on 2017/6/19.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KingRemoteAudioFile : NSObject
/**
 根据url获取下载完成的路径
 */
+(NSString *)cacheFilePath:(NSURL *)url;
/**
 获取临时缓存路径
 */
+(NSString *)tmpFilePath:(NSURL *)url;
/**
 是否本地有缓存

 @param url url
 */
+(BOOL)cacheFileExists:(NSURL *)url;

/**
 是否存在临时文件
 */
+(BOOL)tempFileExists:(NSURL *)url;
/**
 得到url对应本地文件大小
 @param url url
 */
+(long long)cacheFileSize:(NSURL *)url;


/**
 得到url对应缓存文件大小

 @param url url
 */
+(long long)tmpFileSize:(NSURL *)url;



/**
 获取文件类型

 @param url url
 @return 文件类型字符串
 */
+(NSString *)contentType:(NSURL *)url;


/**
 移动文件

 @param url 资源url
 @return 是否成功
 */
+(BOOL)moveTmpPathToCachePath:(NSURL *)url;


/**
 清除本地缓存

 @param url url
 */
+(void)clearTmpFile:(NSURL *)url;


@end
