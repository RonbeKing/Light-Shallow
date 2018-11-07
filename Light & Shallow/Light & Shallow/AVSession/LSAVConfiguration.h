//
//  LSAVConfiguration.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/29.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LSAVConfiguration : NSObject

@property (nonatomic,   copy) AVCaptureSessionPreset sessionPreset;
@property (nonatomic, assign) NSInteger frameRate;
@property (nonatomic, assign) LSVideoCodec videoCodec;
@property (nonatomic, assign) LSAudioCodec audioCodec;

/*
 LSAudioCodecISAC
 LSVideoCodecH264
 1280x720   @ 30 fps
 */
+ (instancetype)defaultConfiguration;
@end
