//
//  LSAVExportCommand.m
//  coreImg
//
//  Created by 王珑宾 on 2018/10/24.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import "LSAVExportCommand.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetManager.h"

@implementation LSAVExportCommand

- (void)performWithAsset:(AVAsset *)asset completion:(processResult)block{
    // Step 1
    // Create an outputURL to which the exported movie will be saved
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    outputURL = [outputURL stringByAppendingPathComponent:@"output.mp4"];
    // Remove Existing File
    [manager removeItemAtPath:outputURL error:nil];
    
    
    // Step 2
    // Create an export session with the composition and write the exported movie to the photo library
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:[self.mutableComposition copy] presetName:AVAssetExportPreset1280x720];
    
    self.exportSession.videoComposition = self.mutableVideoComposition;
    self.exportSession.audioMix = self.mutableAudioMix;
    self.exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    self.exportSession.outputFileType=AVFileTypeMPEG4;
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        switch (self.exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
                [self writeVideoToPhotoLibrary:outputURL];
                if (block) {
                    block(self);
                }

                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed:%@",self.exportSession.error);
                self.executeStatus = NO;
                if (block) {
                    block(self);
                }
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled:%@",self.exportSession.error);
                self.executeStatus = NO;
                if (block) {
                    block(self);
                }
                break;
            default:
                break;
        }
    }];
}

- (void)writeVideoToPhotoLibrary:(NSString *)url{
    [AssetManager saveVideo:url toAlbum:@"RXAlbum" completion:^(NSURL *url, NSError *error) {
        if (error) {
            NSLog(@"save to album failed");
        }else{
            NSLog(@"save to album success");
        }
    }];
}

@end
