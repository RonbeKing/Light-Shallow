//
//  LSVideoEditor.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/1.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSVideoEditor.h"

@interface LSVideoEditor ()

@property (nonatomic, strong) LSAVCommand* avCommand;

@end

@implementation LSVideoEditor

- (void)addMusicToAsset:(AVAsset *)asset completion:(void (^)(LSAVCommand *))block{
    LSAVAddMusicCommand* musicCommand = [[LSAVAddMusicCommand alloc] initWithComposition:self.avCommand.mutableComposition videoComposition:self.avCommand.mutableVideoComposition audioMix:self.avCommand.mutableAudioMix];
    [musicCommand performWithAsset:asset completion:^(LSAVCommand *avCommand) {
        self.avCommand = avCommand;
        if (block) {
            block(avCommand);
        }
    }];
}

- (void)addWatermark:(LSWatermarkType)watermarkType inAsset:(AVAsset *)asset completion:(void (^)(LSAVCommand *))block{
    LSAVAddWatermarkCommand* watermarkCommand = [[LSAVAddWatermarkCommand alloc] initWithComposition:self.avCommand.mutableComposition videoComposition:self.avCommand.mutableVideoComposition audioMix:self.avCommand.mutableAudioMix];
    [watermarkCommand performWithAsset:asset completion:^(LSAVCommand *avCommand) {
        self.avCommand = avCommand;
        if (block) {
            block(avCommand);
        }
    }];
}

- (void)exportAsset:(AVAsset*)asset{
    LSAVExportCommand* exportCommand = [[LSAVExportCommand alloc] initWithComposition:self.avCommand.mutableComposition videoComposition:self.avCommand.mutableVideoComposition audioMix:self.avCommand.mutableAudioMix];
    
    [exportCommand performWithAsset:asset completion:^(LSAVCommand *avCommand) {
        if (avCommand.executeStatus) {
            NSLog(@"export successfully");
        }else{
            NSLog(@"export fail");
        }
    }];
}

@end
