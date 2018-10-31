//
//  LSVideoEditorViewController.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/31.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSVideoEditorViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LSVideoPlayerView.h"

@interface LSVideoEditorViewController ()

@end

@implementation LSVideoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    LSVideoPlayerView* videoPlayerView = [[LSVideoPlayerView alloc] initWithAsset:self.asset frame:self.view.frame];
    [self.view addSubview:videoPlayerView];
    [videoPlayerView play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
