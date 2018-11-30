//
//  ViewController.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/24.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSMainViewController.h"
#import "RealtimeFilterViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "LSAVCommand.h"
#import "LSAVExtractAudioCommand.h"
#import "LSAVCompositionCommand.h"
#import "LSAVExportCommand.h"

#import "LSCompositionViewController.h"
#import "LSImageProcessViewController.h"

#import "LSVideoEditorViewController.h"

#import "LSAssetManager.h"

@interface LSMainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *composeBtn;
@property (weak, nonatomic) IBOutlet UIButton *imageEditorBtn;

@end

@implementation LSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView* bgImgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, KScreenWidth, KScreenWidth)];
    bgImgv.image = [UIImage imageNamed:@"pic_no_live"];
    [self.view addSubview:bgImgv];
    
    self.recordBtn.backgroundColor = [UIColor cyanColor];
    [self cornerRadioWithBtn:self.recordBtn];
    [self.recordBtn addTarget:self action:@selector(jumpToRecord) forControlEvents:UIControlEventTouchUpInside];
    
    self.composeBtn.backgroundColor = [UIColor purpleColor];
    [self cornerRadioWithBtn:self.composeBtn];
    [self.composeBtn addTarget:self action:@selector(jumpToCompose) forControlEvents:UIControlEventTouchUpInside];
    
    self.imageEditorBtn.backgroundColor = [UIColor magentaColor];
    [self cornerRadioWithBtn:self.imageEditorBtn];
    [self.imageEditorBtn addTarget:self action:@selector(JumpToVideoEditor) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)cornerRadioWithBtn:(UIButton*)btn{
    btn.layer.cornerRadius = 8;
    btn.layer.masksToBounds = YES;
}

- (void) jumpToRecord{
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

- (void)jumpToCompose{
    
    LSCompositionViewController* compose = [self.storyboard instantiateViewControllerWithIdentifier:@"compose"];
    [self presentViewController:compose animated:YES completion:nil];
}

- (void)JumpToImageProcess{
    LSImageProcessViewController* imgPro = [[LSImageProcessViewController alloc] init];
    [self presentViewController:imgPro animated:YES completion:nil];
}

- (void)JumpToVideoEditor{
    LSVideoEditorViewController* videoEditor = [[LSVideoEditorViewController alloc] init];
    
    NSString* filePath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Documents/videoTemp"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* theFilePath = [filePath stringByAppendingString:@"/test.mp4"];
    
    AVAsset* asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:theFilePath] options:nil];
    
    NSString *secondVideoPath = [[NSBundle mainBundle] pathForResource:@"dance" ofType:@"mp4"];
    AVAsset* asset2 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:secondVideoPath] options:nil];
    
    videoEditor.asset = asset2;
    [self presentViewController:videoEditor animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
