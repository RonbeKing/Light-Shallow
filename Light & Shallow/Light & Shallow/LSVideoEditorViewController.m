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

#import "LSAVSession.h"
#import "LSAVCommand.h"

@interface LSVideoEditorViewController ()

@property (nonatomic, strong) LSVideoPlayerView* player;

@end

@implementation LSVideoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.player = [[LSVideoPlayerView alloc] initWithAsset:self.asset frame:self.view.frame];
    [self.view addSubview:self.player];
    [self.player play];
    
    UIButton* addMusicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addMusicBtn.frame = CGRectMake(35, KScreenHeight - 90, 100, 45);
    [addMusicBtn setTitle:@"add music" forState:UIControlStateNormal];
    [addMusicBtn addTarget:self action:@selector(addMusic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addMusicBtn];
    
    UIButton* addWatermarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addWatermarkBtn.frame = CGRectMake(170, KScreenHeight - 90, 100, 45);
    [addWatermarkBtn setTitle:@"添加水印" forState:UIControlStateNormal];
    [addWatermarkBtn addTarget:self action:@selector(addWatermark) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addWatermarkBtn];
    
}

- (void)addMusic{
    [[LSAVSession sharedInstance] addMusicToAsset:self.asset completion:^(LSAVCommand *avCommand) {
        [self.player replaceItemWithAsset:avCommand.mutableComposition];
    }];
}

- (void)addWatermark{
    [[LSAVSession sharedInstance] addWatermark:LSWatermarkTypeImage inAsset:self.asset completion:^(LSAVCommand *avCommand) {
        [self.player replaceItemWithAsset:avCommand.mutableComposition];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
