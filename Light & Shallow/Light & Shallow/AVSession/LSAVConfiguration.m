//
//  LSAVConfiguration.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/29.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSAVConfiguration.h"

@implementation LSAVConfiguration

+(instancetype)defaultConfiguration{
    LSAVConfiguration* configuration = [[LSAVConfiguration alloc] init];
    configuration.sessionPreset = AVCaptureSessionPreset1280x720;
    configuration.frameRate = 30;
    configuration.videoCodec = LSVideoCodecH264;
    configuration.audioCodec = LSAudioCodecISAC;
    return configuration;
}

@end
