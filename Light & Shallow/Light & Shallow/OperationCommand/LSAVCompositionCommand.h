//
//  LSAVCompositionCommand.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/1.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSAVCommand.h"

@interface LSAVCompositionCommand : LSAVCommand

// compose the videoTrack of asset1 and audioTrack of asset2
- (void)performWithAsset:(AVAsset *)asset1 secondAsset:(AVAsset *)asset2 completion:(processResult)block;

@end
