//
//  LSAVCommand.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/24.
//  Copyright © 2018年 Ronb X. All rights reserved.
//
//  ******************************************************
//  * Disclaimer: IMPORTANT:  This idea comes from Apple *
//  ******************************************************

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class LSAVCommand;
typedef void(^processResult)(LSAVCommand* avCommand);

@interface LSAVCommand : NSObject

@property (nonatomic, strong) AVMutableComposition* mutableComposition;
@property (nonatomic, strong) AVMutableVideoComposition* mutableVideoComposition;
@property (nonatomic, strong) AVMutableAudioMix* mutableAudioMix;

// The execution state of the command / success or not
@property (nonatomic, assign) BOOL executeStatus;

- (instancetype)initWithComposition:(AVMutableComposition *)composition videoComposition:(AVMutableVideoComposition *)videoComposition audioMix:(AVMutableAudioMix *)audioMix;

- (void)performWithAsset:(AVAsset *)asset completion:(processResult)block;

@end
