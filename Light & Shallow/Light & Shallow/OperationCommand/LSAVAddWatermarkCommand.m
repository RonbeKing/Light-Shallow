//
//  LSAVAddWatermarkCommand.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/24.
//  Copyright © 2018年 Ronb X. All rights reserved.
//
//  ******************************************************
//  * Disclaimer: IMPORTANT:  This idea comes from Apple *
//  ******************************************************

#import "LSAVAddWatermarkCommand.h"
#import <UIKit/UIKit.h>

@implementation LSAVAddWatermarkCommand

- (void)performWithAsset:(AVAsset*)asset completion:(processResult)block{
    
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
    }
    // Insert the video and audio tracks from AVAsset
    if (assetVideoTrack != nil) {
        AVMutableCompositionTrack *compositionVideoTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetVideoTrack atTime:insertionPoint error:&error];
    }
    if (assetAudioTrack != nil) {
        AVMutableCompositionTrack *compositionAudioTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetAudioTrack atTime:insertionPoint error:&error];
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
        
        CGSize videoSize = self.mutableVideoComposition.renderSize;
        [self watermarkWithType:LSWatermarkTypeImage videosize:videoSize position:CGRectZero];
    }
    
    // Step 3
    // finish block
    if (block) {
        block(self);
    }
}

- (void)watermarkWithType:(LSWatermarkType)watermarkType videosize:(CGSize)videoSize position:(CGRect)position{
    
    CALayer* watermarkLayer = [CALayer layer];
    watermarkLayer.bounds = CGRectMake(0, 0, 256*1.0, 256*1.0);
    
    if (watermarkType == LSWatermarkTypeText) {
        CATextLayer *titleLayer = [CATextLayer layer];
        titleLayer.string = @"LSAV";
        titleLayer.foregroundColor = [[UIColor whiteColor] CGColor];
        titleLayer.shadowOpacity = 0.5;
        titleLayer.alignmentMode = kCAAlignmentCenter;
        titleLayer.bounds = CGRectMake(0, 0, videoSize.width/2, videoSize.height/2);
        titleLayer.backgroundColor = [UIColor blueColor].CGColor;
        // Add it to the overall layer.
        [watermarkLayer addSublayer:titleLayer];
    }else if (watermarkType == LSWatermarkTypeImage){
        watermarkLayer.contents = CFBridgingRelease([UIImage imageNamed:@"waterMark"].CGImage);
    }
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, self.mutableVideoComposition.renderSize.width, self.mutableVideoComposition.renderSize.height);
    videoLayer.frame = CGRectMake(0, 0, self.mutableVideoComposition.renderSize.width, self.mutableVideoComposition.renderSize.height);
    [parentLayer addSublayer:videoLayer];
    watermarkLayer.position = CGPointMake(self.mutableVideoComposition.renderSize.width - 132, self.mutableVideoComposition.renderSize.height - 52);
    [parentLayer addSublayer:watermarkLayer];
    self.mutableVideoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

@end
