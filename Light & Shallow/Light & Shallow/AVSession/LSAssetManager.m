//
//  LSAssetManager.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/23.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import "LSAssetManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "LSMediaInfo.h"

@implementation LSAssetManager

#pragma mark -- save video to custom album
+ (void)saveVideo:(NSString *)videoUrl toAlbum:(NSString *)albumName completion:(void (^)(NSURL* url, NSError* error))block{
    NSURL* url = [NSURL fileURLWithPath:videoUrl];
    
    AVAsset* asset = [AVAsset assetWithURL:url];
    [self printMediaInfoWithAsset:asset];
    
    if ([self createAlbum:albumName]) {
        PHFetchResult *fetchResult = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        
        [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection* assetCollection, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([assetCollection.localizedTitle isEqualToString:albumName]) {
                *stop = YES;
                NSError* saveVideoError = nil;
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    PHAssetChangeRequest* assetReq = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                    PHAssetCollectionChangeRequest* collectionReq = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                    PHObjectPlaceholder* placeHolder = [assetReq placeholderForCreatedAsset];
                    [collectionReq addAssets:@[placeHolder]];
                } error:&saveVideoError];
                if (saveVideoError) {
                    if (block) {
                        block(nil, saveVideoError);
                    }
                }else {
                    if (block) {
                        block(url, nil);
                    }
                }
            }
        }];
    }
}

+ (BOOL)isAlbumExist:(NSString *)albumName{
    PHFetchResult* fetchResult = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    __block BOOL isExist = NO;
    [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection* assetCollection, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([assetCollection.localizedTitle isEqualToString:albumName]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    return isExist;
}

+ (BOOL)createAlbum:(NSString *)albumName{
    if (![self isAlbumExist:albumName]) {
        NSError* error;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
        } error:&error];
        if (error) {
            return NO;
        }else{
            return YES;
        }
    }else{
        return YES;
    }
}

+ (void)printMediaInfoWithAsset:(AVAsset*)asset{
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    LSMediaInfo* info = [[LSMediaInfo alloc] init];
    info.videoWidth = assetVideoTrack.naturalSize.width;
    info.videoHeight = assetVideoTrack.naturalSize.height;
    info.videoFrameRate = assetVideoTrack.nominalFrameRate;
    info.videoOutputBitrate = assetVideoTrack.estimatedDataRate;
    info.videoDuration = assetVideoTrack.timeRange.duration;
    info.videoByte = assetVideoTrack.totalSampleDataLength + assetAudioTrack.totalSampleDataLength;
    
    CGAffineTransform t = assetVideoTrack.preferredTransform;
    LSVideoOrientation orientation = LSVideoOrientationPortrait;
    
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
        orientation = LSVideoOrientationPortraitUpsideDown;
    }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
        orientation = LSVideoOrientationLandscapeRight;
    }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
        orientation = LSVideoOrientationPortrait;
    }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
        orientation = LSVideoOrientationLandscapeLeft;
    }
    info.videoOrientation = orientation;
    
    NSLog(@"______%@",info);
}

@end
