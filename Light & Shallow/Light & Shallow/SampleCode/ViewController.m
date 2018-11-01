//
//  ViewController.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/24.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "ViewController.h"
#import "RealtimeFilterViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "LSAVCommand.h"
#import "LSAVExtractAudioCommand.h"
#import "LSAVCompositionCommand.h"
#import "LSAVExportCommand.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 80, 45);
    [btn setTitle:@"跳转" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor blueColor];
    [btn addTarget:self action:@selector(compose) forControlEvents:UIControlEventTouchUpInside];
}

- (void) jump{
//    RealtimeFilterViewController* vc = [[RealtimeFilterViewController alloc] init];
//    [self presentViewController:vc animated:YES completion:nil];
    
    NSString* audioURL = [[NSBundle mainBundle] pathForResource:@"nnn" ofType:@"mp4"];
    AVAsset* audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:audioURL] options:nil];
    
    LSAVExtractAudioCommand* audioCommand = [[LSAVExtractAudioCommand alloc] initWithComposition:nil videoComposition:nil audioMix:nil];
    [audioCommand performWithAsset:audioAsset completion:^(LSAVCommand *avCommand) {
        
    }];
}

- (void)compose{
    NSString* videoURL1 = [[NSBundle mainBundle] pathForResource:@"nnn" ofType:@"mp4"];
    AVAsset* videoAsset1 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL1] options:nil];
    
    NSString* videoURL2 = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    AVAsset* videoAsset2 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL2] options:nil];
    
    LSAVCompositionCommand* command = [[LSAVCompositionCommand alloc] initWithComposition:nil videoComposition:nil audioMix:nil];
    [command performWithAsset:videoAsset2 secondAsset:videoAsset1 completion:^(LSAVCommand *avCommand) {
        LSAVExportCommand* export = [[LSAVExportCommand alloc] initWithComposition:avCommand.mutableComposition videoComposition:avCommand.mutableVideoComposition audioMix:avCommand.mutableAudioMix];
        [export performWithAsset:nil completion:^(LSAVCommand *avCommand) {
            NSLog(@"ddddd");
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
