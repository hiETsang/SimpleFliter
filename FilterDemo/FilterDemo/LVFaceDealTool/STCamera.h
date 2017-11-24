//
//  STCamera.h
//
//  Created by sluin on 16/5/4.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//相机

@protocol STCameraDelegate <NSObject>

// call back in bufferQueue
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end

@interface STCamera : NSObject

@property (nonatomic , assign) id <STCameraDelegate> delegate;

@property (nonatomic , readonly) dispatch_queue_t bufferQueue;

//摄像头位置  默认前置
@property (nonatomic , assign) AVCaptureDevicePosition devicePosition; // default AVCaptureDevicePositionFront

//视频方向
@property (nonatomic , assign) AVCaptureVideoOrientation videoOrientation;

@property (nonatomic , assign) BOOL needVideoMirrored;

@property (nonatomic , strong , readonly) AVCaptureConnection *videoConnection;

@property (nonatomic , copy) NSString *sessionPreset;  // default AVCaptureSessionPreset1280x720

@property (nonatomic , strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic , assign) BOOL bOutputYUV; // default YES  ship格式是否是YUV格式

@property (nonatomic , assign) BOOL bSessionPause;

@property (nonatomic , assign) int iFPS;//帧数  默认25

@property (nonatomic, readwrite, strong) NSDictionary *videoCompressingSettings;

- (void)startRunning;

- (void)stopRunning;

- (void)snapStillImageCompletionHandler:(void (^)(CMSampleBufferRef imageDataSampleBuffer, NSError *error))handler;

- (CGRect)getZoomedRectWithRect:(CGRect)rect scaleToFit:(BOOL)bScaleToFit;

@end
