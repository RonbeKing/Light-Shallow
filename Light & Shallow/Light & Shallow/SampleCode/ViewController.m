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

#import "LSCompositionViewController.h"
#import "LSImageProcessViewController.h"

#import "LSVideoEditorViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 80, 45);
    [btn setTitle:@"视频录制" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor cyanColor];
    [btn addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(100, 200, 80, 45);
    [btn2 setTitle:@"视频合成" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    btn2.backgroundColor = [UIColor purpleColor];
    [btn2 addTarget:self action:@selector(compose) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame = CGRectMake(100, 300, 80, 45);
    [btn3 setTitle:@"图片处理" forState:UIControlStateNormal];
    [self.view addSubview:btn3];
    btn3.backgroundColor = [UIColor blueColor];
    [btn3 addTarget:self action:@selector(toVideoEditor) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) jump{
    RealtimeFilterViewController* vc = [[RealtimeFilterViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
    
//    NSString* audioURL = [[NSBundle mainBundle] pathForResource:@"nnn" ofType:@"mp4"];
//    AVAsset* audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:audioURL] options:nil];
//
//    LSAVExtractAudioCommand* audioCommand = [[LSAVExtractAudioCommand alloc] initWithComposition:nil videoComposition:nil audioMix:nil];
//    [audioCommand performWithAsset:audioAsset completion:^(LSAVCommand *avCommand) {
//
//    }];
}

- (void)compose{
    
    LSCompositionViewController* compose = [self.storyboard instantiateViewControllerWithIdentifier:@"compose"];
    [self presentViewController:compose animated:YES completion:nil];
    
    
    
//    NSString* videoURL1 = [[NSBundle mainBundle] pathForResource:@"nnn" ofType:@"mp4"];
//    AVAsset* videoAsset1 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL1] options:nil];
//
//    NSString* videoURL2 = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
//    AVAsset* videoAsset2 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL2] options:nil];
//
//    LSAVCompositionCommand* command = [[LSAVCompositionCommand alloc] initWithComposition:nil videoComposition:nil audioMix:nil];
//    [command performWithAsset:videoAsset2 secondAsset:videoAsset1 completion:^(LSAVCommand *avCommand) {
//        LSAVExportCommand* export = [[LSAVExportCommand alloc] initWithComposition:avCommand.mutableComposition videoComposition:avCommand.mutableVideoComposition audioMix:avCommand.mutableAudioMix];
//        [export performWithAsset:nil completion:^(LSAVCommand *avCommand) {
//            NSLog(@"ddddd");
//        }];
//    }];
}

- (void)toImageProcess{
    LSImageProcessViewController* imgPro = [[LSImageProcessViewController alloc] init];
    [self presentViewController:imgPro animated:YES completion:nil];
}

- (void)toVideoEditor{
    LSVideoEditorViewController* videoEditor = [[LSVideoEditorViewController alloc] init];
    
    NSString* filePath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Documents/videoTemp"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* theFilePath = [filePath stringByAppendingString:@"/test.mp4"];
    
    AVAsset* asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:theFilePath] options:nil];
    
    
    NSString *secondVideoPath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    AVAsset* asset2 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:secondVideoPath] options:nil];
    
    videoEditor.asset = asset2;
    [self presentViewController:videoEditor animated:YES completion:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
