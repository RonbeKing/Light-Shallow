//
//  realtimeFilterViewController.m
//  coreImg
//
//  Created by 王珑宾 on 2018/10/9.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import "RealtimeFilterViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "videoPreview.h"
#import "AssetManager.h"
#import "LSAVCommand.h"
#import "LSAVAddWatermarkCommand.h"
#import "LSAVExportCommand.h"

#define KScreenWidth  [UIScreen mainScreen].bounds.size.width
#define KScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface RealtimeFilterViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession* captureSession;
@property (nonatomic, strong) videoPreview* videoPreview;
@property (nonatomic, strong) AVCaptureDevice* videoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput* videoDeviceInput;
@property (nonatomic, strong) AVCaptureDevice* audioDevice;
@property (nonatomic, strong) AVCaptureDeviceInput* audioDeviceInput;

// filter
@property (nonatomic, strong) CIFilter* filter;
@property (nonatomic, strong) CIContext* context;
@property (nonatomic, strong) NSMutableArray* filterNames;
@property (nonatomic, strong) CIImage* inputImage;

// record video
@property (nonatomic, strong) AVAssetWriter* assetWriter;
@property (nonatomic, strong) AVAssetWriterInput* assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput* assetWriterAudioInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor* inputPixelBufferAdptor;
@property (nonatomic, assign) CMTime currentSampleTime;
@property (nonatomic, assign) CMVideoDimensions currentVideoDimensions;

@property (nonatomic, assign) BOOL needWrite;
@property (nonatomic,   copy) NSString* videoPath;

@property (nonatomic, assign) BOOL isSwitchingCamera;
@end

@implementation RealtimeFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.filterNames = [NSMutableArray arrayWithObjects:@"CIColorInvert", @"CIPhotoEffectMono", @"CIPhotoEffectInstant", @"CIPhotoEffectTransfer", nil];
    [self initCaptureSession];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 80, 50);
    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"record" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(recordVideo) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(230, 100, 80, 50);
    btn2.backgroundColor = [UIColor blueColor];
    [btn2 setTitle:@"flip" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    [btn2 addTarget:self action:@selector(exitVC) forControlEvents:UIControlEventTouchUpInside];
    
    __block int count = 0;
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        count++;
        if (count == 4) {
            count = 0;
        }
        self.filter = [CIFilter filterWithName:self.filterNames[count]];
    }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)exitVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCaptureSession{
    // init capture session
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession beginConfiguration];
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [self.captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
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
    [output setSampleBufferDelegate:self queue:dispatch_queue_create("videoOutput", DISPATCH_QUEUE_PRIORITY_DEFAULT)];
    
    // audio input
    self.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    self.audioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:nil];
    if ([self.captureSession canAddInput:self.audioDeviceInput]) {
        [self.captureSession addInput:self.audioDeviceInput];
    }
    
    // audio output
    AVCaptureAudioDataOutput* audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:dispatch_queue_create("audioOutput", DISPATCH_QUEUE_PRIORITY_DEFAULT)];
    if ([self.captureSession canAddOutput:audioOutput]) {
        [self.captureSession addOutput:audioOutput];
    }
    
    [self.captureSession commitConfiguration];
    
    // video preview
    __weak typeof(self) weakSelf = self;
    self.videoPreview = [[videoPreview alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    
    self.videoPreview.focusBlock = ^(CGPoint point) {
        if ([weakSelf.videoDevice lockForConfiguration:nil]) {
            if ([weakSelf.videoDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                [weakSelf.videoDevice setFocusMode:AVCaptureFocusModeAutoFocus];
                [weakSelf.videoDevice setFocusPointOfInterest:point];
            }
        }
        [weakSelf.videoDevice unlockForConfiguration];
    };
    self.videoPreview.exposureBlock = ^(CGPoint point) {
        if ([weakSelf.videoDevice lockForConfiguration:nil]) {
            if ([weakSelf.videoDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
                [weakSelf.videoDevice setExposureMode:AVCaptureExposureModeAutoExpose];
                [weakSelf.videoDevice setExposurePointOfInterest:point];
            }
        }
        [weakSelf.videoDevice unlockForConfiguration];
    };
    
    [self.view addSubview:self.videoPreview];
    [self.captureSession startRunning];
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
- (void)recordVideo{
    if (self.needWrite) {
        [self stopRecord];
        return;
    }
    if ([self createWriter]) {
        
        [self.assetWriter startWriting];
        [self.assetWriter startSessionAtSourceTime:self.currentSampleTime];
        self.needWrite = YES;
        
        NSLog(@"record began");
    }
}

- (void)stopRecord{
    self.needWrite = NO;
    [self.assetWriter finishWritingWithCompletionHandler:^{
        NSLog(@"record ended");
        
        AVAsset* asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:self.videoPath] options:nil];

        LSAVAddWatermarkCommand* watermarkCommand = [[LSAVAddWatermarkCommand alloc] initWithComposition:nil videoComposition:nil audioMix:nil];
        
        [watermarkCommand performWithAsset:asset completion:^(LSAVCommand *avCommand) {
            LSAVExportCommand* exportCommand = [[LSAVExportCommand alloc] initWithComposition:avCommand.mutableComposition videoComposition:avCommand.mutableVideoComposition audioMix:avCommand.mutableAudioMix];
            [exportCommand performWithAsset:nil completion:^(LSAVCommand *avCommand) {
                NSLog(@"export successfully");
            }];
        }];
    }];
}

- (NSString *)createFilePath{
    NSString* filePath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Documents/videoTemp"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //NSDate* now = [NSDate date];
    //NSString* nowStr = [NSString ]
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
    NSInteger pixelSize = 1280*720;
    
    CGFloat bitPerPixel = 12.0;
    NSInteger bitsPerSecond = pixelSize * bitPerPixel;
    
    NSDictionary* compressionProperties =
   @{
    AVVideoAverageBitRateKey:@(bitsPerSecond),
    AVVideoExpectedSourceFrameRateKey:@(30),
    AVVideoMaxKeyFrameIntervalKey:@(30),
    AVVideoProfileLevelKey:AVVideoProfileLevelH264BaselineAutoLevel
    };

    NSDictionary* outputSettings =
  @{
    AVVideoCodecKey:AVVideoCodecTypeH264,
    AVVideoWidthKey:@720,
    AVVideoHeightKey:@1280,
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
    
    NSDictionary* audioOutputSettings = @{AVEncoderBitRateKey:@(44100),AVFormatIDKey:@(kAudioFormatMPEG4AAC),AVNumberOfChannelsKey:@(1),AVSampleRateKey:@(44100)};
    
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

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if ([output isKindOfClass:[AVCaptureVideoDataOutput class]]) {
        [self videoCaptureOutput:output didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    }else if ([output isKindOfClass:[AVCaptureAudioDataOutput class]]) {
        [self audioCaptureOutput:output didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    }
}

- (void)videoCaptureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (self.isSwitchingCamera) {
        return;
    }
    if (self.videoDevice.position == AVCaptureDevicePositionFront) {
        [connection setVideoMirrored:YES];
    }
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    //CGAffineTransform transform = CGAffineTransformIdentity;
    if (orientation == UIDeviceOrientationPortrait) {
        //transform = CATransform3DGetAffineTransform(CATransform3DMakeRotation(M_PI, 1, -1, 0));
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }else if (orientation == UIDeviceOrientationLandscapeLeft) {
        //transform = CATransform3DGetAffineTransform(CATransform3DMakeRotation(M_PI, 0, 0, 1));
        [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    }else if (orientation == UIDeviceOrientationLandscapeRight) {
        //transform = CATransform3DGetAffineTransform(CATransform3DMakeRotation(M_PI, 0, 1, 0));
        [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    }
    //image = [image imageByApplyingTransform:transform];
    
    @autoreleasepool{

        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage* image = [CIImage imageWithCVImageBuffer:imageBuffer];
        
        CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
        self.currentVideoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
        self.currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
        
        [self.filter setValue:image forKey:kCIInputImageKey];
        image = self.filter.outputImage;
        
        if (self.needWrite) {
            if (self.inputPixelBufferAdptor.assetWriterInput.isReadyForMoreMediaData && self.assetWriter.status == AVAssetWriterStatusWriting) {
                
                CVPixelBufferRef newPixelBuffer = NULL;
                CVPixelBufferPoolCreatePixelBuffer(NULL, self.inputPixelBufferAdptor.pixelBufferPool, &newPixelBuffer);
                [self.context render:image toCVPixelBuffer:newPixelBuffer bounds:image.extent colorSpace:nil];
                
                if (newPixelBuffer) {
                    BOOL success = [self.inputPixelBufferAdptor appendPixelBuffer:newPixelBuffer withPresentationTime:self.currentSampleTime];
                    if (!success) {
                        NSLog(@"append pixel buffer failed");
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
    if (self.needWrite) {
        //@synchronized(self){
            if (self.assetWriterAudioInput.readyForMoreMediaData && self.assetWriter.status == AVAssetWriterStatusWriting) {
                [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
            }
        //}
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    self.videoPreview.frame = CGRectMake(0, 0, size.width, size.height);
    [self.videoPreview setNeedsLayout];
}

- (CIFilter *)filter{
    if (_filter == nil) {
        _filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
    }
    return _filter;
}

-(CIContext *)context{
    // default creates a context based on GPU
    if (_context == nil) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

@end
