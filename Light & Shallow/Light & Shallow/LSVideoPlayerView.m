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

@end

@implementation LSVideoPlayerView

- (instancetype)initWithAsset:(AVAsset *)asset frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        
        self.asset = asset;
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.layer insertSublayer:self.playerLayer atIndex:0];
        
        self.playerLayer.frame = frame;
        
        //[self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        //[self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    }
    return self;
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        
        self.videoURL = videoURL;
        self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
        
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.layer insertSublayer:self.playerLayer atIndex:0];
        self.frame = frame;
        self.playerLayer.frame = frame;
    }
    return self;
}

- (void)play{
    [self.player play];
    NSLog(@"开始播放");
}

- (void)pause{
    [self.player pause];
}

- (void)moviePlayDidEnd:(NSNotification*)notification{
    NSLog(@"播放完了");
    
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [self.player play];
    }];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
}

-(void)dealloc{
    //[self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    //[self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

@end
