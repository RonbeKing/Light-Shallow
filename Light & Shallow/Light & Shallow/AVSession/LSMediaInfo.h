//
//  LSMediaInfo.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/16.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

// 获取视频分辨率，帧率，帧间隔，编码输出码率，视频方向，时长，大小，
// 音频采样率，码率，

@interface LSMediaInfo : NSObject
// videoInfo

@property (nonatomic, assign) float videoWidth;
@property (nonatomic, assign) float videoHeight;
@property (nonatomic, assign) float videoFrameRate;
@property (nonatomic, assign) float videoOutputBitrate;
@property (nonatomic, assign) LSVideoOrientation videoOrientation;
@property (nonatomic, assign) CMTime videoDuration;
@property (nonatomic, assign) long long videoByte;

// audioInfo
@end
