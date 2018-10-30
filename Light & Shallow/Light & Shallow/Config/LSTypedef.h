//
//  LSTypedef.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/25.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef LSTypedef_h
#define LSTypedef_h

typedef NS_ENUM(NSUInteger, LSWatermarkType)
{
    /* Use pictures as watermarks. */
    LSWatermarkTypeImage = 0,
    /* Use text as watermarks. */
    LSWatermarkTypeText = 1
};

typedef NS_ENUM(NSUInteger, LSVideoCodec)
{
    /* Stable, software VP8 encode & decode via libvpx */
    LSVideoCodecVP8 = 0,
    /* Experimental, hardware H.264 encode & decode via VideoToolbox. */
    LSVideoCodecH264 = 1
};

typedef NS_ENUM(NSUInteger, LSAudioCodec)
{
    /* The Opus audio codec is wideband, and higher quality. */
    LSAudioCodecOpus = 0,
    /* ISAC is lower quality, but more compatible. */
    LSAudioCodecISAC = 1
};

#endif /* LSTypedef_h */
