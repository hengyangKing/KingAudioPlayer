//
//  KingAudioPlayer.m
//  Example
//
//  Created by J on 2017/6/14.
//  Copyright © 2017年 J. All rights reserved.
//

#import "KingAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "KingAudioPlayerRemoteResourceLoadDelegate.h"
#import "NSURL+Scheme.h"
#define kStatus @"status"
#define kPlayback @"playbackLikelyToKeepUp"

@interface KingAudioPlayer()<NSCopying,NSMutableCopying>
{
    BOOL _isUserPause;
}
@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)KingAudioPlayerRemoteResourceLoadDelegate *resourceLoaderDelegate;

@end
@implementation KingAudioPlayer
#pragma mark - 单例方法
static KingAudioPlayer *_shareInstance;
+(instancetype)shareInstance
{
    if (!_shareInstance) {
        _shareInstance=[[KingAudioPlayer alloc]init];
    }
    return _shareInstance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _shareInstance;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _shareInstance;
}
#pragma mark lazy

#pragma mark func

-(void)playUrl:(NSURL *)url isCache:(BOOL)isCache
{
    NSURL *currentURL=((AVURLAsset *)self.player.currentItem.asset).URL;
    if ([url isEqual:currentURL]||[[url streamingURL]isEqual:currentURL]) {
        //当前播放任务已经存在 
        [self resume];
        return;
    }
    if (self.player.currentItem) {
        [self removeObserver];
    }
    _url=url;
    
    if (isCache) {
        url=[url streamingURL];
    }
    
//    资源请求
    AVURLAsset *asset=[AVURLAsset assetWithURL:url];
    //网络音频的请求 是通过asset 调用代理相关方法实现，拦截加载请求，只需要修改其代理方法
    self.resourceLoaderDelegate=[KingAudioPlayerRemoteResourceLoadDelegate new];
    [asset.resourceLoader setDelegate:self.resourceLoaderDelegate queue:dispatch_get_main_queue()];
    
//    资源组织
    AVPlayerItem *item=[AVPlayerItem playerItemWithAsset:asset];
    
    [item addObserver:self forKeyPath:kStatus options:(NSKeyValueObservingOptionNew) context:nil];
    //监听资源准备状态
    [item addObserver:self forKeyPath:kPlayback options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playInterupt:) name:AVPlayerItemPlaybackStalledNotification object:item];

//    资源的播放
    self.player=[AVPlayer playerWithPlayerItem:item];
    
}

-(void)pause
{
    [self.player pause];
    _isUserPause=YES;
    if (self.player) {
        self.state=KingAudioPlayerStateIsPause;
    }
}

-(void)resume
{
    [self.player play];
    _isUserPause=NO;
//    playbackLikelyToKeepUp数据组织者准备完毕
    if (self.player&&self.player.currentItem.playbackLikelyToKeepUp) {
        self.state=KingAudioPlayerStateIsPlaying;
    }
}

-(void)stop
{
    [self.player pause];
    self.player=nil;
    if (!self.player) {
        self.state=KingAudioPlayerStateIsStoped;
    }
}

-(void)seekWithTimeDiffer:(NSInteger)differ
{
    //当前时长
    NSTimeInterval playSec=self.currentTime;
    
    playSec += differ;
    
    [self seekWithTimeProgress:(1.0*playSec/self.totalTime)];

}

-(void)seekWithTimeProgress:(float)progress
{
    if (progress < 0 || progress > 1) {
        return;
    }
    
    // 可以指定时间节点去播放
    // 时间: CMTime : 影片时间
    // 影片时间 -> 秒
    // 秒 -> 影片时间
    
    // 1. 当前音频资源的总时长
    CMTime totalTime = self.player.currentItem.duration;
    // 2. 当前音频, 已经播放的时长
    //    self.player.currentItem.currentTime
    
    NSTimeInterval totalSec = CMTimeGetSeconds(totalTime);
    NSTimeInterval playTimeSec = totalSec * progress;
    CMTime currentTime = CMTimeMake(playTimeSec, 1);
    
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间点的音频资源");
        }else {
            NSLog(@"取消加载这个时间点的音频资源");
        }
    }];

}
-(void)setRate:(float)rate
{
    [self.player setRate:rate];
}
-(float)rate
{
    return self.player.rate;
}
-(void)setMuted:(BOOL)muted
{
    self.player.muted=muted;
}
-(BOOL)muted
{
    return self.player.muted;
}
-(void)setVolume:(float)volume{
    
    if (volume<0||volume>1) {
        return;
    }
    if (volume>0) {
        [self setMuted:NO];
    }
    self.player.volume=volume;
}
-(float)volume
{
    return self.player.volume;
}
-(NSTimeInterval)totalTime
{
    //总时长
    CMTime totleTime=self.player.currentItem.duration;
    //播放时长
    //影片时间->秒
    NSTimeInterval totleSec=CMTimeGetSeconds(totleTime);
    
    return isnan(totleSec)?0:totleSec;
}
-(NSTimeInterval)currentTime
{
    if (!self.player.currentItem) {
        return 0;
    }
    //当前时长
    CMTime playTime=self.player.currentItem.currentTime;
    NSTimeInterval playSec=CMTimeGetSeconds(playTime);
    return isnan(playSec)?0:playSec;

}
-(float)progress{
    if (!self.totalTime) {
        return 0;
    }
    return self.currentTime/self.totalTime;
}
-(float)loadDataProgress
{
    if (!self.totalTime) {
        return 0;
    }
    CMTimeRange range=[[self.player.currentItem loadedTimeRanges].lastObject CMTimeRangeValue];
    CMTime loadTime = CMTimeAdd(range.start, range.duration);
    
    NSTimeInterval loadTimeSec = CMTimeGetSeconds(loadTime);
    
    loadTimeSec = isnan(loadTimeSec)?0:loadTimeSec;

    return loadTimeSec/self.totalTime;
}
-(void)setState:(KingAudioPlayerState)state
{
    if (_state!=state) {
        _state=state;
        if (self.KingAudioPlayerStateChangeBlock) {
            self.KingAudioPlayerStateChangeBlock(_state);
        }
    }
}

#pragma mark observer;
-(void)removeObserver
{
    [self.player.currentItem removeObserver:self forKeyPath:kStatus];
    [self.player.currentItem removeObserver:self forKeyPath:kPlayback];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kStatus]) {
        AVPlayerItemStatus status=[change[NSKeyValueChangeNewKey]integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            [self resume];
        }else{
            self.state=KingAudioPlayerStateIsFailed;
        }
    }else if ([keyPath isEqualToString:kPlayback]){
        BOOL playBack =[change[NSKeyValueChangeNewKey]boolValue];
        if (!playBack) {
//            正在加载
            self.state=KingAudioPlayerStateIsLoading;
        }else{
            if (!_isUserPause) {
                [self resume];
            }
        }
    }
}
- (void)moviePlayDidEnd:(NSNotification *)notification
{
    self.state = KingAudioPlayerStateIsPlaying;
}
-(void)playInterupt:(NSNotification *)notification
{
    //播放被打断
    self.state = KingAudioPlayerStateIsPause;
}


@end
