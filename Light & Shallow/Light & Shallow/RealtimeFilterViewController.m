//
//  realtimeFilterViewController.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/9.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import "RealtimeFilterViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LSVideoPreview.h"
#import "LSAssetManager.h"


#import "LSAVSession.h"
#import "LSSliderView.h"

#define KScreenWidth  [UIScreen mainScreen].bounds.size.width
#define KScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface RealtimeFilterViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic, strong) LSVideoPreview* videoPreview;
@end

@implementation RealtimeFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
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
    [btn2 addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    
    //    __block int count = 0;
    //    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
    //        count++;
    //        if (count == 4) {
    //            count = 0;
    //        }
    //        self.filter = [CIFilter filterWithName:self.filterNames[count]];
    //    }];
    //    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)initCaptureSession{
    // init capture session
    
    // video preview
    self.videoPreview = [[LSVideoPreview alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    [self.view addSubview:self.videoPreview];
    
    [[LSAVSession sharedInstance] startCaptureWithVideoPreview:self.videoPreview];
}

- (void)exitVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchCamera{
    [[LSAVSession sharedInstance] switchCamera];
}

- (void)recordVideo{
    [[LSAVSession sharedInstance] startRecord];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
//    self.videoPreview.frame = CGRectMake(0, 0, size.width, size.height);
//    [self.videoPreview setNeedsLayout];
}
@end
