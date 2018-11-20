//
//  LSRecordOperationView.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/20.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSRecordOperationView.h"

@interface LSRecordOperationView ()

@property (nonatomic, assign) BOOL isRecording;
@property (weak,   nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign) int second;
@end

@implementation LSRecordOperationView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.second ++;
        self.countLabel.text = [NSString stringWithFormat:@"%d s",self.second];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (IBAction)recordAction:(UIButton *)sender {
    self.isRecording = !self.isRecording;
    if (self.isRecording) {
        [self.timer setFireDate:[NSDate distantPast]];
        if (self.beginRecordBlock) {
            self.beginRecordBlock();
        }
    }else{
        [self.timer setFireDate:[NSDate distantFuture]];
        self.second = 0;
        if (self.endRecordBlock) {
            self.endRecordBlock();
        }
    }
}

- (IBAction)canvas:(UIButton *)sender {
    if (self.ajustCanvasBlock) {
        self.ajustCanvasBlock(sender.tag - 1);
    }
}

- (IBAction)filters:(UIButton *)sender {
    if (self.changeFilterBlock) {
        self.changeFilterBlock((int)sender.tag - 1);
    }
}

- (IBAction)flip:(id)sender {
    if (self.flipCameraBlock) {
        self.flipCameraBlock();
    }
}

- (IBAction)flash:(id)sender {
    if (self.changeTorchModeBlock) {
        self.changeTorchModeBlock();
    }
}
@end
