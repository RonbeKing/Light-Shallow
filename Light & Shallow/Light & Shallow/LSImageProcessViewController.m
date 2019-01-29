//
//  LSImageProcessViewController.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/2.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSImageProcessViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@import ReplayKit;

@interface LSImageProcessViewController ()

@end

@implementation LSImageProcessViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor whiteColor];
//
//    NSString *secondVideoPath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
//    NSString *firstVideoPath = [[NSBundle mainBundle] pathForResource:@"nnn" ofType:@"mp4"];
//
//    AVPlayerItem *firstVideoItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:firstVideoPath]];
//    AVPlayerItem *secondVideoItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:secondVideoPath]];
//
//    AVQueuePlayer* queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:firstVideoItem, secondVideoItem,nil]];
//
//    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:queuePlayer];
//    queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
//    layer.frame = self.view.layer.frame;
//    [self.view.layer addSublayer:layer];
//    [queuePlayer play];
//
//}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}

- (void)startCapture{
    if (@available(ios 11.0, *)) {
        
        [[RPScreenRecorder sharedRecorder] startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
            NSLog(@"bufferType = %ld",(long)bufferType);
        } completionHandler:^(NSError * _Nullable error) {
            NSLog(@"complete");
        }];
        
    }
}

- (void)endCapture{
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self startCapture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
