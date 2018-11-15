//
//  LSVideoPreview.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/11.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import "LSVideoPreview.h"
#import "LSSliderView.h"
#import "LSConstants.h"

#define KScreenWidth  [UIScreen mainScreen].bounds.size.width
#define KScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface LSVideoPreview ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) CALayer* previewLayer;
@property (nonatomic, strong) UIView* focusView;
@property (nonatomic, strong) LSSliderView * slider;
@property (nonatomic, assign) CGFloat lastScale;
@end

@implementation LSVideoPreview

- (instancetype)init{
    if (self = [super init]) {
        [self initialPreviewLayer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initialPreviewLayer];
    }
    return self;
}

- (void)initialPreviewLayer{
    self.previewLayer = [[CALayer alloc] init];
    //self.previewLayer.frame = self.bounds;
    self.previewLayer.contentsGravity = @"resizeAspectFill";
    self.previewLayer.masksToBounds = YES;
    //self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //self.previewLayer.anchorPoint = CGPointZero;
    [self.layer insertSublayer:self.previewLayer atIndex:0];
    [self addSubview:self.focusView];
    
    UITapGestureRecognizer* focusGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
    [self addGestureRecognizer:focusGest];
    _lastScale = 1.0;
    [self initSliderView];
    [self initGester];
}

- (void)initSliderView{
    [self addSubview:self.slider];
    self.slider.frame = CGRectMake(0, 0, KScreenWidth - 80, 50);
    self.slider.center = CGPointMake(40, KScreenHeight/2 -20);
    self.slider.transform = CGAffineTransformMakeRotation(-90*M_PI/180);
}

- (void)initGester{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(tapViewAction)];
    [self addGestureRecognizer:tapGesture];

    UIPinchGestureRecognizer * pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    pinchGesture.delegate = self;
    [self addGestureRecognizer:pinchGesture];
}

- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        float currentScale = _lastScale - (1 - pinchGestureRecognizer.scale)*0.05;
        if (currentScale < DEFAULT_VIDEO_ZOOM_FACTOR_MIN) {
            currentScale = DEFAULT_VIDEO_ZOOM_FACTOR_MIN;
        }
        if (currentScale > DEFAULT_VIDEO_ZOOM_FACTOR_MAX) {
            currentScale = DEFAULT_VIDEO_ZOOM_FACTOR_MAX;
        }
        if (currentScale >= DEFAULT_VIDEO_ZOOM_FACTOR_MIN && currentScale <= DEFAULT_VIDEO_ZOOM_FACTOR_MAX) {
            self.slider.value = currentScale;
            self.focalizeAdjustmentBlock(currentScale);
            _lastScale = currentScale;
        }
    }
}

- (void)tapViewAction{
    self.slider.hidden = !self.slider.hidden;
}

- (void) focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusCameraAtPoint:point];
}

- (void)focusCameraAtPoint:(CGPoint)focusPoint{
    self.focusView.center = focusPoint;
    self.focusView.hidden = NO;
    [UIView animateWithDuration:0.35 animations:^{
        self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.35 animations:^{
            self.focusView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.focusView.hidden = YES;
        }];
    }];
    
    CGSize previewSize = self.bounds.size;
    focusPoint = CGPointMake(focusPoint.y / previewSize.height, 1 - focusPoint.x / previewSize.width);
    if (self.focusBlock) {
        self.focusBlock(focusPoint);
    }
    if (self.exposureBlock) {
        self.exposureBlock(focusPoint);
    }
}

-(void)layoutSubviews{
    self.previewLayer.frame = self.bounds;
    if (self.bounds.size.width >self.bounds.size.height) {
        self.slider.center = CGPointMake(40, self.bounds.size.height/2 + 20);
    }else{
        self.slider.center = CGPointMake(40, self.bounds.size.height/2 + 20);
    }
}

-(void)setImageContents:(id)imageContents{
    self.previewLayer.contents = imageContents;
}

- (void)setCanvasRatio:(LSCanvasRatio)canvasRatio{
    _canvasRatio = canvasRatio;
    switch (canvasRatio) {
        case LSCanvasRatio1X1:
        {
            self.frame = CGRectMake(0, 40, KScreenWidth, KScreenWidth);
            [self layoutSubviews];
        }
            break;
        case LSCanvasRatio16X9:
        {
            self.frame = CGRectMake(0, 40, KScreenWidth, KScreenWidth*9/16);
            [self layoutSubviews];
        }
            break;
        case LSCanvasRatio9X16:
        {
            self.frame = CGRectMake(0, 40, KScreenWidth, KScreenWidth*16/9);
            [self layoutSubviews];
        }
            break;
        case LSCanvasRatio4X3:
        {
            self.frame = CGRectMake(0, 40, KScreenWidth, KScreenWidth*3/4);
            [self layoutSubviews];
        }
            break;
        default:
            break;
    }
}

-(UIView *)focusView{
    if (!_focusView) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _focusView.layer.borderColor = [UIColor greenColor].CGColor;
        _focusView.layer.borderWidth = DEFAULT_VIDEO_ZOOM_FACTOR_MIN;
        _focusView.hidden = YES;
    }
    return _focusView;
}

- (LSSliderView *)slider{
    if (!_slider) {
        _slider = [[LSSliderView alloc] init];
        _slider.hidden = NO;
        _slider.minimumValue = DEFAULT_VIDEO_ZOOM_FACTOR_MIN;
        _slider.maximumValue = DEFAULT_VIDEO_ZOOM_FACTOR_MAX;
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
    self.focalizeAdjustmentBlock(slider.value);
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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}
@end
