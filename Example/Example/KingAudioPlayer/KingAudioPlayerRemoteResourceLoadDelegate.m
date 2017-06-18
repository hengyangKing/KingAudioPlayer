//
//  KingAudioPlayerRemoteResourceLoadDelegate.m
//  Example
//
//  Created by J on 2017/6/18.
//  Copyright © 2017年 J. All rights reserved.
//

#import "KingAudioPlayerRemoteResourceLoadDelegate.h"

@implementation KingAudioPlayerRemoteResourceLoadDelegate

/**
 当外界需要播放一段音频资源时，会抛一个请求给这个对象
 */
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
//    根据请求信息，返回给外界数据
//    填充相应信息头
    loadingRequest.contentInformationRequest.contentLength=1;
    loadingRequest.contentInformationRequest.contentType=@"";
    //字节区间允许访问
    loadingRequest.contentInformationRequest.byteRangeAccessSupported=YES;
    
    //相应数据给外界
//    地址映射
    NSData *data=[NSData dataWithContentsOfFile:@"" options:NSDataReadingMappedIfSafe error:nil];
    long long requestOffset=loadingRequest.dataRequest.requestedOffset;
    NSInteger requestLength=loadingRequest.dataRequest.requestedLength;
    
    NSData *subData=[data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    
    
    [loadingRequest.dataRequest respondWithData:subData];
    
//    完成本次请求,一旦所有的数据都完成，才能调用完成请求方法
    [loadingRequest finishLoading];
        
    return YES;
}

/**
 取消请求调用
 */
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge{

    
}
@end
