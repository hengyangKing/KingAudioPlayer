//
//  ViewController.m
//  Example
//
//  Created by J on 2017/6/14.
//  Copyright © 2017年 J. All rights reserved.
//

#import "ViewController.h"
#import "KingAudioPlayer.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *loadPV;

@property (nonatomic, weak) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;

@property (weak, nonatomic) IBOutlet UIButton *mutedBtn;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)play:(id)sender {
    
    // http://120.25.226.186:32812/resources/videos/minion_01.mp4
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
    [[KingAudioPlayer shareInstance] playUrl:url];
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
- (IBAction)progress:(UISlider *)sender {
    [[KingAudioPlayer shareInstance] seekWithTimeProgress:sender.value];
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
