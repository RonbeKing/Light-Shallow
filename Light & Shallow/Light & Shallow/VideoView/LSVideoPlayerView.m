//
//  LSVideoPlayerView.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/31.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSVideoPlayerView.h"

@interface LSVideoPlayerView ()

@property (nonatomic, strong) AVPlayerLayer* playerLayer;
@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem* playerItem;
@property (nonatomic, assign) CMTime duration;
@property (nonatomic, assign) CMTime currentTime;

@property (nonatomic, strong) AVAsset* asset;
@property (nonatomic, strong) NSURL* videoURL;

@property (nonatomic, assign) LSPlayerState playerState;

@end

@implementation LSVideoPlayerView

- (instancetype)initWithAsset:(AVAsset *)asset frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.asset = asset;
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        [self configPlayer];
        self.playerLayer.frame = frame;
    }
    return self;
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.videoURL = videoURL;
        self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
        [self configPlayer];
        self.playerLayer.frame = frame;
    }
    return self;
}

- (void)configPlayer{
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    self.playerState = LSPlayerStateReadyToPlay;
    
    //[self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //[self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    // Add gestures
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
}

- (void)play{
    [self.player play];
    self.playerState = LSPlayerStatePlaying;
}

- (void)pause{
    [self.player pause];
    self.playerState = LSPlayerStateStop;
}

- (void)replaceItemWithAsset:(AVAsset *)asset{
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    //[self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //[self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self play];
}

- (void)moviePlayDidEnd:(NSNotification*)notification{
    NSLog(@"播放完了");
    
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [self.player play];
    }];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
}

- (void)doubleTap:(UITapGestureRecognizer*)tap{
    if (self.playerState != LSPlayerStatePlaying) {
        [self play];
    }else{
        [self pause];
    }
}

-(void)dealloc{
    //[self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    //[self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

@end
