//
//  LSVideoPlayerView.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/31.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSVideoPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface LSVideoPlayerView ()

@property (nonatomic, strong) AVPlayerLayer* playerLayer;
@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem* currentPlayItem;
@property (nonatomic, assign) CMTime duration;
@property (nonatomic, assign) CMTime currentTime;

@property (nonatomic, assign) LSPlayerState playerState;
@end

@implementation LSVideoPlayerView

#pragma mark -- 播放器初始化配置

- (instancetype)initWithAsset:(AVAsset *)asset frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.asset = asset;
        self.currentPlayItem = [AVPlayerItem playerItemWithAsset:asset];
        [self configPlayer];
    }
    return self;
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.videoURL = videoURL;
        self.currentPlayItem = [AVPlayerItem playerItemWithURL:videoURL];
        [self configPlayer];
    }
    return self;
}

- (void)configPlayer{
    self.player = [AVPlayer playerWithPlayerItem:self.currentPlayItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:self.playerLayer];
    self.playerState = LSPlayerStateReadyToPlay;
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 100) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if ([weakSelf.delegate respondsToSelector:@selector(LSVideoPlayerDidPlayedToTime:)]) {
            [weakSelf.delegate LSVideoPlayerDidPlayedToTime:time];
        }
        if (weakSelf.isUsingRemoteCommand) {
            [weakSelf updateRemoteInfoCenter];
        }
    }];

    // Add gestures
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [self addNotifications];
}

- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark -- MPRemoteCommandCenter

- (void)addMediaPlayerRemoteCommands{
    MPRemoteCommandCenter* commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    MPRemoteCommand* pauseCommand = [commandCenter pauseCommand];
    [pauseCommand setEnabled:YES];
    [pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    MPRemoteCommand* playCommand = [commandCenter playCommand];
    [playCommand setEnabled:YES];
    [playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    if (@available(ios 9.1, *)) {
        MPRemoteCommand* changeProgressCommand = [commandCenter changePlaybackPositionCommand];
        [changeProgressCommand setEnabled:YES];
        [changeProgressCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
            CMTime time = CMTimeMakeWithSeconds(playbackPositionEvent.positionTime, self.player.currentItem.duration.timescale);
            [self seekToTime:time];
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
}

- (void)removeMediaPlayerRemoteCommands{
    MPRemoteCommandCenter* commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [[commandCenter playCommand] removeTarget:self];
    if (@available(iOS 9.1, *)) {
        [[commandCenter pauseCommand] removeTarget:self];
    }
    [[commandCenter changePlaybackPositionCommand] removeTarget:self];
}

- (void)updateRemoteInfoCenter{
    if (!self.player) {
        return;
    }
    MPNowPlayingInfoCenter* infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    // 歌曲名
    [info setObject:@"歌曲名称" forKey:MPMediaItemPropertyTitle];
    [info setObject:@"专辑名称" forKey:MPMediaItemPropertyAlbumTitle];
    // 封面图片
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(250, 250) requestHandler:^UIImage * _Nonnull(CGSize size) {
        UIImage* image = [UIImage imageNamed:@"cover3.jpg"];
        return image;
    }];
    [info setObject:artwork forKey:MPMediaItemPropertyArtwork];
    // 设置进度
    NSNumber* duration = @(CMTimeGetSeconds(self.player.currentItem.duration));
    NSNumber* currentTime = @(CMTimeGetSeconds(self.player.currentItem.currentTime));
    if (!duration || !currentTime) {
        return;
    }
    [info setObject:duration forKey:MPMediaItemPropertyPlaybackDuration];
    [info setObject:currentTime forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [info setObject:@(self.player.rate) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    infoCenter.nowPlayingInfo = info;
}

- (void)updateRemoteProgress{
    
}

#pragma mark -- 视频控制事件

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
    self.playerState = LSPlayerStatePlaying;
}

- (void)pause{
    [self.player pause];
    self.playerState = LSPlayerStateStop;
}

- (void)playWithRate:(CGFloat)rate{
    [self.player play];
    self.player.currentItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    self.player.rate = 0.25;
    self.playerState = LSPlayerStatePlaying;
}

- (void)seekToTime:(CMTime)time{
    [self.player seekToTime:time];
}

- (void)destroy{
    [self pause];
    self.player = nil;
    if (self.isUsingRemoteCommand) {
        [self removeMediaPlayerRemoteCommands];
    }
}

#pragma mark -- 通知响应事件

- (void)moviePlayDidEnd:(NSNotification*)notification{
    if (self.circlePlay) {
        [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [self play];
        }];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
}

- (void)didEnterBackground{
    self.playerLayer.player = nil;
}

- (void)willEnterForeground{
    self.playerLayer.player = self.player;
}

#pragma mark -- 设置播放源

-(void)setVideoURL:(NSURL *)videoURL{
    _videoURL = videoURL;
    self.currentPlayItem = [AVPlayerItem playerItemWithURL:videoURL];
    [self.player replaceCurrentItemWithPlayerItem:self.currentPlayItem];
    [self configPlayer];
}

-(void)setAsset:(AVAsset *)asset{
    _asset = asset;
    self.currentPlayItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.player replaceCurrentItemWithPlayerItem:self.currentPlayItem];
    [self configPlayer];
}

- (void)replaceItemWithAsset:(AVAsset *)asset{
    self.currentPlayItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.player replaceCurrentItemWithPlayerItem:self.currentPlayItem];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayItem];
    [self play];
}

- (void)setIsUsingRemoteCommand:(BOOL)isUsingRemoteCommand{
    _isUsingRemoteCommand = isUsingRemoteCommand;
    if (isUsingRemoteCommand) {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self addMediaPlayerRemoteCommands];
    }
}
#pragma mark -- 手势响应事件

- (void)doubleTap:(UITapGestureRecognizer*)tap{
    if (self.playerState != LSPlayerStatePlaying) {
        [self play];
    }else{
        [self pause];
    }
}

-(void)dealloc{
    NSLog(@"player view dealloc");
    if (self.isUsingRemoteCommand) {
        [self removeMediaPlayerRemoteCommands];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayItem];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

@end
