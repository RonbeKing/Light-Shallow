//
//  LSVideoPreview.h
//  coreImg
//
//  Created by 王珑宾 on 2018/10/11.
//  Copyright © 2018年 Ronb X. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^FocusBlock) (CGPoint point);
typedef void (^ExposureBlock) (CGPoint point);

@interface LSVideoPreview : UIView
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) id imageContents;
@property (nonatomic,   copy) FocusBlock focusBlock;
@property (nonatomic,   copy) ExposureBlock exposureBlock;
@end
