//
//  LSAssetManager.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/23.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LSAssetManager : NSObject

+ (void)saveVideo:(NSString *)videoUrl toAlbum:(NSString *)albumName completion:(void (^)(NSURL* url, NSError* error))block;

@end
