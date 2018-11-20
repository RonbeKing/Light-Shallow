//
//  LSVideoEditor.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/1.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSVideoEditor.h"
#import <AVKit/AVKit.h>

@interface LSVideoEditor ()

@property (nonatomic, strong) LSAVCommand* avCommand;

@end

@implementation LSVideoEditor

- (void)addMusicToAsset:(AVAsset *)asset completion:(void (^)(LSAVCommand *))block{
    LSAVAddMusicCommand* musicCommand = [[LSAVAddMusicCommand alloc] initWithComposition:self.avCommand.mutableComposition videoComposition:self.avCommand.mutableVideoComposition audioMix:self.avCommand.mutableAudioMix];
    [musicCommand performWithAsset:asset completion:^(LSAVCommand *avCommand) {
        self.avCommand = avCommand;
        if (block) {
            block(avCommand);
        }
    }];
}

- (void)addWatermark:(LSWatermarkType)watermarkType inAsset:(AVAsset *)asset completion:(void (^)(LSAVCommand *))block{
    LSAVAddWatermarkCommand* watermarkCommand = [[LSAVAddWatermarkCommand alloc] initWithComposition:self.avCommand.mutableComposition videoComposition:self.avCommand.mutableVideoComposition audioMix:self.avCommand.mutableAudioMix];
    [watermarkCommand performWithAsset:asset completion:^(LSAVCommand *avCommand) {
        self.avCommand = avCommand;
        if (block) {
            block(avCommand);
        }
    }];
}

- (void)exportAsset:(AVAsset*)asset{
    LSAVExportCommand* exportCommand = [[LSAVExportCommand alloc] initWithComposition:self.avCommand.mutableComposition videoComposition:self.avCommand.mutableVideoComposition audioMix:self.avCommand.mutableAudioMix];
    
    [exportCommand performWithAsset:asset completion:^(LSAVCommand *avCommand) {
        if (avCommand.executeStatus) {
            NSLog(@"export successfully");
        }else{
            NSLog(@"export fail");
        }
    }];
}

- (void)centerFrameImageWithAsset:(AVAsset*)asset completion:(void (^)(UIImage *image))completion {
    // AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CGFloat assetTimeLong = CMTimeGetSeconds(asset.duration);
    
    NSMutableArray* timeArr = [NSMutableArray array];
    for (float i = 0; i < assetTimeLong; i+=1) {
        CMTime midpoint = CMTimeMakeWithSeconds(i, 600);
        NSValue *midTime = [NSValue valueWithCMTime:midpoint];
        [timeArr addObject:midTime];
    }
    [imageGenerator generateCGImagesAsynchronouslyForTimes:timeArr completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded && image != NULL) {
            UIImage *centerFrameImage = [[UIImage alloc] initWithCGImage:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(centerFrameImage);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil);
                }
            });
        }
    }];
}

#pragma imageToVideo

-(void)composeVideoWithImages:(NSArray *)images{
    NSMutableArray* imageArr = [NSMutableArray array];
    for (UIImage* image in images) {
        UIImage* newImage = [self imageWithImage:image scaledToSize:CGSizeMake(480, 480)];
        [imageArr addObject:newImage];
    }
    //设置mov路径
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *moviePath =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",@"test"]];
    //self.theVideoPath=moviePath;
    
    //定义视频的大小320 480 倍数
    CGSize size =CGSizeMake(480,480);
    
    //        [selfwriteImages:imageArr ToMovieAtPath:moviePath withSize:sizeinDuration:4 byFPS:30];//第2中方法
    
    NSError *error =nil;
    //    转成UTF-8编码
    unlink([moviePath UTF8String]);
    NSLog(@"path->%@",moviePath);
    //     iphone提供了AVFoundation库来方便的操作多媒体设备，AVAssetWriter这个类可以方便的将图像和音频写成一个完整的视频文件
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:moviePath] fileType:AVFileTypeQuickTimeMovie error:&error];
    
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error =%@", [error localizedDescription]);
    //mov的格式设置 编码格式 宽度 高度
    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,
                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
    
    AVAssetWriterInput *writerInput =[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary*sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    //    AVAssetWriterInputPixelBufferAdaptor提供CVPixelBufferPool实例,
    //    可以使用分配像素缓冲区写入输出文件。使用提供的像素为缓冲池分配通常
    //    是更有效的比添加像素缓冲区分配使用一个单独的池
    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput]){
        [videoWriter addInput:writerInput];
    }
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
    int __block frame =0;
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        //写入时的逻辑：将数组中的每一张图片多次写入到buffer中，
        while([writerInput isReadyForMoreMediaData])
        {//数组中一共7张图片此时写入490次
            if(++frame >=[imageArr count]*imageArr.count*10)
            {
                [writerInput markAsFinished];
                [videoWriter finishWritingWithCompletionHandler:^{
                    NSLog(@"合成完成");
                }];
                break;
            }
            CVPixelBufferRef buffer =NULL;
            //每张图片写入70次换下一张
            int idx =frame/(imageArr.count*10);
            NSLog(@"idx==%d",idx);
            //将图片转成buffer
            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[imageArr objectAtIndex:idx] CGImage] size:size];
            
            if (buffer)
            {//添加buffer并设置每个buffer出现的时间，每个buffer的出现时间为第n张除以30（30是一秒30张图片，帧率，也可以自己设置其他值）所以为frame/30，即CMTimeMake(frame,30)为每一个buffer出现的时间点
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,30)])//设置每秒钟播放图片的个数
                {
                    NSLog(@"FAIL");
                }
                else
                {
                    NSLog(@"OK");
                }
                
                CFRelease(buffer);
            }
        }
    }];
}

-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    //    新创建的位图上下文 newSize为其大小
    UIGraphicsBeginImageContext(newSize);
    //    对图片进行尺寸的改变
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    //    从当前上下文中获取一个UIImage对象  即获取新的图片对象
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size {
    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer =NULL;
    CVReturn status =CVPixelBufferCreate(kCFAllocatorDefault,size.width,size.height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options,&pxbuffer);
    
    NSParameterAssert(status ==kCVReturnSuccess && pxbuffer !=NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    
    void *pxdata =CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata !=NULL);
    CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
    //    当你调用这个函数的时候，Quartz创建一个位图绘制环境，也就是位图上下文。当你向上下文中绘制信息时，Quartz把你要绘制的信息作为位图数据绘制到指定的内存块。一个新的位图上下文的像素格式由三个参数决定：每个组件的位数，颜色空间，alpha选项
    CGContextRef context =CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    //使用CGContextDrawImage绘制图片  这里设置不正确的话 会导致视频颠倒
    //    当通过CGContextDrawImage绘制图片到一个context中时，如果传入的是UIImage的CGImageRef，因为UIKit和CG坐标系y轴相反，所以图片绘制将会上下颠倒
    CGContextDrawImage(context,CGRectMake(0,0,CGImageGetWidth(image),CGImageGetHeight(image)), image);
    // 释放色彩空间
    CGColorSpaceRelease(rgbColorSpace);
    // 释放context
    CGContextRelease(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;
}
@end
