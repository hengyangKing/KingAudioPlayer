//
//  KingAudioPlayer+Format.m
//  Example
//
//  Created by J on 2017/6/17.
//  Copyright © 2017年 J. All rights reserved.
//

#import "KingAudioPlayer+Format.h"

@implementation KingAudioPlayer (Format)

-(NSString *)totalTimeFormat
{
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)self.totalTime/60,(int)self.totalTime%60];
}
-(NSString *)currentTimeFormat
{
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)self.currentTime/60,(int)self.currentTime%60];
}




@end
