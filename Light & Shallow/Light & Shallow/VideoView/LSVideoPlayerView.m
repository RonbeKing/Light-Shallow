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

@property (nonatomic, assign) LSPlayerState playerState;


@end

@implementation LSVideoPlayerView

- (instancetype)initWithAsset:(AVAsset *)asset frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.asset = asset;
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        [self configPlayer];
    }
    return self;
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.videoURL = videoURL;
        self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
        [self configPlayer];
    }
    return self;
}

- (void)configPlayer{
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    //[self.layer insertSublayer:self.playerLayer atIndex:0];
    [self.layer addSublayer:self.playerLayer];
    self.playerState = LSPlayerStateReadyToPlay;
    
    //[self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //[self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    // Add gestures
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
}

- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem*)playerItem{
    for (AVPlayerItemTrack *track in playerItem.tracks){
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeAudio]){
            track.enabled = enable;
        }
    }
}

- (void)play{
    [self.player play];
    self.player.currentItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    self.player.rate = 1;
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

-(void)setVideoURL:(NSURL *)videoURL{
    _videoURL = videoURL;
    self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self configPlayer];
}

-(void)setAsset:(AVAsset *)asset{
    _asset = asset;
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self configPlayer];
}

@end
