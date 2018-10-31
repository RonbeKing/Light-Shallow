//
//  LSVideoPlayerView.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/31.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LSVideoPlayerView : UIView

@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) BOOL circlePlay;

- (instancetype)initWithAsset:(AVAsset *)asset frame:(CGRect)frame;

- (instancetype)initWithVideoURL:(NSURL*)videoURL frame:(CGRect)frame;

- (void)play;
- (void)pause;

@end
