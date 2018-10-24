//
//  LSAVAddWatermarkCommand.m
//  coreImg
//
//  Created by 王珑宾 on 2018/10/24.
//  Copyright © 2018年 Ronb X. All rights reserved.
//
//*****************************************************************
//Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
//*****************************************************************

#import "LSAVAddWatermarkCommand.h"
#import <UIKit/UIKit.h>

@implementation LSAVAddWatermarkCommand

- (void)performWithAsset:(AVAsset*)asset{
    self.watermarkLayer = nil;
    CGSize videoSize;
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    CMTime insertionPoint = kCMTimeZero;
    NSError *error = nil;
    
    // Step 1
    // Create a composition with the given asset and insert audio and video tracks into it from the asset
    if(!self.mutableComposition) {
        
        // Check if a composition already exists, else create a composition using the input asset
        self.mutableComposition = [AVMutableComposition composition];
        
        // Insert the video and audio tracks from AVAsset
        if (assetVideoTrack != nil) {
            AVMutableCompositionTrack *compositionVideoTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetVideoTrack atTime:insertionPoint error:&error];
        }
        if (assetAudioTrack != nil) {
            AVMutableCompositionTrack *compositionAudioTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetAudioTrack atTime:insertionPoint error:&error];
        }
    }
    
    // Step 2
    // Create a water mark layer of the same size as that of a video frame from the asset
    if ([[self.mutableComposition tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        
        if(!self.mutableVideoComposition) {
            
            // build a pass through video composition
            self.mutableVideoComposition = [AVMutableVideoComposition videoComposition];
            self.mutableVideoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
            self.mutableVideoComposition.renderSize = assetVideoTrack.naturalSize;
            
            AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [self.mutableComposition duration]);
            
            AVAssetTrack *videoTrack = [self.mutableComposition tracksWithMediaType:AVMediaTypeVideo][0];
            AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            passThroughInstruction.layerInstructions = @[passThroughLayer];
            self.mutableVideoComposition.instructions = @[passThroughInstruction];
            
        }
        
        videoSize = self.mutableVideoComposition.renderSize;
        self.watermarkLayer = [self watermarkLayerForSize:videoSize];
    }
    
    // Step 3
    // Notify AVSEViewController about add watermark operation completion
    //[[NSNotificationCenter defaultCenter] postNotificationName:AVSEEditCommandCompletionNotification object:self];
}

- (CALayer *)watermarkLayerForSize:(CGSize)videoSize{
    // Create a layer for the title
    CALayer *_watermarkLayer = [CALayer layer];
    
    // Create a layer for the text of the title.
    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.string = @"AVSE";
    titleLayer.foregroundColor = [[UIColor whiteColor] CGColor];
    titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentCenter;
    titleLayer.bounds = CGRectMake(0, 0, videoSize.width/2, videoSize.height/2);
    
    // Add it to the overall layer.
    [_watermarkLayer addSublayer:titleLayer];
    
    return _watermarkLayer;
}
@end
