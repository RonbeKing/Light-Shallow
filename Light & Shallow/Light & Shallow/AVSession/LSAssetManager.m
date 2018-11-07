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

@implementation LSAssetManager

#pragma mark -- save video to custom album
+ (void)saveVideo:(NSString *)videoUrl toAlbum:(NSString *)albumName completion:(void (^)(NSURL* url, NSError* error))block{
    NSURL* url = [NSURL fileURLWithPath:videoUrl];
    if ([self createAlbum:albumName]) {
        NSError* saveVideoError = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            PHAssetChangeRequest* assetReq = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
            PHAssetCollectionChangeRequest* collectionReq = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
            PHObjectPlaceholder* placeHolder = [assetReq placeholderForCreatedAsset];
            [collectionReq addAssets:@[placeHolder]];
        } error:&saveVideoError];
        if (saveVideoError) {
            if (block) {
                block(nil, saveVideoError);
            }
        }else {
            if (block) {
                block(nil, nil);
            }
        }
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

@end
