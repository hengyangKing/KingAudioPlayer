//
//  KingAudioPlayer.m
//  Example
//
//  Created by J on 2017/6/14.
//  Copyright © 2017年 J. All rights reserved.
//

#import "KingAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#define kStatus @"status"
@interface KingAudioPlayer()<NSCopying,NSMutableCopying>
@property(nonatomic,strong)AVPlayer *player;
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
#pragma mark func


-(void)playUrl:(NSURL *)url
{
//    资源请求
    AVURLAsset *asset=[AVURLAsset assetWithURL:url];
//    资源组织
    AVPlayerItem *item=[AVPlayerItem playerItemWithAsset:asset];
    
    [item addObserver:self forKeyPath:kStatus options:(NSKeyValueObservingOptionNew) context:nil];
    
//    资源的播放
     self.player=[AVPlayer playerWithPlayerItem:item];
}

-(void)pause
{
    [self.player pause];
}

-(void)resume
{
    [self.player play];
}

-(void)stop
{
    [self.player pause];
    self.player=nil;
}

-(void)seekWithTimeDiffer:(NSInteger)differ
{
    //总时长
    CMTime totleTime=self.player.currentItem.duration;
    
    NSTimeInterval totleSec=CMTimeGetSeconds(totleTime);

    //当前时长
    CMTime playTime=self.player.currentItem.currentTime;
    
    NSTimeInterval playSec=CMTimeGetSeconds(playTime);
    
    playSec += differ;
    
    [self seekWithTimeProgress:(1.0*playSec/totleSec)];

}

-(void)seekWithTimeProgress:(float)progress
{
    if (progress<0||progress>1) {
        return;
    }
    //总时长
    CMTime totleTime=self.player.currentItem.duration;
    //播放时长
//    影片时间->秒
    NSTimeInterval totleSec=CMTimeGetSeconds(totleTime);
    NSTimeInterval playTime=totleSec*progress;
    
//    秒->影片时间
   CMTime currentTime = CMTimeMake(playTime, NSEC_PER_SEC);

    [self.player seekToTime:(currentTime) completionHandler:^(BOOL finished) {
        finished?NSLog(@"确定加载"):NSLog(@"取消加载");
    }];
}

-(void)setRate:(float)rate
{
    [self.player setRate:rate];
}

-(void)setMuted:(BOOL)muted{
    self.player.muted=muted;
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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kStatus]) {
        AVPlayerItemStatus status=[change[NSKeyValueChangeNewKey]integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            [self.player play];
        }
    }
}
@end
