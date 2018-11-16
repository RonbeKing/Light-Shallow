//
//  LSMediaInfo.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/16.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSMediaInfo.h"

@implementation LSMediaInfo

-(NSString *)description{
    
    NSString* descriptions = [NSString stringWithFormat:@"\n videoWidth = %f \n videoHeight = %f \n videoFrameRate = %f \n videoOutputBitrate = %f \n videoOrientation = %lu \n videoDuration = %lld \n videoByte = %lld \n",self.videoWidth,self.videoHeight,self.videoFrameRate,self.videoOutputBitrate,(unsigned long)self.videoOrientation,self.videoDuration.value/self.videoDuration.timescale,self.videoByte];
    return descriptions;
}

@end
