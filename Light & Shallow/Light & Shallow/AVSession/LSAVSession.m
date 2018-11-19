//
//  LSAVSession.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/25.
//  Copyright © 2018年 Ronb X. All rights reserved.
//
//  **********************************************
//  * IMPORTANT:  SDK主功能的接口类,提供各种功能的接口 *
//  **********************************************

#import "LSAVSession.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreImage/CoreImage.h>
#import "LSVideoPreview.h"

#import "LSAVCommand.h"
#import "LSAVAddMusicCommand.h"
#import "LSAVAddWatermarkCommand.h"
#import "LSAVExportCommand.h"

#import "CaptureSessionManager.h"
#import "LSVideoEditor.h"

@interface LSAVSession ()<CaptureSessionManagerDelegate>

#pragma mark -- AVCaptureSession

@property (nonatomic, strong) CaptureSessionManager* captureSessionManager;
@property (nonatomic, strong) LSVideoEditor* videoEditor;

@end

@implementation LSAVSession

+ (instancetype)sharedInstance{
    static LSAVSession* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LSAVSession alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        self.captureSessionManager = [[CaptureSessionManager alloc] init];
        self.captureSessionManager.delegate = self;
        self.videoEditor = [[LSVideoEditor alloc] init];
     }
    return self;
}

#pragma mark -- startCapture

- (void)startCaptureWithVideoPreview:(LSVideoPreview *)videoPreview{
    [self.captureSessionManager startCaptureWithVideoPreview:videoPreview];
}

#pragma mark -- change capture session property

- (void)changeTorchMode:(AVCaptureTorchMode)torchMode{
    [self.captureSessionManager changeTorchMode:torchMode];
}

- (void)switchCamera{
    [self.captureSessionManager switchCamera];
}

#pragma mark -- video record

- (void)startRecord{
    [self.captureSessionManager startRecord];
}

- (void)stopRecord{
    [self.captureSessionManager stopRecord];
}

- (void)finishRecord:(void (^)(AVAsset *))block{
    [self.captureSessionManager finishRecord:block];
}

#pragma mark -- Video editor

- (void)addMusicToAsset:(AVAsset *)asset completion:(void (^)(LSAVCommand *))block{
    [self.videoEditor addMusicToAsset:asset completion:block];
}

- (void)addWatermark:(LSWatermarkType)watermarkType inAsset:(AVAsset *)asset completion:(void (^)(LSAVCommand *))block{
    [self.videoEditor addWatermark:watermarkType inAsset:asset completion:block];
}

- (void)exportAsset:(AVAsset*)asset{
    [self.videoEditor exportAsset:asset];
}

- (void)composeAsset1:(AVAsset *)asset1 mediaType:(AVMediaType)mediaType1 asset2:(AVAsset *)asset2 mediaType:(AVMediaType)mediaType2{
    
}

#pragma mark -- CaptureSessionManagerDelegate

- (void)videoCaptureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}

- (void)audioCaptureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

}

@end
