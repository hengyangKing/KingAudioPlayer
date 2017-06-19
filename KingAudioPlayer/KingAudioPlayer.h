//
//  KingAudioPlayer.h
//  Example
//
//  Created by J on 2017/6/14.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KingAudioPlayerFormat.h"


typedef NS_ENUM(NSInteger,KingAudioPlayerState)  {
    KingAudioPlayerStateIsUnknown=0,
    KingAudioPlayerStateIsLoading,
    KingAudioPlayerStateIsPlaying,
    KingAudioPlayerStateIsStoped,
    KingAudioPlayerStateIsPause,
    KingAudioPlayerStateIsFailed,
    KingAudioPlayerStateIsFinish
} ;

@interface KingAudioPlayer : NSObject

+(instancetype)shareInstance;

/**
 播放音频

 @param url url
 @param isCache 是否需要缓存
 */
-(void)playUrl:(NSURL *)url isCache:(BOOL)isCache;

-(void)pause;

-(void)resume;

-(void)stop;

-(void)seekWithTimeDiffer:(NSInteger)differ;

-(void)seekWithTimeProgress:(float)progress;

#pragma mark 属性

/**
 总长度
 */
@property(nonatomic,assign,readonly)NSTimeInterval totalTime;

/**
 当前时长
 */
@property(nonatomic,assign,readonly)NSTimeInterval currentTime;

/**
 播放进度
 */
@property(nonatomic,assign,readonly)float progress;

/**
 当前播放地址
 */
@property(nonatomic,strong,readonly)NSURL *url;

/**
 缓冲进度
 */
@property(nonatomic,assign,readonly)float loadDataProgress;

/**
 静音
 */
@property(nonatomic,assign)BOOL muted;

/**
 音量
 */
@property(nonatomic,assign)float volume;

/**
 速度
 */
@property(nonatomic,assign)float rate;


/**
 状态
 */
@property(nonatomic,assign,readonly)KingAudioPlayerState state;


/**
 状态变化block
 */
@property(nonatomic,copy)void *(^KingAudioPlayerStateChangeBlock)(KingAudioPlayerState state);
@end
