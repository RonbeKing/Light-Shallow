//
//  LSVideoEditor.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/1.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSAVCommand.h"
#import "LSAVExtractAudioCommand.h"
#import "LSAVAddMusicCommand.h"
#import "LSAVAddWatermarkCommand.h"
#import "LSAVExportCommand.h"


@interface LSVideoEditor : NSObject

- (void)addMusicToAsset:(AVAsset*)asset completion:(void(^)(LSAVCommand*avCommand))block;
- (void)addWatermark:(LSWatermarkType)watermarkType inAsset:(AVAsset*)asset completion:(void(^)(LSAVCommand *avCommand))block;
- (void)exportAsset:(AVAsset*)asset;

/**
 @brief 制作一个时长为15s的视频，帧率为30
 */
- (void)composeVideoWithImages:(NSArray*)images;

@end
