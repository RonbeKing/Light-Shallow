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
@property (nonatomic, strong) LSSliderView * slider;

@end

@implementation RealtimeFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initCaptureSession];
    [self initSliderView];
    [self initGester];
    
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

- (void)initSliderView{
    [self.view addSubview:self.slider];
    self.slider.frame = CGRectMake(0, 0, KScreenWidth - 80, 50);
    self.slider.center = CGPointMake(40, KScreenHeight/2 -20);
    self.slider.transform = CGAffineTransformMakeRotation(-90*M_PI/180);
}

- (void)initGester{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(tapViewAction)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)tapViewAction{
    self.slider.hidden = !self.slider.hidden;
}

- (void)exitVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recordVideo{
    [[LSAVSession sharedInstance] startRecord];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    self.videoPreview.frame = CGRectMake(0, 0, size.width, size.height);
    [self.videoPreview setNeedsLayout];
    if (size.width >size.height) {
        self.slider.center = CGPointMake(size.width - 40, size.height/2 + 20);
    }else{
        self.slider.center = CGPointMake(40, size.height/2 + 20);
    }
}

- (LSSliderView *)slider{
    if (!_slider) {
        _slider = [[LSSliderView alloc] init];
        _slider.hidden = NO;
        _slider.minimumValue = 1.0;
        _slider.maximumValue = 3.0;
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_slider setThumbImage:[UIImage imageNamed:@"球"] forState:UIControlStateNormal];
        [_slider setThumbImage:[UIImage imageNamed:@"球"] forState:UIControlStateHighlighted];
        UIImage * image = [self createImageWithColor:[UIColor colorWithWhite:1 alpha:0.4]];
        [self.slider setMaximumTrackImage:image forState:UIControlStateNormal];
        [self.slider setMinimumTrackImage:image forState:UIControlStateNormal];
    }
    return _slider;
}

- (void)sliderValueChanged:(UISlider *)slider{
    NSLog(@"slilder.value = %f ",slider.value);
}

- (UIImage*) createImageWithColor:(UIColor*)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    CGContextStrokePath(context);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


@end
