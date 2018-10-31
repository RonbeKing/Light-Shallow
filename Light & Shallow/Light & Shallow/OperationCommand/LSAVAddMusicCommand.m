//
//  LSAVAddMusicCommand.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/30.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSAVAddMusicCommand.h"

@implementation LSAVAddMusicCommand

-(void)performWithAsset:(AVAsset *)asset completion:(processResult)block{
    
    AVAssetTrack* videoTrack = nil;
    AVAssetTrack* audioTrack = nil;
    
    if ([asset tracksWithMediaType:AVMediaTypeVideo].count != 0) {
        videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([asset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
        audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    NSError* error = nil;
    NSString* audioURL = [[NSBundle mainBundle] pathForResource:@"Music" ofType:@"m4a"];
    AVAsset* audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:audioURL] options:nil];
    AVAssetTrack* newAudioTrack = [audioAsset tracksWithMediaType:AVMediaTypeAudio][0];
    
    if (!self.mutableComposition) {
        self.mutableComposition = [AVMutableComposition composition];
    }
    if (videoTrack) {
        AVMutableCompositionTrack* compositionVideoTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:videoTrack atTime:kCMTimeZero error:&error];
    }
    if (audioTrack) {
        AVMutableCompositionTrack* compositionAudioTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:audioTrack atTime:kCMTimeZero error:&error];
    }
    
    if (newAudioTrack) {
        AVMutableCompositionTrack* customAudioTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [customAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [self.mutableComposition duration]) ofTrack:newAudioTrack atTime:kCMTimeZero error:&error];
    }
    
    AVMutableAudioMixInputParameters* mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:newAudioTrack];
    //[mixParameters setVolumeRampFromStartVolume:1 toEndVolume:0 timeRange:CMTimeRangeMake(kCMTimeZero, self.mutableComposition.duration)];
    
    self.mutableAudioMix = [AVMutableAudioMix audioMix];
    self.mutableAudioMix.inputParameters = @[mixParameters];
    
    
    if (block) {
        block(self);
    }
}

@end
