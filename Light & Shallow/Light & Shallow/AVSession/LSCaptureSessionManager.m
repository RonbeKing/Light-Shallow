//
//  CaptureSessionManager.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/24.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import "LSCaptureSessionManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreImage/CoreImage.h>
#import "LSVideoPreview.h"

@interface LSCaptureSessionManager ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong) LSAVConfiguration* config;

#pragma mark -- AVCaptureSession

@property (nonatomic, strong) AVCaptureSession* captureSession;
@property (nonatomic, strong) LSVideoPreview* videoPreview;
@property (nonatomic, strong) AVCaptureDevice* videoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput* videoDeviceInput;
@property (nonatomic, strong) AVCaptureDevice* audioDevice;
@property (nonatomic, strong) AVCaptureDeviceInput* audioDeviceInput;
@property (nonatomic,   copy) dispatch_queue_t recordQueue;

#pragma mark -- Filter

@property (nonatomic, strong) CIFilter* filter;
@property (nonatomic, strong) CIContext* context;
@property (nonatomic, strong) CIImage* inputImage;

#pragma mark -- AVAssetWriter

@property (nonatomic, strong) AVAssetWriter* assetWriter;
@property (nonatomic, strong) AVAssetWriterInput* assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput* assetWriterAudioInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor* inputPixelBufferAdptor;
@property (nonatomic, assign) CMTime currentSampleTime;
@property (nonatomic, assign) CMVideoDimensions currentVideoDimensions;

#pragma mark --

@property (nonatomic, assign) BOOL needWrite;
@property (nonatomic,   copy) NSString* videoPath;
@property (nonatomic, assign) BOOL isSwitchingCamera;

@end

@implementation LSCaptureSessionManager

- (instancetype)initWithConfiguration:(LSAVConfiguration *)config{
    if (self = [super init]) {
        self.config = config;
    }
    return self;
}

#pragma mark -- startCapture

- (void)startCaptureWithVideoPreview:(LSVideoPreview *)videoPreview{
    self.videoPreview = videoPreview;
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession beginConfiguration];
    if ([self.captureSession canSetSessionPreset:self.config.sessionPreset]) {
        [self.captureSession setSessionPreset:self.config.sessionPreset];
    }
    
    // video input device
    self.videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    AVCaptureDeviceInput* videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.videoDevice error:nil];
    self.videoDeviceInput = videoDeviceInput;
    
    // lock the device
    if ([self.videoDevice lockForConfiguration:nil]) {
        // set the torch mode auto
        if ([self.videoDevice isTorchModeSupported:AVCaptureTorchModeAuto]) {
            [self.videoDevice setTorchMode:AVCaptureTorchModeAuto];
        }
        
        // set the white balance
        if ([self.videoDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.videoDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [self.videoDevice unlockForConfiguration];
    }
    
    if ([self.captureSession canAddInput:videoDeviceInput]) {
        [self.captureSession addInput:videoDeviceInput];
    }
    
    // video output
    AVCaptureVideoDataOutput* output = [[AVCaptureVideoDataOutput alloc] init];
    output.alwaysDiscardsLateVideoFrames = YES;
    if ([self.captureSession canAddOutput:output]) {
        [self.captureSession addOutput:output];
    }
    [output setSampleBufferDelegate:self queue:self.recordQueue];
    
    // audio input
    self.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    self.audioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:nil];
    if ([self.captureSession canAddInput:self.audioDeviceInput]) {
        [self.captureSession addInput:self.audioDeviceInput];
    }
    
    // audio output
    AVCaptureAudioDataOutput* audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:self.recordQueue];
    if ([self.captureSession canAddOutput:audioOutput]) {
        [self.captureSession addOutput:audioOutput];
    }
    
    [self.captureSession commitConfiguration];
    
    // video preview
    __weak typeof(self) weakSelf = self;
    videoPreview.focusBlock = ^(CGPoint point) {
        [weakSelf changeVideoDevicePropertyInSafety:^(AVCaptureDevice *captureDevice) {
            if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
                [captureDevice setFocusPointOfInterest:point];
            }
        }];
    };
    self.videoPreview.exposureBlock = ^(CGPoint point) {
        [weakSelf changeVideoDevicePropertyInSafety:^(AVCaptureDevice *captureDevice) {
            if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
                [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
                [captureDevice setExposurePointOfInterest:point];
            }
        }];
    };
    self.videoPreview.focalizeAdjustmentBlock = ^(CGFloat scale) {
        [weakSelf changeVideoDevicePropertyInSafety:^(AVCaptureDevice *captureDevice) {
            if([weakSelf.videoDevice isRampingVideoZoom]){
                [weakSelf.videoDevice cancelVideoZoomRamp];
            }
            [weakSelf.videoDevice rampToVideoZoomFactor:scale withRate:100.f];
        }];
    };
    
    [self.captureSession startRunning];
}

#pragma mark -- change capture session property

- (void)changeVideoDevicePropertyInSafety:(void(^)(AVCaptureDevice* captureDevice))propertyChange{
    __weak typeof(self) weakSelf = self;
    AVCaptureDevice* videoCaptureDevice = weakSelf.videoDevice;
    if ([videoCaptureDevice lockForConfiguration:nil]) {
        propertyChange(videoCaptureDevice);
        [videoCaptureDevice unlockForConfiguration];
    }
}

- (void)changeTorchMode{
    [self changeVideoDevicePropertyInSafety:^(AVCaptureDevice *captureDevice) {
        AVCaptureTorchMode oldTorchMode = self.videoDevice.torchMode;
        AVCaptureTorchMode newTorchMode = AVCaptureTorchModeOff;
        if (oldTorchMode == AVCaptureTorchModeOff) {
            newTorchMode = AVCaptureTorchModeOn;
        }
        if ([self.videoDevice isTorchModeSupported:newTorchMode]) {
            [self.videoDevice setTorchMode:newTorchMode];
        }
    }];
}

- (void)switchCamera{
    self.isSwitchingCamera = YES;
    CATransition* transition = [CATransition animation];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.duration = 0.35f;
    transition.type = @"oglFlip";
    
    AVCaptureDevicePosition oldPosition = [self.videoDevice position];
    AVCaptureDevice *newCam = nil;
    if (oldPosition == AVCaptureDevicePositionFront) {
        newCam = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        transition.subtype = kCATransitionFromRight;
    }else{
        newCam = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        transition.subtype = kCATransitionFromLeft;
    }
    self.videoDevice = newCam;
    [self.videoPreview.previewLayer addAnimation:transition forKey:nil];
    
    AVCaptureDeviceInput* deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:newCam error:nil];
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.videoDeviceInput];
    if ([self.captureSession canAddInput:deviceInput]) {
        [self.captureSession addInput:deviceInput];
        self.videoDeviceInput = deviceInput;
    }
    [self.captureSession commitConfiguration];
    self.isSwitchingCamera = NO;
}

#pragma mark -- video record

- (void)startRecord{
    if (self.needWrite) {
        [self finishRecord:^(AVAsset *asset) {
            
        }];
        return;
    }
    if ([self createWriter]) {
        self.needWrite = YES;
        NSLog(@"record began");
    }
}

- (void)stopRecord{
    self.needWrite = NO;
    [self.assetWriter finishWritingWithCompletionHandler:^{
        self.needWrite = NO;
    }];
}

- (void)finishRecord:(void (^)(AVAsset *))block{
    self.needWrite = NO;
    [self.assetWriter finishWritingWithCompletionHandler:^{
        NSLog(@"record ended");
        AVAsset* asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:self.videoPath] options:nil];
        if (block) {
            block(asset);
        }
    }];
}

#pragma mark -- create AVAssetWriter

- (NSString *)createFilePath{
    NSString* filePath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Documents/videoTemp"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* theFilePath = [filePath stringByAppendingString:@"/test.mp4"];
    self.videoPath = theFilePath;
    if ([fileManager fileExistsAtPath:theFilePath]) {
        [fileManager removeItemAtPath:theFilePath error:nil];
    }
    return theFilePath;
}

- (BOOL)createWriter{
    
    NSString* filePath = [self createFilePath];
    NSError* error;
    self.assetWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:filePath] fileType:AVFileTypeMPEG4 error:&error];
    if (error) {
        return NO;
    }
    
    // codec settings
    NSInteger pixelSize = self.config.outputSize.width*self.config.outputSize.height;
    
    CGFloat bitPerPixel = 24.0; //24位真彩色
    NSInteger bitsPerSecond = pixelSize * bitPerPixel;
    
    NSDictionary* compressionProperties =
    @{
      AVVideoAverageBitRateKey:@(bitsPerSecond),
      AVVideoExpectedSourceFrameRateKey:@(self.config.frameRate),
      AVVideoMaxKeyFrameIntervalKey:@(30),
      AVVideoProfileLevelKey:AVVideoProfileLevelH264BaselineAutoLevel
      };
    
    AVVideoCodecType type;
    if (@available(iOS 11.0, *)){
        type = AVVideoCodecTypeH264;
    }else{
        type = AVVideoCodecH264;
    }
    NSDictionary* outputSettings =
    @{
      AVVideoCodecKey:type,
      AVVideoWidthKey:@(self.config.outputSize.width),
      AVVideoHeightKey:@(self.config.outputSize.height),
      AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
      AVVideoCompressionPropertiesKey:compressionProperties
      };
    
    AVAssetWriterInput* assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    self.assetWriterVideoInput = assetWriterVideoInput;
    //assetWriterVideoInput.transform = CGAffineTransformMakeRotation(M_PI/2.0);
    
    NSDictionary* sourcePixelBufferAttributesDictionary =
    @{
      (NSString*)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),
      (NSString*)kCVPixelBufferWidthKey:@(self.currentVideoDimensions.width),
      (NSString*)kCVPixelBufferHeightKey:@(self.currentVideoDimensions.height),
      (NSString*)kCVPixelFormatOpenGLESCompatibility:@(1)
      };
    
    self.inputPixelBufferAdptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:assetWriterVideoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    if ([self.assetWriter canAddInput:assetWriterVideoInput]) {
        [self.assetWriter addInput:assetWriterVideoInput];
    }else {
        NSLog(@"can't add the asset writer for video input");
    }
    
    NSDictionary* audioOutputSettings = @{AVEncoderBitRateKey:@(128000),AVFormatIDKey:@(kAudioFormatMPEG4AAC),AVNumberOfChannelsKey:@(2),AVSampleRateKey:@(44100)};
    
    /* 注：
     <1>AVNumberOfChannelsKey 通道数  1为单通道 2为立体通道
     <2>AVSampleRateKey 采样率 取值为 8000/44100/96000 影响音频采集的质量
     <3>d 比特率(音频码率) 取值为 8 16 24 32
     <4>AVEncoderAudioQualityKey 质量  (需要iphone8以上手机)
     <5>AVEncoderBitRateKey 比特采样率 一般是128000
     */
    
    /*另注：aac的音频采样率不支持96000，当我设置成8000时，assetWriter也是报错*/
    
    AVAssetWriterInput* assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
    assetWriterAudioInput.expectsMediaDataInRealTime = YES;
    self.assetWriterAudioInput = assetWriterAudioInput;
    if ([self.assetWriter canAddInput:assetWriterAudioInput]) {
        [self.assetWriter addInput:assetWriterAudioInput];
    }else{
        NSLog(@"can't add the asset writer for audio input");
    }
    
    if (assetWriterVideoInput) {
        return YES;
    }
    return NO;
}

#pragma mark -- AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if ([output isKindOfClass:[AVCaptureVideoDataOutput class]]) {
        [self videoCaptureOutput:output didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    }else if ([output isKindOfClass:[AVCaptureAudioDataOutput class]]) {
        [self audioCaptureOutput:output didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    }
}

- (void)videoCaptureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if ([self.delegate respondsToSelector:@selector(videoCaptureOutput:didOutputSampleBuffer:fromConnection:)]) {
        [self.delegate videoCaptureOutput:output didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    }
    
    if (self.isSwitchingCamera) {
        return;
    }
    if (self.videoDevice.position == AVCaptureDevicePositionFront) {
        [connection setVideoMirrored:YES];
    }
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationPortrait) {
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }else if (orientation == UIDeviceOrientationLandscapeLeft) {
        [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    }else if (orientation == UIDeviceOrientationLandscapeRight) {
        [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    }else{
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    @autoreleasepool{
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage* image = [CIImage imageWithCVImageBuffer:imageBuffer];
        
        CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
        self.currentVideoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
        self.currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
        
        [self.filter setValue:image forKey:kCIInputImageKey];
        image = self.filter.outputImage;
        
        if (self.needWrite) {
            if (self.assetWriter.status != AVAssetWriterStatusWriting) {
                [self.assetWriter startWriting];
                [self.assetWriter startSessionAtSourceTime:self.currentSampleTime];
            }
            
            if (self.inputPixelBufferAdptor.assetWriterInput.isReadyForMoreMediaData && self.assetWriter.status == AVAssetWriterStatusWriting) {
                
                CVPixelBufferRef newPixelBuffer = NULL;
                CVPixelBufferPoolCreatePixelBuffer(NULL, self.inputPixelBufferAdptor.pixelBufferPool, &newPixelBuffer);
                [self.context render:image toCVPixelBuffer:newPixelBuffer bounds:image.extent colorSpace:nil];
                
                if (newPixelBuffer) {
                    if (self.assetWriter.status == AVAssetWriterStatusWriting) {
                        BOOL success = [self.inputPixelBufferAdptor appendPixelBuffer:newPixelBuffer withPresentationTime:self.currentSampleTime];
                        if (!success) {
                            NSLog(@"append pixel buffer failed");
                        }
                    }
                    CFRelease(newPixelBuffer);
                }else{
                    NSLog(@"newPixelBuffer is nil");
                }
            }
        }
        
        CGImageRef imageRef = [self.context createCGImage:image fromRect:image.extent];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.videoPreview.imageContents = (__bridge id)imageRef;
            CGImageRelease(imageRef);
        });
    }
}

- (void)audioCaptureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if ([self.delegate respondsToSelector:@selector(audioCaptureOutput:didOutputSampleBuffer:fromConnection:)]) {
        [self.delegate audioCaptureOutput:output didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    }
    
    if (self.needWrite) {
        //@synchronized(self){
        if (self.assetWriterAudioInput.readyForMoreMediaData && self.assetWriter.status == AVAssetWriterStatusWriting) {
            [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
        }
        //}
    }
}

#pragma mark -- lazy load

- (dispatch_queue_t)recordQueue{
    if (_recordQueue == nil) {
        _recordQueue = dispatch_queue_create("videoRecord", DISPATCH_QUEUE_SERIAL);
    }
    return _recordQueue;
}

- (CIFilter *)filter{
    if (_filter == nil) {
        _filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    }
    return _filter;
}

- (void)changeFilter:(LSFilterType)filter{
    switch (filter) {
        case LSFilterTypeNoir:
            _filter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
            break;
        case LSFilterTypeTransfer:
            _filter = [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
            break;
        case LSFilterTypeMono:
            _filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
            break;
        case LSFilterTypeInstant:
            _filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
            break;
        default:
            break;
    }
}

-(CIContext *)context{
    // default creates a context based on GPU
    if (_context == nil) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

-(void)dealloc{
    self.recordQueue = nil;
}

@end
