//
//  KingAudioPlayer.h
//  Example
//
//  Created by J on 2017/6/14.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KingAudioPlayer : NSObject

+(instancetype)shareInstance;

-(void)playUrl:(NSURL *)url;

-(void)pause;

-(void)resume;

-(void)stop;

-(void)seekWithTimeDiffer:(NSInteger)differ;

-(void)seekWithTimeProgress:(float)progress;

-(void)setRate:(float)rate;

-(void)setMuted:(BOOL)muted;

-(void)setVolume:(float)volume;


@end
