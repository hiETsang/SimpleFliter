//
//  STCamera.m
//
//  Created by sluin on 16/5/4.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

#import "STCamera.h"
#import "STMobileLog.h"
#import <UIKit/UIKit.h>

@interface STCamera () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic , strong) AVCaptureDeviceInput * deviceInput;//设备输入
@property (nonatomic , strong) AVCaptureVideoDataOutput * dataOutput;//视频输出
@property (nonatomic , strong) AVCaptureStillImageOutput *stillImageOutput;//图片输出

@property (nonatomic , strong) AVCaptureSession *session;
@property (nonatomic , strong) AVCaptureDevice *videoDevice;//设备

@property (nonatomic , readwrite) dispatch_queue_t bufferQueue;

@property (nonatomic , strong , readwrite) AVCaptureConnection *videoConnection;


@end

@implementation STCamera

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setupCaptureSession];
    }
    return self;
}

- (void)dealloc
{
    if (self.session) {
        
        self.bSessionPause = YES;
        
        [self.session beginConfiguration];
        
        [self.session removeOutput:self.dataOutput];
        [self.session removeInput:self.deviceInput];
        
        [self.session commitConfiguration];
        
        if ([self.session isRunning]) {
            
            [self.session stopRunning];
        }
        
        self.session = nil;
    }
}

- (void)setupCaptureSession
{
    self.bSessionPause = YES;
    
    dispatch_queue_t bufferQueue = dispatch_queue_create("STCameraBufferQueue", NULL);
    self.bufferQueue = bufferQueue;
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    
    self.videoDevice = [self cameraDeviceWithPosition:AVCaptureDevicePositionFront];
    _devicePosition = AVCaptureDevicePositionFront;
    
    NSError *error = nil;
    
    // todo camera auth check
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
    
    self.deviceInput = deviceInput;
    
    if (!deviceInput) {
        
        STLog(@"create input error");
        
        return;
    }
    
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    self.dataOutput = dataOutput;
    
    // 指定接收器是否应该永远放弃拍摄下一帧之前没有处理的任何视频帧。
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    //默认输出YUV格式
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    _bOutputYUV = YES;
    
    [dataOutput setSampleBufferDelegate:self queue:self.bufferQueue];
    
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    [session beginConfiguration];
    
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        
        [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
        
        _sessionPreset = AVCaptureSessionPreset1280x720;
    }
    
    if ([self.session canAddOutput:stillImageOutput]) {
        
        [self.session addOutput:stillImageOutput];
        self.stillImageOutput = stillImageOutput;
        self.stillImageOutput.outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG };
        if ([self.stillImageOutput respondsToSelector:@selector(setHighResolutionStillImageOutputEnabled:)]) {
            //是否在设备支持条件下输出质量最高的图片
            self.stillImageOutput.highResolutionStillImageOutputEnabled = YES;
        }
    }else {
        
        STLog( @"Could not add still image output to the session" );
    }
    
    if ([session canAddOutput:dataOutput]) {
        
        [session addOutput:dataOutput];
    }else{
        
        STLog( @"Could not add video data output to the session" );
    }
    
    if ([session canAddInput:deviceInput]) {
        
        [session addInput:deviceInput];
    }else{
        
        STLog( @"Could not add device input to the session" );
    }
    
    [self setIFPS:25];
    
    self.videoConnection =  [self.dataOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([self.videoConnection isVideoOrientationSupported]) {
        
        [self.videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        self.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    if ([self.videoConnection isVideoMirroringSupported]) {
        
        [self.videoConnection setVideoMirrored:YES];
        self.needVideoMirrored = YES;
    }
    
    [session commitConfiguration];
    
    //系统提供的编码配置
    self.videoCompressingSettings = [[_dataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie] copy];
}

- (void)setBOutputYUV:(BOOL)bOutputYUV
{
    if (_bOutputYUV != bOutputYUV) {
        
        _bOutputYUV = bOutputYUV;
        //kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange = '420v'，表示输出的视频格式为NV12；范围： (luma=[16,235] chroma=[16,240])
        //kCVPixelFormatType_420YpCbCr8BiPlanarFullRange = '420f'，表示输出的视频格式为NV12；范围： (luma=[0,255] chroma=[1,255])
        //kCVPixelFormatType_32BGRA = 'BGRA', 输出的是BGRA的格式

        int iCVPixelFormatType = bOutputYUV ? kCVPixelFormatType_420YpCbCr8BiPlanarFullRange : kCVPixelFormatType_32BGRA;
        
        
        AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        //默认丢掉之前的帧获取新的帧
        [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
        
        [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:iCVPixelFormatType] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        
        [dataOutput setSampleBufferDelegate:self queue:_bufferQueue];
        
        _bSessionPause = YES;
        
        [_session beginConfiguration];
        //弃掉初始的数据输出
        [_session removeOutput:_dataOutput];
        
        if ([_session canAddOutput:dataOutput]) {
            
            [_session addOutput:dataOutput];
            _dataOutput = dataOutput;
        }else{
            
            STLog(@"session add data output failed when change output buffer pixel format.");
        }
        
        [_session commitConfiguration];
        
        _videoConnection =  [_dataOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([_videoConnection isVideoOrientationSupported]) {
            
            [_videoConnection setVideoOrientation:_videoOrientation];
        }
        
        if ([_videoConnection isVideoMirroringSupported]) {
            
            [_videoConnection setVideoMirrored:_needVideoMirrored];
        }
        
        _bSessionPause = NO;
    }
}

//切换摄像头
- (void)setDevicePosition:(AVCaptureDevicePosition)devicePosition
{
    if (_devicePosition != devicePosition && devicePosition != AVCaptureDevicePositionUnspecified) {
        
        if (_session) {
            
            AVCaptureDevice *targetDevice = [self cameraDeviceWithPosition:devicePosition];
            
            if (targetDevice && [self judgeCameraAuthorization]) {
                
                NSError *error = nil;
                AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:targetDevice error:&error];
                
                if(!deviceInput || error) {
                    
                    STLog(@"Error creating capture device input: %@", error.localizedDescription);
                    return;
                }
                
                _bSessionPause = YES;
                
                [_session beginConfiguration];
                
                [_session removeInput:_deviceInput];
                
                if ([_session canAddInput:deviceInput]) {
                    
                    [_session addInput:deviceInput];
                    
                    _deviceInput = deviceInput;
                    _videoDevice = targetDevice;
                    
                    _devicePosition = devicePosition;
                }
                
                _videoConnection =  [_dataOutput connectionWithMediaType:AVMediaTypeVideo];
                
                if ([_videoConnection isVideoOrientationSupported]) {
                    
                    [_videoConnection setVideoOrientation:_videoOrientation];
                }
                
                if ([_videoConnection isVideoMirroringSupported]) {
                    
                    [_videoConnection setVideoMirrored:devicePosition == AVCaptureDevicePositionFront];
                    
                }
                                
                [_session commitConfiguration];
                
                _bSessionPause = NO;
            }
        }
    }
}

//设置会话的图像质量
- (void)setSessionPreset:(NSString *)sessionPreset
{
    if (_session && _sessionPreset) {
        
//        if (![sessionPreset isEqualToString:_sessionPreset]) {
        
        _bSessionPause = YES;
        
        [_session beginConfiguration];
        
        if ([_session canSetSessionPreset:sessionPreset]) {
            
            [_session setSessionPreset:sessionPreset];
            
            _sessionPreset = sessionPreset;
        }
        
        // todo max frame rate.
        if (_iFPS > 0) {
            
            CMTime frameDuration = CMTimeMake(1 , _iFPS);
            
            if ([_videoDevice lockForConfiguration:nil]) {
                
                _videoDevice.activeVideoMaxFrameDuration = frameDuration;
                _videoDevice.activeVideoMinFrameDuration = frameDuration;
                
                [_videoDevice unlockForConfiguration];
            }
        }
        
        [_session commitConfiguration];
        
        self.videoCompressingSettings = [[self.dataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie] copy];
        
        _bSessionPause = NO;
//        }
    }
}

- (void)setIFPS:(int)iFPS
{
    // todo max frame rate.
    if (iFPS > 0) {
     
        CMTime frameDuration = CMTimeMake(1 , iFPS);
        
        [_session beginConfiguration];
        
        if ([_videoDevice lockForConfiguration:nil]) {
            
            _videoDevice.activeVideoMaxFrameDuration = frameDuration;
            _videoDevice.activeVideoMinFrameDuration = frameDuration;
            
            [_videoDevice unlockForConfiguration];
        }
        
        [_session commitConfiguration];
        
        _iFPS = iFPS;
    }
}

- (void)startRunning
{
    if (![self judgeCameraAuthorization]) {
        
        return;
    }
    
    if (!self.dataOutput) {
        
        return;
    }
    
    if (self.session && ![self.session isRunning]) {
        
        [self.session startRunning];
        self.bSessionPause = NO;
    }
}


- (void)stopRunning
{
    if (self.session && [self.session isRunning]) {
        
        [self.session stopRunning];
        self.bSessionPause = YES;
    }
}

//获取缩小后的尺寸 是否需要缩放来填充
- (CGRect)getZoomedRectWithRect:(CGRect)rect scaleToFit:(BOOL)bScaleToFit
{
    CGRect rectRet = rect;
    
    if (self.dataOutput.videoSettings) {
        
        CGFloat fWidth = [[self.dataOutput.videoSettings objectForKey:@"Width"] floatValue];
        CGFloat fHeight = [[self.dataOutput.videoSettings objectForKey:@"Height"] floatValue];
        
        float fScaleX = fWidth / CGRectGetWidth(rect);
        float fScaleY = fHeight / CGRectGetHeight(rect);
        //如果比例填充 取比例大的  否则取比例小的
        float fScale = bScaleToFit ? fmaxf(fScaleX, fScaleY) : fminf(fScaleX, fScaleY);
        
        fWidth /= fScale;
        fHeight /= fScale;
        
        CGFloat fX = rect.origin.x - (fWidth - rect.size.width) / 2.0f;
        CGFloat fY = rect.origin.y - (fHeight - rect.size.height) / 2.0f;
        
        rectRet = CGRectMake(fX, fY, fWidth, fHeight);
    }
    
    return rectRet;
}

- (BOOL)judgeCameraAuthorization
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请打开相机权限" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return NO;
    }
    
    return YES;
}

- (AVCaptureDevice *)cameraDeviceWithPosition:(AVCaptureDevicePosition)position
{
    AVCaptureDevice *deviceRet = nil;
    
    if (position != AVCaptureDevicePositionUnspecified) {
        
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        for (AVCaptureDevice *device in devices) {
            
            if ([device position] == position) {
                
                deviceRet = device;
            }
        }
    }
    
    return deviceRet;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (!_previewLayer) {
        
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    }
    
    return _previewLayer;
}

//拍照方法
- (void)snapStillImageCompletionHandler:(void (^)(CMSampleBufferRef imageDataSampleBuffer, NSError *error))handler
{
    if ([self judgeCameraAuthorization]) {
        self.bSessionPause = YES;
        
        NSString *strSessionPreset = [self.sessionPreset mutableCopy];
        self.sessionPreset = AVCaptureSessionPresetPhoto;
        
        // 改变preset会黑一下
        [NSThread sleepForTimeInterval:0.3];
        
        dispatch_async(self.bufferQueue, ^{
            
            [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                
                self.bSessionPause = NO;
                self.sessionPreset = strSessionPreset;
                handler(imageDataSampleBuffer , error);
            }];
        } );
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (!self.bSessionPause) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutput:didOutputSampleBuffer:fromConnection:)]) {
            //[connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            [self.delegate captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
        }
    }
}

@end
