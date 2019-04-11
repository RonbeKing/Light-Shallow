//
//  LSVideoPlayerView.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/31.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class LSVideoPlayerView;
@protocol LSVideoPlayerViewDelegate <NSObject>
@optional
- (void)LSVideoPlayerDidPlayedToTime:(CMTime)time;
- (void)LSVideoPlayer:(LSVideoPlayerView *)player readyToPlayVideoOfIndex:(NSInteger)index;
@end

@interface LSVideoPlayerView : UIView

@property (nonatomic, strong) AVAsset* asset;
@property (nonatomic, strong) NSURL* videoURL;

/**
 @brief  the queue of videos to play, if it's null, the functions 'playNext' and 'playPrevious' will be unable;
 */
@property (nonatomic, strong) NSMutableArray<AVAsset *>* videoQueue;

@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) BOOL singleCirclePlay;
@property (nonatomic, assign, readonly) LSPlayerState playerState;
@property (nonatomic, strong, readonly) AVPlayerItem* currentPlayItem;
@property (nonatomic, assign) BOOL isUsingRemoteCommand;
@property (nonatomic,   weak)id <LSVideoPlayerViewDelegate> delegate;

- (instancetype)initWithAsset:(AVAsset *)asset frame:(CGRect)frame;
- (instancetype)initWithVideoURL:(NSURL*)videoURL frame:(CGRect)frame;
- (instancetype)initWithVideoQueue:(NSMutableArray*)videoQueue frame:(CGRect)frame;

- (void)play;
- (void)pause;
- (void)playWithRate:(CGFloat)rate;

- (void)playNext;
- (void)playPrevious;

- (void)seekToTime:(CMTime)time;

- (void)replaceItemWithAsset:(AVAsset *)asset;

- (void)destroy;
@end
