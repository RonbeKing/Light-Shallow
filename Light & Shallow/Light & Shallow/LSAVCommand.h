//
//  LSAVCommand.h
//  coreImg
//
//  Created by 王珑宾 on 2018/10/24.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LSAVCommand : NSObject

@property (nonatomic, strong) AVMutableComposition* mutableComposition;
@property (nonatomic, strong) AVMutableVideoComposition* mutableVideoComposition;
@property (nonatomic, strong) AVMutableAudioMix* mutableAudioMix;
@property (nonatomic, strong) CALayer* watermarkLayer;

- (instancetype)initWithComposition:(AVMutableComposition *)composition videoComposition:(AVMutableVideoComposition *)videoComposition audioMix:(AVMutableAudioMix *)audioMix;

- (void)performWithAsset:(AVAsset *)asset;

@end
