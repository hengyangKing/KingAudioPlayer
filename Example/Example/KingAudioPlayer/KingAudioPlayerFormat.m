//
//  KingAudioPlayerFormat.m
//  Example
//
//  Created by J on 2017/6/17.
//  Copyright © 2017年 J. All rights reserved.
//

#import "KingAudioPlayerFormat.h"
@interface KingAudioPlayerFormat()
@property(nonatomic,assign)NSTimeInterval total;
@property(nonatomic,assign)NSTimeInterval current;
@end
@implementation KingAudioPlayerFormat
-(KingAudioPlayerFormat *(^)(NSTimeInterval ))TotalTime
{
    return ^(NSTimeInterval totle){
        self.total=totle;
        return self;
    };
}
-(KingAudioPlayerFormat *(^)(NSTimeInterval))CurrentTime
{
    return ^(NSTimeInterval current){
        self.current=current;
        return self;
    };
}
-(void)setTotal:(NSTimeInterval)total
{
    _total=total;
    if (self.playerTotalTimeFormat) {
        self.playerTotalTimeFormat(self.totalTimeFormat);
    }
}
-(void)setCurrent:(NSTimeInterval)current
{
    _current=current;
    if (self.playerCurrentTimeFormat) {
        self.playerCurrentTimeFormat(self.currentTimeFormat);
    }
}


-(NSString *)totalTimeFormat
{
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)self.total/60,(int)self.total%60];
}
-(NSString *)currentTimeFormat
{
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)self.current/60,(int)self.current%60];
}





@end
