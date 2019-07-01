//
//  CaptureSessionManager.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/24.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LSAVConfiguration.h"

@class LSVideoPreview;

@protocol LSCaptureSessionManagerDelegate <NSObject>
@optional
- (void)videoCaptureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

- (void)audioCaptureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
@end

@interface LSCaptureSessionManager : NSObject

@property (nonatomic, strong, readonly) AVCaptureSession* captureSession;
@property (nonatomic, weak) id <LSCaptureSessionManagerDelegate> delegate;
@property (nonatomic, strong) LSAVConfiguration* config;
/**
 @brief 初始化capture，用于视频录制
 @param config 录制时的输入输出参数
 */
- (instancetype)initWithConfiguration:(LSAVConfiguration *)config;

/**
 @brief
    start capture
 
 @param videoPreview
    It's a view used to preview
 */
- (void)startCaptureWithVideoPreview:(LSVideoPreview *)videoPreview;

- (void)changePreset:(AVCaptureSessionPreset)preset;
/**
 @brief flashMode and cam orientation
 */
- (void)changeTorchMode;
- (void)switchCamera;

/**
 @brief  start / stop record
 */
- (void)startRecord;
- (void)stopRecord;
- (void)finishRecord:(void (^)(AVAsset *asset))block;

- (void)changeFilter:(LSFilterType)filter;
@end
