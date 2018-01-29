//
//  XCaptureController.m
//  CaptureDemo
//
//  Created by canoe on 2017/11/2.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "XCaptureController.h"
#import "LFGPUImageBeautyFilter.h"//美颜效果1  柔光磨皮
#import "GPUImageBeautifyFilter.h"//美颜效果2  提亮磨皮

/***  当前屏幕宽度 */
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
/***  当前屏幕高度 */
#define kScreenHeight  [[UIScreen mainScreen] bounds].size.height

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface XCaptureController ()<UIGestureRecognizerDelegate,GPUImageVideoCameraDelegate,GPUImageMovieWriterDelegate>

@property(nonatomic, strong) GPUImageStillCamera *videoCamera;//GPUImage输入源
@property (nonatomic, strong) GPUImageView *filterView; //显示的View
@property(nonatomic, strong) GPUImageFilterPipeline *pipeline;//当前正在使用的滤镜组
@property(nonatomic, strong) GPUImageMovieWriter *movieWriter;//视频录制
@property(nonatomic, strong) NSURL *outputUrl; //视频输出地址
@property (copy, nonatomic) NSString *cameraQuality;//拍摄质量
@property(nonatomic,assign) int mCount; //人脸识别间隔时长统计

//聚焦
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;//点击手势
@property (strong, nonatomic) CALayer *focusBoxLayer;//聚焦图层
@property (strong, nonatomic) CAAnimation *focusBoxAnimation;//聚焦动画

//缩放
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGesture;//放大缩小
@property (nonatomic, assign) CGFloat beginGestureScale;//原始放大倍数
@property (nonatomic, assign) CGFloat effectiveScale;//有效倍数

@property (nonatomic, copy) void (^didRecordCompletionBlock)(XCaptureController *camera, NSURL *outputFileUrl, NSError *error);//视频拍摄完成回调

@end

NSString *const XCameraErrorDomain = @"XCameraErrorDomain";

@implementation XCaptureController

#pragma mark - 默认配置

-(instancetype) init
{
    return [self initWithQuality:AVCaptureSessionPresetHigh];
}

-(instancetype) initWithQuality:(NSString *)quality
{
    return [self initWithQuality:quality position:XCapturePositionRear];
}

-(instancetype) initWithQuality:(NSString *)quality position:(XCapturePosition)position
{
    return [self initWithQuality:quality position:position enableRecording:NO];
}

-(instancetype) initWithQuality:(NSString *)quality position:(XCapturePosition)position enableRecording:(BOOL)recordingEnabled
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self setupWithQuality:quality position:position enableRecording:recordingEnabled];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupWithQuality:AVCaptureSessionPresetHigh
                      position:XCapturePositionRear
               enableRecording:NO];
    }
    return self;
}

-(void)setupWithQuality:(NSString *)quality position:(XCapturePosition)position enableRecording:(BOOL)recordingEnabled
{
    _cameraQuality = quality;
    _position = position;
    _recordingEnabled = recordingEnabled;
    _flash = XCaptureFlashOff;
    _whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
    _useDeviceOrientation = YES;
    _tapToFocus = NO;
    _recording = NO;
    _zoomingEnabled = NO;
    _effectiveScale = 1.0f;
    _openBeautyFilter = NO;
    _mCount = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    self.preview = [[UIView alloc] initWithFrame:CGRectZero];
    self.preview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.preview];
    
    //聚焦
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.delaysTouchesEnded = NO;//手势识别失败立即发送touchend结束触摸事件
    [self.preview addGestureRecognizer:self.tapGesture];
    
    //缩放
    if (_zoomingEnabled) {
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(previewPinned:)];
        self.pinchGesture.delegate = self;
        [self.preview addGestureRecognizer:self.pinchGesture];
    }
    
    //添加聚焦动画
    [self addDefaultFocusBox];
}

#pragma mark - 相机初始化
- (void)attachToViewController:(UIViewController *)vc withFrame:(CGRect)frame
{
    [vc addChildViewController:self];
    self.view.frame = frame;
    [vc.view addSubview:self.view];
    [self didMoveToParentViewController:vc];
}

- (void)start
{
    [XCaptureController requestCameraPermission:^(BOOL granted) {
        if (granted) {
            //如果是视频录制，额外需要麦克风权限  没有麦克风权限的话就没有声音
            if (self.recordingEnabled) {
                [XCaptureController requestMicrophonePermission:^(BOOL granted) {
                    if (granted) {
                        [self initialize];
                    }else
                    {
                        NSError *error = [NSError errorWithDomain:XCameraErrorDomain
                                                             code:XCameraErrorCodeCameraPermission
                                                         userInfo:nil];
                        [self passError:error];
                    }
                }];
            }else
            {
                [self initialize];
            }
        }else
        {
            NSError *error = [NSError errorWithDomain:XCameraErrorDomain
                                                 code:XCameraErrorCodeCameraPermission
                                             userInfo:nil];
            [self passError:error];
        }
    }];
}

//初始化
-(void)initialize
{
    if (!_videoCamera) {
        AVCaptureDevicePosition devicePosition;
        switch (self.position) {
            case XCapturePositionRear:
                if([self.class isRearCameraAvailable]) {
                    devicePosition = AVCaptureDevicePositionBack;
                } else {
                    devicePosition = AVCaptureDevicePositionFront;
                    _position = XCapturePositionFront;
                }
                break;
            case XCapturePositionFront:
                if([self.class isFrontCameraAvailable]) {
                    devicePosition = AVCaptureDevicePositionFront;
                } else {
                    devicePosition = AVCaptureDevicePositionBack;
                    _position = XCapturePositionRear;
                }
                break;
            default:
                devicePosition = AVCaptureDevicePositionUnspecified;
                break;
        }
        //初始化相机
        _videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:self.cameraQuality cameraPosition:devicePosition];
        _videoCamera.outputImageOrientation = (NSInteger)[self orientationForConnection];   //输出图片方向
        _videoCamera.horizontallyMirrorFrontFacingCamera = YES; //前置相机是否镜像
        
        //预览界面
        self.filterView = [[GPUImageView alloc] initWithFrame:self.preview.bounds];
        self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        [self.preview addSubview:self.filterView];
        
        //添加输入输出关系
        self.pipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:@[] input:_videoCamera output:self.filterView];
        //滤镜配置
        [self setupDefaultFilter];
        
        //添加音频输入
        if (self.isRecordingEnabled) {
            [_videoCamera addAudioInputsAndOutputs];
        }
        
        //设置默认的白平衡
        [self setWhiteBalanceMode:_whiteBalanceMode];
        
        //设置默认闪光灯
        [self updateFlashMode:_flash];
        
        //开启逐帧输出代理
        if (self.openFaceDetection) {
            _videoCamera.delegate = self;
        }
    }
    [self.videoCamera startCameraCapture];
}

- (void)stop
{
    [self.videoCamera stopCameraCapture];
}

#pragma mark - 人脸识别
-(void)setOpenFaceDetection:(BOOL)openFaceDetection
{
    _openFaceDetection = openFaceDetection;
    if (_videoCamera) {
        _videoCamera.delegate = openFaceDetection?self:nil;
    }
}

-(void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (!_openFaceDetection) {
        return;
    }
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    self.mCount++;
    if (self.mCount % 5 == 0) {
        //每隔5帧检测一次人脸
        dispatch_async(dispatch_get_main_queue(), ^{
            [self inputCIImageForDetector:image];
        });
        self.mCount = 0;
    }
}

//对输入的图片进行人脸检测
-(CIImage *)inputCIImageForDetector:(CIImage *)image{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow
                                                     forKey:CIDetectorAccuracy];
    CIDetector *detector=[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    //对图片进行修正
    //裁剪设置的区域
    CIImage * cropImage = [self cropImage:[self fixCIImageOrientation:image]];
    
    //人脸检测
    NSArray *faceArray = [detector featuresInImage:cropImage
                                           options:nil];
    
    //没有检测到人脸 返回
    if (!faceArray.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.faceDetectionDelegate respondsToSelector:@selector(faceDetectionSuccess:faceCount:)]) {
                [self.faceDetectionDelegate faceDetectionSuccess:NO faceCount:0];
            }
        });
        return image;
    }
    
    //有人脸
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.faceDetectionDelegate respondsToSelector:@selector(faceDetectionSuccess:faceCount:)]) {
            [self.faceDetectionDelegate faceDetectionSuccess:YES faceCount:faceArray.count];
        }
    });
    
    //只有一张人脸
    if (faceArray.count == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.faceDetectionDelegate respondsToSelector:@selector(faceDetectionSuccessWithImage:)]) {
                [self.faceDetectionDelegate faceDetectionSuccessWithImage:[self uiImageConvertFromCIImage:cropImage]];
            }
        });
    }
    return image;
}


-(CIImage *)fixCIImageOrientation:(CIImage *)ciImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if (self.videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
        transform = CGAffineTransformScale(transform, -1, 1);
        transform = CGAffineTransformTranslate(transform, -ciImage.extent.size.height, 0);
    }
    transform = CGAffineTransformTranslate(transform, 0, ciImage.extent.size.width);
    transform = CGAffineTransformRotate(transform, -M_PI_2);
    
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, ciImage.extent.size.height, ciImage.extent.size.width,
                                             CGImageGetBitsPerComponent(cgImage), 0,
                                             CGImageGetColorSpace(cgImage),
                                             CGImageGetBitmapInfo(cgImage));
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, CGRectMake(0,0,ciImage.extent.size.width,ciImage.extent.size.height), cgImage);
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    CIImage *resultImage = [CIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    CGImageRelease(cgImage);
    return resultImage;
}


-(UIImage *)uiImageConvertFromCIImage:(CIImage *)ciImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:[ciImage extent]];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return image;
}

-(CIImage *)cropImage:(CIImage *)image
{
    if (CGRectEqualToRect(self.detectionRect, CGRectZero)) {
        return image;
    }

    float scaleWidth = image.extent.size.width/self.view.frame.size.width;
    float scaleHeight = image.extent.size.height/(self.view.frame.size.width * kScreenHeight/kScreenWidth);

    CGRect newRect = CGRectZero;
    newRect.origin.x = self.detectionRect.origin.x * scaleWidth;
    newRect.origin.y = self.detectionRect.origin.y * scaleHeight;
    newRect.size.width = self.detectionRect.size.width * scaleWidth;
    newRect.size.height = self.detectionRect.size.height * scaleHeight;

    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef ref = [context createCGImage:image fromRect:newRect];
    CIImage *resultImage = [[CIImage alloc] initWithCGImage:ref];
    CGImageRelease(ref);
    return resultImage;
}


#pragma mark - 滤镜
-(void)setupDefaultFilter
{
    NSMutableArray *arrayM = [NSMutableArray array];
    if (_openBeautyFilter) {
        LFGPUImageBeautyFilter *filter = [[LFGPUImageBeautyFilter alloc] init];
        [arrayM addObject:filter];
    }else
    {
        GPUImageFilter *filter = [[GPUImageFilter alloc] init];
        [arrayM addObject:filter];
    }
    //如果存在定义的滤镜，叠加效果
    if (_filters) {
        [arrayM addObject:_filters];
    }
    [self.pipeline replaceAllFilters:arrayM];
}

-(void)setOpenBeautyFilter:(BOOL)openBeautyFilter
{
    _openBeautyFilter = openBeautyFilter;
    if (_videoCamera) {
        [self setupDefaultFilter];
    }
}

-(void)setFilters:(GPUImageOutput<GPUImageInput> *)filters
{
    _filters = filters;
    if (_videoCamera) {
        [self setupDefaultFilter];
    }
}

#pragma mark - 拍照
-(void)capture:(void (^)(XCaptureController *capture,UIImage *image, NSError *error))onCapture animationBlock:(void (^)(void))animationBlock
{
    if (!self.videoCamera.captureSession) {
        NSError *error = [NSError errorWithDomain:XCameraErrorDomain code:XCameraErrorCodeSession userInfo:nil];
        onCapture(self,nil,error);
        return;
    }
    
    self.videoCamera.outputImageOrientation = (NSInteger)[self orientationForConnection];
    
    BOOL flashActive =  self.videoCamera.inputCamera.flashActive;
    if (!flashActive && animationBlock) {
        animationBlock();
    }
    
    [self.videoCamera capturePhotoAsImageProcessedUpToFilter:[self.pipeline.filters lastObject] withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if (onCapture) {
            dispatch_async(dispatch_get_main_queue(), ^{
                onCapture(self,processedImage,error);
            });
        }
    }];
}

-(void)capture:(void (^)(XCaptureController *camera, UIImage *image, NSError *error))onCapture
{
    [self capture:onCapture animationBlock:^{
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.duration = 0.1;
        animation.autoreverses = YES;
        animation.repeatCount = 0.0;
        animation.fromValue = [NSNumber numberWithFloat:1.0];
        animation.toValue = [NSNumber numberWithFloat:0.1];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [self.preview.layer addAnimation:animation forKey:@"animateOpacity"];
    }];
}


#pragma mark - 录制视频
- (void)startRecordingWithOutputUrl:(NSURL *)url didRecord:(void (^)(XCaptureController *, NSURL *, NSError *))completionBlock
{
    if (!self.recordingEnabled) {
        NSError *error = [NSError errorWithDomain:XCameraErrorDomain code:XCameraErrorCodeVideoNotEnabled userInfo:nil];
        [self passError:error];
        return;
    }
    
    if (self.flash == XCaptureFlashOn) {
        //开启手电筒
        [self enableTorch:YES];
    }
    
    self.videoCamera.outputImageOrientation = (NSInteger)[self orientationForConnection];
    
    self.didRecordCompletionBlock = completionBlock;
    
    self.outputUrl = url;
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:CGSizeMake(480, 640)];
    self.movieWriter.encodingLiveVideo = YES;
    [[self.pipeline.filters lastObject] addTarget:self.movieWriter];
    self.videoCamera.audioEncodingTarget = self.movieWriter;
    [self.movieWriter startRecording];
    self.recording = YES;
}

-(void)stopRecording
{
    if (!self.recordingEnabled) {
        return;
    }
    
    self.recording = NO;
    [[self.pipeline.filters lastObject] removeTarget:self.movieWriter];
    self.videoCamera.audioEncodingTarget = nil;
    [self.movieWriter finishRecording];
}

-(void)movieRecordingCompleted
{
    self.recording = NO;
    [self enableTorch:NO];
    [[self.pipeline.filters lastObject] removeTarget:self.movieWriter];
    self.videoCamera.audioEncodingTarget = nil;
    [self.movieWriter finishRecording];
    
    if (self.didRecordCompletionBlock) {
        self.didRecordCompletionBlock(self, self.outputUrl, nil);
    }
}

-(void)movieRecordingFailedWithError:(NSError *)error
{
    self.recording = NO;
    [self enableTorch:NO];
    [[self.pipeline.filters lastObject] removeTarget:self.movieWriter];
    self.videoCamera.audioEncodingTarget = nil;
    [self.movieWriter finishRecording];
    
    if (self.didRecordCompletionBlock) {
        self.didRecordCompletionBlock(self, self.outputUrl, error);
    }
}


#pragma mark - 双指缩放
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        _beginGestureScale = _effectiveScale;
    }
    return YES;
}

- (void)previewPinned:(UIPinchGestureRecognizer *)recognizer
{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.preview];
        CGPoint convertedLocation = [self.preview.layer convertPoint:location fromLayer:self.view.layer];
        if ( ! [self.preview.layer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if (allTouchesAreOnThePreviewLayer) {
        _effectiveScale = _beginGestureScale * recognizer.scale;
        if (_effectiveScale < 1.0f)
            _effectiveScale = 1.0f;
        if (_effectiveScale > self.videoCamera.inputCamera.activeFormat.videoMaxZoomFactor)
            _effectiveScale = self.videoCamera.inputCamera.activeFormat.videoMaxZoomFactor;
        
        [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
            [self.videoCamera.inputCamera rampToVideoZoomFactor:_effectiveScale withRate:100];
        }];
    }
}

#pragma mark - 聚焦
- (void)addDefaultFocusBox
{
    CALayer *focusBox = [[CALayer alloc] init];
    focusBox.cornerRadius = 5.0f;
    focusBox.bounds = CGRectMake(0.0f, 0.0f, 70, 60);
    focusBox.borderWidth = 3.0f;
    focusBox.borderColor = [[UIColor yellowColor] CGColor];
    focusBox.opacity = 0.0f;
    [self.view.layer addSublayer:focusBox];
    
    CABasicAnimation *focusBoxAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    focusBoxAnimation.duration = 0.75;
    focusBoxAnimation.autoreverses = NO;
    focusBoxAnimation.repeatCount = 0.0;
    focusBoxAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    focusBoxAnimation.toValue = [NSNumber numberWithFloat:0.0];
    
    [self clickFocusBox:focusBox animation:focusBoxAnimation];
}

-(void)clickFocusBox:(CALayer *)layer animation:(CAAnimation *)animation
{
    self.focusBoxLayer = layer;
    self.focusBoxAnimation = animation;
}

- (void)previewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if(!self.tapToFocus) {
        return;
    }
    CGPoint touchedPoint = [gestureRecognizer locationInView:self.preview];
    [self showFocusBox:touchedPoint];
    //这里需要自己做映射，将点击的点坐标映射到相机坐标中
    if(self.videoCamera.cameraPosition == AVCaptureDevicePositionBack){
        touchedPoint = CGPointMake(touchedPoint.y /gestureRecognizer.view.bounds.size.height ,1-touchedPoint.x/gestureRecognizer.view.bounds.size.width);
    }else
        touchedPoint = CGPointMake(touchedPoint.y /gestureRecognizer.view.bounds.size.height ,touchedPoint.x/gestureRecognizer.view.bounds.size.width);
    
    [self focusAtPoint:touchedPoint];
}

//更改聚焦状态
- (void)focusAtPoint:(CGPoint)point
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if (captureDevice.isFocusPointOfInterestSupported && [captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            captureDevice.focusPointOfInterest = point;
            captureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
    }];
}

//显示聚焦动画
- (void)showFocusBox:(CGPoint)point
{
    if(self.focusBoxLayer) {
        // clear animations
        [self.focusBoxLayer removeAllAnimations];
        
        // move layer to the touch point
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        self.focusBoxLayer.position = point;
        [CATransaction commit];
    }
    
    if(self.focusBoxAnimation) {
        // run the animation
        [self.focusBoxLayer addAnimation:self.focusBoxAnimation forKey:@"animateOpacity"];
    }
}

#pragma mark - 白平衡

-(void)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
    if ([self.videoCamera.inputCamera isWhiteBalanceModeSupported:whiteBalanceMode]) {
        [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
            [self.videoCamera.inputCamera setWhiteBalanceMode:whiteBalanceMode];
        }];
    }
}

#pragma mark - 摄像头转换
- (void)setCameraPosition:(XCapturePosition)cameraPosition
{
    if (_position == cameraPosition || !self.videoCamera.captureSession) {
        return;
    }
    
    if(cameraPosition == XCapturePositionRear && ![self.class isRearCameraAvailable]) {
        return;
    }
    
    if(cameraPosition == XCapturePositionFront && ![self.class isFrontCameraAvailable]) {
        return;
    }
    [self.videoCamera stopCameraCapture];
    self.videoCamera = nil;
    _position = cameraPosition;
    
    [self initialize];
}

- (XCapturePosition)changePosition
{
    if (!self.videoCamera.inputCamera) {
        return self.position;
    }
    
    if (self.position == XCapturePositionFront) {
        self.cameraPosition = XCapturePositionRear;
    }else
    {
        self.cameraPosition = XCapturePositionFront;
    }
    
    return self.position;
}

#pragma mark - 闪光灯
-(BOOL)isFlashAvailable
{
    return self.videoCamera.inputCamera.hasFlash && self.videoCamera.inputCamera.isFlashAvailable;
}

//更新闪光灯模式
- (BOOL)updateFlashMode:(XCaptureFlash)cameraFlash
{
    if (!self.videoCamera.captureSession)
        return NO;
    
    AVCaptureFlashMode flashMode;
    
    if (cameraFlash == XCaptureFlashOn) {
        flashMode = AVCaptureFlashModeOn;
    }else if (cameraFlash == XCaptureFlashAuto)
    {
        flashMode = AVCaptureFlashModeAuto;
    }else
    {
        flashMode = AVCaptureFlashModeOff;
    }
    
    if ([self.videoCamera.inputCamera isFlashModeSupported:flashMode]) {
        NSError *error;
        if([self.videoCamera.inputCamera lockForConfiguration:&error]) {
            self.videoCamera.inputCamera.flashMode = flashMode;
            [self.videoCamera.inputCamera unlockForConfiguration];
            _flash = cameraFlash;
            return YES;
        } else {
            [self passError:error];
            return NO;
        }
    }else{
        return NO;
    }
}

-(BOOL)isTorchAvailable
{
    return self.videoCamera.inputCamera.hasTorch && self.videoCamera.inputCamera.isTorchAvailable;
}

- (void)enableTorch:(BOOL)enabled
{
    if([self isTorchAvailable]) {
        AVCaptureTorchMode torchMode = enabled ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
            [self.videoCamera.inputCamera setTorchMode:torchMode];
        }];
    }
}


#pragma mark - other

- (void)passError:(NSError *)error
{
    if(self.onError) {
        __weak typeof(self) weakSelf = self;
        self.onError(weakSelf, error);
    }
}

/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= self.videoCamera.inputCamera;
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        [self passError:error];
    }
}

//返回一个指定的相机设备
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) return device;
    }
    return nil;
}

#pragma mark - Controller
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    CGRect bounds = self.preview.bounds;
    self.filterView.bounds = bounds;
}

- (AVCaptureVideoOrientation)orientationForConnection
{
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    
    if(self.useDeviceOrientation) {
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationLandscapeLeft:
                // yes to the right, this is not bug!
                videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
    }
    else {
        switch ([[UIApplication sharedApplication] statusBarOrientation]) {
            case UIInterfaceOrientationLandscapeLeft:
                videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeRight:
                videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
    }
    
    return videoOrientation;
}

//旋转的时候重新布局
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // layout subviews is not called when rotating from landscape right/left to left/right
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self.view setNeedsLayout];
    }
}

- (void)dealloc {
    [self stop];
}

#pragma mark - Premission
+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock
{
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            // return to main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock) {
                    completionBlock(granted);
                }
            });
        }];
    } else {
        completionBlock(YES);
    }
}

+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock
{
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            // return to main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock) {
                    completionBlock(granted);
                }
            });
        }];
    }
}

+ (BOOL)isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

+ (BOOL)isRearCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
