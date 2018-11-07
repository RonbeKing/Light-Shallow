//
//  LSAVSession.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/25.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

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

@interface LSAVSession ()<CaptureSessionManagerDelegate>

#pragma mark -- AVCaptureSession

@property (nonatomic, strong) CaptureSessionManager* captureSessionManager;

#pragma mark -- video composition

@property (nonatomic, strong) AVMutableComposition* mutableComposition;
@property (nonatomic, strong) AVMutableVideoComposition* mutableVideoComposition;
@property (nonatomic, strong) AVMutableAudioMix* mutableAudioMix;

@property (nonatomic, strong) LSAVCommand* avCommand;

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
    LSAVAddMusicCommand* musicCommand = [[LSAVAddMusicCommand alloc] initWithComposition:self.avCommand.mutableComposition videoComposition:self.avCommand.mutableVideoComposition audioMix:self.avCommand.mutableAudioMix];
    [musicCommand performWithAsset:asset completion:^(LSAVCommand *avCommand) {
        self.avCommand = avCommand;
        if (block) {
            block(avCommand);
        }
    }];
}

- (void)addWatermark:(LSWatermarkType)watermarkType inAsset:(AVAsset *)asset completion:(void (^)(LSAVCommand *))block{
    LSAVAddWatermarkCommand* watermarkCommand = [[LSAVAddWatermarkCommand alloc] initWithComposition:self.avCommand.mutableComposition videoComposition:self.avCommand.mutableVideoComposition audioMix:self.avCommand.mutableAudioMix];
    [watermarkCommand performWithAsset:asset completion:^(LSAVCommand *avCommand) {
        self.avCommand = avCommand;
        if (block) {
            block(avCommand);
        }
    }];
}

- (void)exportAsset:(AVAsset*)asset{
    LSAVExportCommand* exportCommand = [[LSAVExportCommand alloc] initWithComposition:self.avCommand.mutableComposition videoComposition:self.avCommand.mutableVideoComposition audioMix:self.avCommand.mutableAudioMix];
    
    [exportCommand performWithAsset:asset completion:^(LSAVCommand *avCommand) {
        if (avCommand.executeStatus) {
            NSLog(@"export successfully");
        }else{
            NSLog(@"export fail");
        }
    }];
}

- (void)composeAsset1:(AVAsset *)asset1 mediaType:(AVMediaType)mediaType1 asset2:(AVAsset *)asset2 mediaType:(AVMediaType)mediaType2{
    
}

#pragma mark -- CaptureSessionManagerDelegate

- (void)videoCaptureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}

- (void)audioCaptureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

}

@end
