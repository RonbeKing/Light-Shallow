//
//  videoPreview.m
//  coreImg
//
//  Created by 王珑宾 on 2018/10/11.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import "videoPreview.h"

@interface videoPreview ()
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) UIView* focusView;
@end

@implementation videoPreview

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
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    self.previewLayer.frame = self.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //self.previewLayer.anchorPoint = CGPointZero;
    [self.layer insertSublayer:self.previewLayer atIndex:0];
    [self addSubview:self.focusView];
    
    UITapGestureRecognizer* focusGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
    [self addGestureRecognizer:focusGest];
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
}

-(void)setImageContents:(id)imageContents{
    self.previewLayer.contents = imageContents;
}

-(UIView *)focusView{
    if (!_focusView) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _focusView.layer.borderColor = [UIColor greenColor].CGColor;
        _focusView.layer.borderWidth = 1.0f;
        _focusView.hidden = YES;
    }
    return _focusView;
}
@end
