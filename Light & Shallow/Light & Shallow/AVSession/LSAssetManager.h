//
//  LSAssetManager.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/23.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef void(^AuthBlock)(AVAuthorizationStatus cerma,PHAuthorizationStatus photos ,AVAuthorizationStatus alumb,NSInteger isShowAuthView);

@class AVAsset;
@interface LSAssetManager : NSObject

#pragma mark -- 验证是否具有媒体权限
+ (BOOL)cameraAuthorized;
+ (BOOL)microPhoneAuthorized;
+ (BOOL)albumAuthorized;

#pragma mark -- 请求媒体权限
+ (void)requestCameraAuth:(void(^)(BOOL granted))authorized;
+ (void)requestMicroPhoneAuth:(void(^)(BOOL granted))authorized;
+ (void)requestAlbumAuth:(void(^)(BOOL granted))authorized;

#pragma mark -- 保存视频到指定相册
+ (void)saveVideo:(NSString *)videoUrl toAlbum:(NSString *)albumName completion:(void (^)(NSURL* url, NSError* error))block;

#pragma mark -- 打印媒体信息
/*you can check the class 'LSMediaInfo' for the log information*/
+ (void)printMediaInfoWithAsset:(AVAsset*)asset;

#pragma mark -- 打印图片头EXIF信息

@end
