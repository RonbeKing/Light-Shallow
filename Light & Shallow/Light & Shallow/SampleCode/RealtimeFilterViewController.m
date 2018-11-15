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
#import "LSOperationView.h"
#import "LSAssetManager.h"
#import "LSAVSession.h"

@interface RealtimeFilterViewController ()
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
    // video preview
    self.videoPreview = [[LSVideoPreview alloc] init];
    self.videoPreview.canvasRatio = LSCanvasRatio1X1;
    [self.view addSubview:self.videoPreview];
    [[LSAVSession sharedInstance] startCaptureWithVideoPreview:self.videoPreview];
    
    LSOperationView* operationView = [[LSOperationView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 260, KScreenWidth, 260)];
    [self.view addSubview:operationView];
    
    operationView.beginRecordBlock = ^{
        [[LSAVSession sharedInstance] startRecord];
    };
    
    operationView.endRecordBlock = ^{
        [[LSAVSession sharedInstance] finishRecord:^(AVAsset *asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LSVideoEditorViewController* videoEditor = [[LSVideoEditorViewController alloc] init];
                videoEditor.asset = asset;
                [self presentViewController:videoEditor animated:YES completion:nil];
            });
        }];
    };
    
    operationView.flipCameraBlock = ^{
        [[LSAVSession sharedInstance] switchCamera];
    };
    
    operationView.ajustCanvasBlock = ^(LSCanvasRatio canvasRatio) {
        self.videoPreview.canvasRatio = canvasRatio;
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
