//
//  LSAVSession.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/25.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class LSVideoPreview,LSAVCommand;

@interface LSAVSession : NSObject

+ (instancetype)sharedInstance;

- (void)startCaptureWithVideoPreview:(LSVideoPreview*)videoPreview;
//- (void)stopCapture;
- (void)startRecord;
- (void)stopRecord;
- (void)finishRecord:(void(^)(AVAsset* asset))block;

- (void)changeTorchMode:(AVCaptureTorchMode)torchMode;
- (void)switchCamera;

- (void)composeAsset1:(AVAsset *)asset1 mediaType:(AVMediaType)mediaType1 asset2:(AVAsset *)asset2 mediaType:(AVMediaType)mediaType2;
- (void)addMusicToAsset:(AVAsset *)asset completion:(void(^)(LSAVCommand* avCommand))block;
- (void)addWatermark:(LSWatermarkType)watermarkType inAsset:(AVAsset *)asset completion:(void(^)(LSAVCommand *avCommand))block;
- (void)exportAsset:(AVAsset *)asset;

@end
