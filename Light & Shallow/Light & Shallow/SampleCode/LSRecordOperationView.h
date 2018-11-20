//
//  LSRecordOperationView.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/20.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BeginRecord)(void);
typedef void(^EndRecord)(void);
typedef void(^FlipCamera)(void);
typedef void(^AjustCanvas)(LSCanvasRatio canvasRatio);
typedef void(^ChangeTorchMode)(void);
typedef void(^ChangeFilter)(int tag);

@interface LSRecordOperationView : UIView
@property (nonatomic, copy) BeginRecord beginRecordBlock;
@property (nonatomic, copy) EndRecord endRecordBlock;
@property (nonatomic, copy) FlipCamera flipCameraBlock;
@property (nonatomic, copy) AjustCanvas ajustCanvasBlock;
@property (nonatomic, copy) ChangeTorchMode changeTorchModeBlock;
@property (nonatomic, copy) ChangeFilter changeFilterBlock;
@end
