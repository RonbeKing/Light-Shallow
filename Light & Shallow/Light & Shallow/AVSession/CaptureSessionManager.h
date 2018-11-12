//
//  CaptureSessionManager.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/24.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class LSVideoPreview;

@protocol CaptureSessionManagerDelegate <NSObject>

- (void)videoCaptureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

- (void)audioCaptureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end

@interface CaptureSessionManager : NSObject

@property (nonatomic, weak) id <CaptureSessionManagerDelegate> delegate;

- (void)startCaptureWithVideoPreview:(LSVideoPreview *)videoPreview;

- (void)changeTorchMode:(AVCaptureTorchMode)torchMode;

- (void)switchCamera;

- (void)startRecord;

- (void)stopRecord;
- (void)finishRecord:(void (^)(AVAsset *asset))block;

@end
