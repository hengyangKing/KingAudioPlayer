//
//  KingAudioPlayerFormat.h
//  Example
//
//  Created by J on 2017/6/17.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KingAudioPlayerFormat : NSObject
@property(nonatomic,copy)void (^playerTotalTimeFormat)(NSString *totalTimeFormat);
@property(nonatomic,copy)void (^playerCurrentTimeFormat)(NSString *currentTimeFormat);

@property(nonatomic,copy,readonly)KingAudioPlayerFormat *(^TotalTime)(NSTimeInterval totalTime);
@property(nonatomic,copy,readonly)KingAudioPlayerFormat *(^CurrentTime)(NSTimeInterval currentTime);


@end
