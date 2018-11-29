//
//  LSImageProcessViewController.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/2.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSImageProcessViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface LSImageProcessViewController ()

@end

@implementation LSImageProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *secondVideoPath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    NSString *firstVideoPath = [[NSBundle mainBundle] pathForResource:@"nnn" ofType:@"mp4"];
    
    
    AVPlayerItem *firstVideoItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:firstVideoPath]];
    AVPlayerItem *secondVideoItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:secondVideoPath]];
    
    AVQueuePlayer* queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:firstVideoItem, secondVideoItem,nil]];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:queuePlayer];
    queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
    layer.frame = self.view.layer.frame;
    
    [self.view.layer addSublayer:layer];
    
    
    
    [queuePlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
