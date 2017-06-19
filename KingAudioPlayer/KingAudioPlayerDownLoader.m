//
//  KingAudioPlayerDownLoader.m
//  Example
//
//  Created by J on 2017/6/19.
//  Copyright © 2017年 J. All rights reserved.
//

#import "KingAudioPlayerDownLoader.h"
#import "KingRemoteAudioFile.h"
//下载某一区间数据
@interface KingAudioPlayerDownLoader()<NSURLSessionDataDelegate>

@property(nonatomic,strong)NSURLSession *sesssion;
@property(nonatomic,strong)NSOutputStream *outputSrteam;
@property(nonatomic,strong)NSURL *url;

/**
 已经加载的大小
 */
@end
@implementation KingAudioPlayerDownLoader


-(NSURLSession *)sesssion
{
    if (!_sesssion) {
        _sesssion=[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _sesssion;
}
-(void)setOffset:(long long)offset
{
    _offset=offset;
}
-(void)setLoadedSize:(long long)loadedSize
{
    _loadedSize=loadedSize;
}
-(void)setTotalSize:(long long)totalSize
{
    _totalSize=totalSize;
}
-(void)setMIMEType:(NSString *)MIMEType
{
    _MIMEType=MIMEType;
}
#pragma mark func

-(void)cancelAndClean
{
    [self.sesssion invalidateAndCancel];
    _sesssion=nil;
    [KingRemoteAudioFile clearTmpFile:self.url];
    self.loadedSize=0;
}
-(void)downloadWithURL:(NSURL *)url offset:(long long)offset
{
    self.url=url;
    self.offset=offset;
    [self cancelAndClean];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:self.url cachePolicy:(NSURLRequestReloadIgnoringLocalCacheData) timeoutInterval:0.0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    
    NSURLSessionDataTask *task=[self.sesssion dataTaskWithRequest:request];
    //挂起
    [task resume];
    
}
-(BOOL)isDownLoading
{
    return [[NSNumber numberWithLongLong:self.loadedSize]boolValue];
}

#pragma mark NSURLSessionDataDelegate
//请求头
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
    //    对比文件大小
    //    通过回调控制是否继续请求
    
    self.totalSize=[response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangStr=response.allHeaderFields[@"Content-Range"];
    if (contentRangStr.length) {
        //    [@"Content-Range"]字段在某些情况下 只有在请求头设置过才会有
        self.totalSize = [[[contentRangStr componentsSeparatedByString:@"/"]lastObject] longLongValue];
    }

    self.MIMEType=response.MIMEType;
    self.outputSrteam=[NSOutputStream outputStreamToFileAtPath:[KingRemoteAudioFile tmpFilePath:self.url] append:YES];
    [self.outputSrteam open];
    completionHandler(NSURLSessionResponseAllow);
}
//接收
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if ([self.delegate respondsToSelector:@selector(downloading)]) {
        [self.delegate downloading];
    }
    self.loadedSize+=data.length;
    [self.outputSrteam write:data.bytes maxLength:data.length];
}
//完成
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (!error) {
//        本地缓存大小==文件总大小 ->移动
        if ([KingRemoteAudioFile tmpFileSize:self.url]==self.totalSize) {
//            移动
            [KingRemoteAudioFile moveTmpPathToCachePath:self.url];
        }
    }
}


@end
