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
@property (nonatomic, strong) AVQueuePlayer* player;
@property (nonatomic, strong) UIView* playerView;
@end

@implementation LSImageProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    NSString *secondVideoPath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    NSString *firstVideoPath = [[NSBundle mainBundle] pathForResource:@"dance" ofType:@"mp4"];

    AVPlayerItem *firstVideoItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:firstVideoPath]];
    AVPlayerItem *secondVideoItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:secondVideoPath]];

    AVQueuePlayer* queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:firstVideoItem, secondVideoItem,nil]];
    self.player = queuePlayer;
    
    UIView* playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    playerView.backgroundColor = UIColor.redColor;
    self.playerView = playerView;
    [self.view addSubview:playerView];
    playerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:queuePlayer];
    queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
    layer.frame = playerView.layer.frame;
    [playerView.layer addSublayer:layer];
    
    
    [queuePlayer play];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)appDidBecomeActive{
    
}

- (void)appWillResignActive{
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.player play];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    //self.playerView.frame = self.view.frame;
    //[self.view layoutSubviews];
    self.playerView.frame = CGRectMake(0, 0, size.width, size.height);
    [self.playerView setNeedsLayout];
}

- (void)setSlider{
    //UISlider* slider = [UISlider alloc] initWithFrame:CGRectMake(0, 0, <#CGFloat width#>, <#CGFloat height#>)
}

//- (void)viewDidLoad{
//    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor whiteColor];
//
//
//}
//
//- (void)startCapture{
//    if (@available(ios 11.0, *)) {
//
//        [[RPScreenRecorder sharedRecorder] startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
//            NSLog(@"bufferType = %ld",(long)bufferType);
//        } completionHandler:^(NSError * _Nullable error) {
//            NSLog(@"complete");
//        }];
//
//    }
//}
//
//- (void)endCapture{
//
//}
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self startCapture];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
