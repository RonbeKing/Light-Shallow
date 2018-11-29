//
//  LSVideoPlayerView.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/31.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol LSVideoPlayerViewDelegate <NSObject>
@optional
- (void)LSVideoPlayerDidPlayedToTime:(CMTime)time;
@end

@interface LSVideoPlayerView : UIView

@property (nonatomic, strong) AVAsset* asset;
@property (nonatomic, strong) NSURL* videoURL;

@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) BOOL circlePlay;
@property (nonatomic, assign, readonly) LSPlayerState playerState;
@property (nonatomic, strong, readonly) AVPlayerItem* currentPlayItem;
@property (nonatomic,   weak)id <LSVideoPlayerViewDelegate> delegate;
- (instancetype)initWithAsset:(AVAsset *)asset frame:(CGRect)frame;

- (instancetype)initWithVideoURL:(NSURL*)videoURL frame:(CGRect)frame;

- (void)play;
- (void)pause;
- (void)playWithRate:(CGFloat)rate;

- (void)seekToTime:(CMTime)time;

- (void)replaceItemWithAsset:(AVAsset *)asset;
@end
