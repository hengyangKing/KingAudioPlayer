//
//  KingAudioPlayerRemoteResourceLoadDelegate.m
//  Example
//
//  Created by J on 2017/6/18.
//  Copyright © 2017年 J. All rights reserved.
//

#import "KingAudioPlayerRemoteResourceLoadDelegate.h"
#import "KingRemoteAudioFile.h"
#import "KingAudioPlayerDownLoader.h"
#import "NSURL+Scheme.h"
@interface KingAudioPlayerRemoteResourceLoadDelegate()<KingAudioPlayerDownLoaderDelegate>
@property(nonatomic,strong)KingAudioPlayerDownLoader *downLoader;
@property(nonatomic,strong)NSMutableArray *loadingRequests;
@end
@implementation KingAudioPlayerRemoteResourceLoadDelegate

-(KingAudioPlayerDownLoader *)downLoader
{
    if (!_downLoader) {
        _downLoader=[[KingAudioPlayerDownLoader alloc]init];
        _downLoader.delegate=self;
    }
    return _downLoader;
}
-(NSMutableArray *)loadingRequests
{
    if (!_loadingRequests) {
        _loadingRequests=[NSMutableArray arrayWithCapacity:0];
    }
    return _loadingRequests;
}
#pragma mark AVAssetResourceLoaderDelegate
/**
 当外界需要播放一段音频资源时，会抛一个请求给这个对象
 */
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {

    // 1. 判断, 本地有没有该音频资源的缓存文件, 如果有 -> 直接根据本地缓存, 向外界响应数据(3个步骤) return
    NSURL *url = [loadingRequest.request.URL httpURL];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    if (requestOffset != currentOffset) {
        requestOffset = currentOffset;
    }
    
    if ([KingRemoteAudioFile cacheFileExists:url]) {
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
    
    // 记录所有的请求
    [self.loadingRequests addObject:loadingRequest];
    
    // 2. 判断有没有正在下载
    if (self.downLoader.loadedSize == 0) {
        [self.downLoader downloadWithURL:url offset:requestOffset];
        //        开始下载数据(根据请求的信息, url, requestOffset, requestLength)
        return YES;
    }
    
    // 3. 判断当前是否需要重新下载
    // 3.1 当资源请求, 开始点 < 下载的开始点
    // 3.2 当资源的请求, 开始点 > 下载的开始点 + 下载的长度 + 666
    if (requestOffset < self.downLoader.offset || requestOffset > (self.downLoader.offset + self.downLoader.loadedSize + 666)) {
        [self.downLoader downloadWithURL:url offset:requestOffset];
        return YES;
    }
    
    // 开始处理资源请求 (在下载过程当中, 也要不断的判断)
    [self handleAllLoadingRequest];
    
    
    return YES;

}

/**
 取消请求调用
 */
-(void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    //拖动过程中 需要清除之前请求，
    [self.loadingRequests removeObject:resourceLoader];
}

#pragma mark KingAudioPlayerDownLoaderDelegate
//下载过程中不断处理该请求
-(void)downloading
{
    [self handleAllLoadingRequest];
}

#pragma mark func
//处理本地已经下载完成的文件
- (void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    //    根据请求信息，返回给外界数据
    //    填充相应信息头
//    计算总大小
//    1.获取文件路径
    NSURL *url=loadingRequest.request.URL;
    long long totalSize=[KingRemoteAudioFile cacheFileSize:url];
    
    loadingRequest.contentInformationRequest.contentLength=totalSize;
    
    NSString *contentType=[KingRemoteAudioFile contentType:url];
    
    loadingRequest.contentInformationRequest.contentType=contentType;
    //字节区间允许访问
    loadingRequest.contentInformationRequest.byteRangeAccessSupported=YES;
    
    //相应数据给外界
    //    地址映射
    NSData *data=[NSData dataWithContentsOfFile:[KingRemoteAudioFile cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
    
    long long requestOffset=loadingRequest.dataRequest.requestedOffset;
    
    NSInteger requestLength=loadingRequest.dataRequest.requestedLength;
    
    NSData *subData=[data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    
    //    完成本次请求,一旦所有的数据都完成，才能调用完成请求方法
    [loadingRequest finishLoading];

}

/**
 处理请求
 */
-(void)handleAllLoadingRequest
{
    //    NSLog(@"在这里不断的处理请求");
    NSLog(@"-----%@", self.loadingRequests);
    NSMutableArray *deleteRequests = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingRequests) {
        // 1. 填充内容信息头
        NSURL *url = loadingRequest.request.URL;
        long long totalSize = self.downLoader.totalSize;
        loadingRequest.contentInformationRequest.contentLength = totalSize;
        NSString *contentType = self.downLoader.MIMEType;
        loadingRequest.contentInformationRequest.contentType = contentType;
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
        // 2. 填充数据
        NSData *data = [NSData dataWithContentsOfFile:[KingRemoteAudioFile tmpFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        if (data == nil) {
            data = [NSData dataWithContentsOfFile:[KingRemoteAudioFile cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        }
        
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        if (requestOffset != currentOffset) {
            requestOffset = currentOffset;
        }
        NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
        
        
        long long responseOffset = requestOffset - self.downLoader.offset;
        long long responseLength = MIN(self.downLoader.offset + self.downLoader.loadedSize - requestOffset, requestLength) ;
        
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        
        [loadingRequest.dataRequest respondWithData:subData];
        
        
        
        // 3. 完成请求(必须把所有的关于这个请求的区间数据, 都返回完之后, 才能完成这个请求)
        if (requestLength == responseLength) {
            [loadingRequest finishLoading];
            [deleteRequests addObject:loadingRequest];
        }
        
    }
    
    [self.loadingRequests removeObjectsInArray:deleteRequests];
    
}
@end
