//
//  ViewController.m
//  Example
//
//  Created by J on 2017/6/14.
//  Copyright © 2017年 J. All rights reserved.
//

#import "ViewController.h"
#import "KingAudioPlayer+Format.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *loadPV;

@property (weak, nonatomic) IBOutlet UISlider *playSlider;

@property (weak, nonatomic) IBOutlet UIButton *mutedBtn;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (nonatomic, weak) NSTimer *timer;


@end

@implementation ViewController

-(NSTimer *)timer
{
    if (!_timer) {
        NSTimer *timer=[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(update) userInfo:self repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
        _timer=timer;
    }
    return _timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // slider开始滑动事件
    [self.playSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [self.playSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self.playSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    
    [self timer];
}
-(void)update{
    [self.playTimeLabel setText:[KingAudioPlayer shareInstance].currentTimeFormat];
    [self.totalTimeLabel setText:[KingAudioPlayer shareInstance].totalTimeFormat];
//    [self.playSlider setValue:[KingAudioPlayer shareInstance].progress];
    [self.volumeSlider setValue: [KingAudioPlayer shareInstance].volume];
    [self.loadPV setProgress:[KingAudioPlayer shareInstance].loadDataProgress];
    [self.mutedBtn setSelected:[KingAudioPlayer shareInstance].muted];
}

-(void)progressSliderTouchBegan:(UISlider *)slider
{
//    [[KingAudioPlayer shareInstance]pause];

}
-(void)progressSliderValueChanged:(UISlider *)slider
{
    [[KingAudioPlayer shareInstance] seekWithTimeProgress:slider.value];

}
-(void)progressSliderTouchEnded:(UISlider *)slider
{
//    [[KingAudioPlayer shareInstance]resume];

}
- (IBAction)play:(id)sender {
    
    // http://120.25.226.186:32812/resources/videos/minion_01.mp4
    NSURL *url = [NSURL URLWithString:@"http://cdn.xinchao.mobi/imgs/201711/5a02be4dbd7a5.mp4"];
    [[KingAudioPlayer shareInstance] playUrl:url isCache:YES];
//    [[XMGRemotePlayer shareInstance] playWithURL:url isCache:YES];
    
}
- (IBAction)pause:(id)sender {
    [[KingAudioPlayer shareInstance] pause];
}

- (IBAction)resume:(id)sender {
    [[KingAudioPlayer shareInstance] resume];
}
- (IBAction)kuaijin:(id)sender {
    [[KingAudioPlayer shareInstance] seekWithTimeDiffer:15];
}
- (IBAction)rate:(id)sender {
    [[KingAudioPlayer shareInstance] setRate:2];
}
- (IBAction)muted:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[KingAudioPlayer shareInstance] setMuted:sender.selected];
}
- (IBAction)volume:(UISlider *)sender {
    [[KingAudioPlayer shareInstance] setVolume:sender.value];
}

@end
