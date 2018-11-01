//
//  LSAVCompositionCommand.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/1.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSAVCompositionCommand.h"

@implementation LSAVCompositionCommand

- (void)performWithAsset:(AVAsset *)asset1 secondAsset:(AVAsset *)asset2 completion:(processResult)block{
    
    AVAssetTrack* videoTrack = nil;
    AVAssetTrack* audioTrack = nil;
    
    if ([asset1 tracksWithMediaType:AVMediaTypeVideo].count != 0) {
        videoTrack = [asset1 tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([asset2 tracksWithMediaType:AVMediaTypeAudio].count != 0) {
        audioTrack = [asset2 tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    if (!self.mutableComposition) {
        self.mutableComposition = [AVMutableComposition composition];
    }
    
    NSError* error = nil;
    if (videoTrack) {
        AVMutableCompositionTrack* compositionVideoTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset1 duration]) ofTrack:videoTrack atTime:kCMTimeZero error:&error];
    }
    if (audioTrack) {
        AVMutableCompositionTrack* compositionAudioTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset1 duration]) ofTrack:audioTrack atTime:kCMTimeZero error:&error];
    }
    
    if (block) {
        block(self);
    }
}

@end
