//
//  realtimeFilterViewController.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/9.
//  Copyright © 2018年 Ronb X. All rights reserved.
//
//  *****************************************
//  * view controller added realtime-filter *
//  *****************************************

#import "RealtimeFilterViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LSVideoEditorViewController.h"
#import "LSVideoPreview.h"
//#import "LSOperationView.h"
#import "LSRecordOperationView.h"
#import "LSAssetManager.h"
#import "LSCaptureSessionManager.h"
#import "LSAVConfiguration.h"

@interface RealtimeFilterViewController ()
@property (nonatomic, strong) LSCaptureSessionManager* captureSession;
@property (nonatomic, strong) LSAVConfiguration* AVConfig;
@property (nonatomic, strong) LSVideoPreview* videoPreview;
@end

@implementation RealtimeFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initCaptureSession];
    
    UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(15, 10, 45, 20);
    [backBtn setTitle:@"back" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCaptureSession{
    self.AVConfig = [LSAVConfiguration defaultConfiguration];
    self.captureSession = [[LSCaptureSessionManager alloc] initWithConfiguration:self.AVConfig];
    
    // video preview
    self.videoPreview = [[LSVideoPreview alloc] init];
    self.videoPreview.canvasRatio = LSCanvasRatio1X1;
    [self.view addSubview:self.videoPreview];
    [self.captureSession startCaptureWithVideoPreview:self.videoPreview];
    
    LSRecordOperationView* operationView = [[[NSBundle mainBundle] loadNibNamed:@"LSRecordOperationView" owner:nil options:nil] lastObject];
    operationView.frame = CGRectMake(0, KScreenHeight - 260, KScreenWidth, 260);
    [self.view addSubview:operationView];
    
    operationView.beginRecordBlock = ^{
        [self.captureSession startRecord];
    };

    operationView.endRecordBlock = ^{
        [self.captureSession finishRecord:^(AVAsset *asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LSVideoEditorViewController* videoEditor = [[LSVideoEditorViewController alloc] init];
                videoEditor.asset = asset;
                [self presentViewController:videoEditor animated:YES completion:nil];
            });
        }];
    };

    operationView.flipCameraBlock = ^{
        [self.captureSession switchCamera];
    };
    
    operationView.changeTorchModeBlock = ^{
        [self.captureSession changeTorchMode];
    };
    
    operationView.changeFilterBlock = ^(int tag) {
        [self.captureSession changeFilter:tag];
    };

    operationView.ajustCanvasBlock = ^(LSCanvasRatio canvasRatio) {
        self.videoPreview.canvasRatio = canvasRatio;
        switch (canvasRatio) {
            case 0:
                self.captureSession.config.outputSize = CGSizeMake(1280, 720);
            case 3:
                self.captureSession.config.outputSize = CGSizeMake(720, 1280);
                self.captureSession.config.sessionPreset = AVCaptureSessionPreset1280x720;
                [self.captureSession changePreset:AVCaptureSessionPreset1280x720];
                break;
            case 1:
                self.captureSession.config.outputSize = CGSizeMake(640, 480);
                self.captureSession.config.sessionPreset = AVCaptureSessionPreset640x480;
                [self.captureSession changePreset:AVCaptureSessionPreset640x480];
                break;
            case 2:
                self.captureSession.config.outputSize = CGSizeMake(480, 480);
                self.captureSession.config.sessionPreset = AVCaptureSessionPreset640x480;
                [self.captureSession changePreset:AVCaptureSessionPreset640x480];
                break;
            default:
                break;
        }
    };
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    self.videoPreview.frame = CGRectMake(0, 0, size.width, size.height);
    [self.videoPreview setNeedsLayout];
}

- (void)exitVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
