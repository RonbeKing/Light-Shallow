//
//  LSOperationView.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/15.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSOperationView.h"

@interface LSOperationView ()

@property (nonatomic, assign) int count;

@end

@implementation LSOperationView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3];
        [self initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3];
        [self initUI];
    }
    return self;
}

- (void)initUI{
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 20, 80, 50);
    [btn setTitle:@"record" forState:UIControlStateNormal];
    [self addSubview:btn];
    [btn addTarget:self action:@selector(recordVideo) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(20, 90, 80, 50);
    [btn2 setTitle:@"endRec" forState:UIControlStateNormal];
    [self addSubview:btn2];
    [btn2 addTarget:self action:@selector(finishRecord) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame = CGRectMake(120, 20, 80, 50);
    [btn3 setTitle:@"flip" forState:UIControlStateNormal];
    [self addSubview:btn3];
    [btn3 addTarget:self action:@selector(flipCam) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn4.frame = CGRectMake(120, 90, 80, 50);
    [btn4 setTitle:@"canvas" forState:UIControlStateNormal];
    [self addSubview:btn4];
    [btn4 addTarget:self action:@selector(ajustCanvas:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)recordVideo{
    if (self.beginRecordBlock) {
        self.beginRecordBlock();
    }
}

- (void)finishRecord{
    if (self.endRecordBlock) {
        self.endRecordBlock();
    }
}

- (void)flipCam{
    if (self.flipCameraBlock) {
        self.flipCameraBlock();
    }
}

- (void)ajustCanvas:(LSCanvasRatio)canvasRatio{
    self.count %= 4;
    if (self.ajustCanvasBlock) {
        self.ajustCanvasBlock(self.count++);
    }
}

@end
