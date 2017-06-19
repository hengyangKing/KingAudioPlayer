//
//  KingRemoteAudioFile.m
//  Example
//
//  Created by J on 2017/6/19.
//  Copyright © 2017年 J. All rights reserved.
//

#import "KingRemoteAudioFile.h"
#import <MobileCoreServices/MobileCoreServices.h>
//下载完成 cache + 文件名称
//下载中 tmp + 文件名称
#define  FILEMANAGER [NSFileManager defaultManager]

//缓存路径
#define KCachePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingFormat:@"/audioPlayerCaches"]


#define KTempPath  NSTemporaryDirectory()

@implementation KingRemoteAudioFile

+(NSString *)cacheFilePath:(NSURL *)url{
    
    [self hasLive:KCachePath];
    return [KCachePath stringByAppendingPathComponent:url.lastPathComponent];
}

+(NSString *)tmpFilePath:(NSURL *)url
{
    return [KTempPath stringByAppendingPathComponent:url.lastPathComponent];
}
+(long long)cacheFileSize:(NSURL *)url
{
    if (![self cacheFileExists:url]) {
        return 0;
    }
    NSDictionary *fileInfoDic=[FILEMANAGER attributesOfItemAtPath:[self cacheFilePath:url] error:nil];
    
    return  [fileInfoDic[NSFileSize]longLongValue];
}
+(long long)tmpFileSize:(NSURL *)url
{
    if (![self tempFileExists:url]) {
        return 0;
    }
    NSDictionary *fileInfoDic=[FILEMANAGER attributesOfItemAtPath:[self tmpFilePath:url] error:nil];
    return  [fileInfoDic[NSFileSize]longLongValue];
}
+(BOOL)cacheFileExists:(NSURL *)url{
    NSString *path=[self cacheFilePath:url];
    return [FILEMANAGER fileExistsAtPath:path];
}

+(BOOL)tempFileExists:(NSURL *)url{
    NSString *path=[self tmpFilePath:url];
    return [FILEMANAGER fileExistsAtPath:path];
}
+ (BOOL)hasLive:(NSString *)path
{
    if (![FILEMANAGER fileExistsAtPath:path])
    {
        return [FILEMANAGER createDirectoryAtPath:path
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:NULL];
    }
    return NO;
}

+(NSString *)contentType:(NSURL *)url
{
    NSString *path=[self cacheFilePath:url];
    NSString *fileExtension=path.pathExtension;
    
    CFStringRef contentTypeCF=UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension),NULL);
    //改变索引关系 进行桥接
    NSString *contentType=CFBridgingRelease(contentTypeCF);
    return contentType;
}

+(BOOL)moveTmpPathToCachePath:(NSURL *)url
{
    if (![self tempFileExists:url]) {
        return NO;
    }
    NSString *tmpPath=[self tmpFilePath:url];
    NSString *cachePath=[self cacheFilePath:url];

    return  [FILEMANAGER moveItemAtPath:tmpPath toPath:cachePath error:nil];
}
+(void)clearTmpFile:(NSURL *)url
{
    NSString *tmpPath=[self tmpFilePath:url];
    BOOL isDirectory=YES;
    
    BOOL isExists=[FILEMANAGER fileExistsAtPath:tmpPath isDirectory:&isDirectory];
    if (isExists&&!isDirectory) {
        [FILEMANAGER removeItemAtPath:tmpPath error:nil];
    }
}
@end
