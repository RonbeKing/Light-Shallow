//
//  LSCompositionViewController.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/1.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSCompositionViewController.h"
#import "LSVideoPlayerView.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "LSAVCommand.h"
#import "LSAVCompositionCommand.h"
#import "LSAVAddMusicCommand.h"
#import "LSAVAddWatermarkCommand.h"
#import "LSAVExportCommand.h"


@interface LSCompositionViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@property (weak, nonatomic) IBOutlet LSVideoPlayerView *player1;
@property (weak, nonatomic) IBOutlet LSVideoPlayerView *player2;
@property (weak, nonatomic) IBOutlet LSVideoPlayerView *player3;

@property (nonatomic, strong) AVAsset* asset1;
@property (nonatomic, strong) AVAsset* asset2;

@property (nonatomic, strong) UIImagePickerController* picker;
@property (nonatomic, strong) UIImagePickerController* picker2;
@end

@implementation LSCompositionViewController

- (IBAction)btn1tap:(id)sender {
    [self presentViewController:self.picker animated:YES completion:nil];
}

- (IBAction)btn2Tap:(id)sender {
    [self presentViewController:self.picker2 animated:YES completion:nil];
}
- (IBAction)btn3Tap:(id)sender {
    
    
//    NSString* videoURL1 = [[NSBundle mainBundle] pathForResource:@"nnn" ofType:@"mp4"];
//    AVAsset* videoAsset1 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL1] options:nil];
//
//    NSString* videoURL2 = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
//    AVAsset* videoAsset2 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL2] options:nil];
    
    LSAVCompositionCommand* command = [[LSAVCompositionCommand alloc] initWithComposition:nil videoComposition:nil audioMix:nil];
    [command performWithAsset:self.asset1 secondAsset:self.asset2 completion:^(LSAVCommand *avCommand) {
        LSAVExportCommand* export = [[LSAVExportCommand alloc] initWithComposition:avCommand.mutableComposition videoComposition:avCommand.mutableVideoComposition audioMix:avCommand.mutableAudioMix];
        [export performWithAsset:nil completion:^(LSAVCommand *avCommand) {
            NSLog(@"ddddd");
            self.player3.asset = avCommand.mutableComposition;
            [self.player3 play];
        }];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.picker = [[UIImagePickerController alloc] init];
    _picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    _picker.delegate = self;
    _picker.mediaTypes = @[@"public.movie",@"public.image"];
    
    self.picker2 = [[UIImagePickerController alloc] init];
    _picker2.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    _picker2.delegate = self;
    _picker2.mediaTypes = @[@"public.movie",@"public.image"];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*)kUTTypeMovie]) {
        NSURL *URL = info[UIImagePickerControllerMediaURL];
        
        if (picker == self.picker2) {
            self.player2.videoURL = URL;
            self.asset2 = [AVAsset assetWithURL:URL];
            [self.player2 play];
        }else{
            self.player1.videoURL = URL;
            self.asset1 = [AVAsset assetWithURL:URL];
            [self.player1 play];
        }
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
