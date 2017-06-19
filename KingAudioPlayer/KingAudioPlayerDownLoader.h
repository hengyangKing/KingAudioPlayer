//
//  KingAudioPlayerDownLoader.h
//  Example
//
//  Created by J on 2017/6/19.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol KingAudioPlayerDownLoaderDelegate<NSObject>
-(void)downloading;
@end
@interface KingAudioPlayerDownLoader : NSObject

@property(nonatomic,weak)id<KingAudioPlayerDownLoaderDelegate> delegate;


-(void)downloadWithURL:(NSURL *)url offset:(long long)offset;

/**
 是否正在下载
 */
-(BOOL)isDownLoading;
//下载起始点
@property(nonatomic,assign,readonly)long long offset;
//已经请求的文件大小
@property(nonatomic,assign,readonly)long long loadedSize;
//文件总大小
@property(nonatomic,assign,readonly)long long totalSize;
//文件类型
@property(nonatomic,copy,readonly)NSString *MIMEType;



@end
