//
//  LSAVSession.h
//  coreImg
//
//  Created by 王珑宾 on 2018/10/25.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSVideoPreview;
@interface LSAVSession : NSObject

+ (instancetype)sharedInstance;

- (void)startCaptureWithVideoPreview:(LSVideoPreview*)videoPreview;
//- (void)stopCapture;
- (void)startRecord;
- (void)stopRecord;

@end
