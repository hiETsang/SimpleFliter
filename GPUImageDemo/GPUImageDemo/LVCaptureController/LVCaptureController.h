//
//  LVCaptureController.h
//  CaptureDemo
//
//  Created by canoe on 2017/11/2.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"

//摄像头
typedef NS_ENUM(NSUInteger, LVCapturePosition) {
    LVCapturePositionRear,  //后置
    LVCapturePositionFront  //前置
};

//闪光灯
typedef NS_ENUM(NSUInteger, LVCaptureFlash) {
    LVCaptureFlashOff,
    LVCaptureFlashOn,
    LVCaptureFlashAuto,
};

//镜像
typedef NS_ENUM(NSUInteger, LVCaptureMirror) {
    LVCaptureMirrorOff,
    LVCaptureMirrorOn,
    LVCaptureMirrorAuto,
};

//错误信息
extern NSString *const LVCameraErrorDomain;
typedef enum : NSUInteger {
    LVCameraErrorCodeCameraPermission = 10, //相机权限错误
    LVCameraErrorCodeMicrophonePermission = 11, //麦克风权限错误
    LVCameraErrorCodeSession = 12, //会话错误
    LVCameraErrorCodeVideoNotEnabled = 13 //不允许录制
} LVSimpleCameraErrorCode;

#pragma mark - 人脸识别代理
@protocol XFaceDetectionDelegate<NSObject>

/**
 @param hasFace 是否有人脸
 @param faceCount 人脸张数
 */
-(void)faceDetectionSuccess:(BOOL)hasFace faceCount:(NSUInteger)faceCount;


/**
 在检测的范围内只有一张人脸时返回 如果openDetection==NO返回所有的图片
 @param image 人脸图片，如果detectionRect有值，那么裁剪该区域（返回的图片都是没有滤镜和美颜的原图）
 */
-(void)faceDetectionSuccessWithImage:(UIImage *)image;
@end





@interface LVCaptureController : UIViewController

#pragma mark - 初始化

/**
 初始化函数
 @param quality 输出图片质量
 @param position 摄像头位置   默认后置
 @param recordingEnabled 是否需要录像     默认不需要
 @return LVCaptureController
 */
-(instancetype) initWithQuality:(NSString *)quality position:(LVCapturePosition)position enableRecording:(BOOL)recordingEnabled;

-(instancetype) initWithQuality:(NSString *)quality position:(LVCapturePosition)position;

-(instancetype) initWithQuality:(NSString *)quality;

/**
 设置预览图层的位置
 
 @param vc 展示的VC
 @param frame 位置区域
 */
- (void)attachToViewController:(UIViewController *)vc withFrame:(CGRect)frame;

//开始会话
-(void)start;

//停止会话
-(void)stop;

#pragma mark - 相机配置

/**
 返回错误信息
 */
@property (nonatomic, copy) void (^onError)(LVCaptureController *camera, NSError *error);

//预览界面
@property (strong, nonatomic) UIView *preview;

//白平衡模式    Default: AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance 持续对焦中心点设置白平衡
@property (nonatomic) AVCaptureWhiteBalanceMode whiteBalanceMode;

//摄像头       Default：LVCapturePositionRear   默认后置
@property (nonatomic ,assign) LVCapturePosition position;

//闪光灯       Default：LVCaptureFlashOff  默认关闭
@property (nonatomic ,readonly) LVCaptureFlash flash;

//是否允许缩放 Default：NO
@property (nonatomic ,assign ,getter=isZoomingEnabled) BOOL zoomingEnabled;

//点击聚焦    Default：NO
@property (nonatomic ,assign) BOOL tapToFocus;

//是否使用设备的方向 Default：YES
@property (nonatomic) BOOL useDeviceOrientation;

/**
 切换摄像头
 @return 当前摄像头
 */
-(LVCapturePosition)changePosition;

//更新闪光灯模式
- (BOOL)updateFlashMode:(LVCaptureFlash)cameraFlash;

//点击聚焦图层和聚焦动画
-(void)clickFocusBox:(CALayer *)layer animation:(CAAnimation *)animation;

#pragma mark - 拍照

/**
 拍照

 @param onCapture 返回图片或者错误信息
 @param animationBlock 自定义动画
 */
-(void)capture:(void (^)(LVCaptureController *capture,UIImage *image, NSError *error))onCapture animationBlock:(void (^)(void))animationBlock;
-(void)capture:(void (^)(LVCaptureController *camera, UIImage *image, NSError *error))onCapture;

#pragma mark - 视频

//是否可以录制
@property (nonatomic ,assign ,getter=isRecordingEnabled) BOOL recordingEnabled;

//是否正在录制视频
@property (nonatomic ,assign ,getter=isRecording) BOOL recording;

/**
 视频录制

 @param url 视频存储的URL
 @param completionBlock 返回视频路径
 */
- (void)startRecordingWithOutputUrl:(NSURL *)url didRecord:(void (^)(LVCaptureController *camera, NSURL *outputFileUrl, NSError *error))completionBlock;

//停止录制
- (void)stopRecording;

#pragma mark - 人脸识别 -
@property(nonatomic, assign) BOOL openFaceDetection;    //是否打开人脸识别，默认关闭
@property(nonatomic,weak) id<XFaceDetectionDelegate> faceDetectionDelegate;
@property(nonatomic) CGRect detectionRect;              //需要人脸检测的范围，默认全屏

#pragma mark - 美颜滤镜 -
//传入滤镜后，如果开启美颜，会在美颜效果上加上传入的滤镜效果
@property(nonatomic, assign) BOOL openBeautyFilter;     //是否开启美颜功能  默认 NO  (内部提供两种美颜效果，可以根据需要选择)
@property(nonatomic, strong) GPUImageOutput<GPUImageInput> *filters;//单个滤镜或者滤镜组

#pragma mark - 权限 -

//闪光灯是否可用
- (BOOL)isFlashAvailable;

//手电筒是否可用
- (BOOL)isTorchAvailable;

/**
 *  请求相机权限
 */
+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock;

/**
 *  请求麦克风权限
 */
+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock;

/**
 *  前置摄像头是否可用
 */
+ (BOOL)isFrontCameraAvailable;

/**
 *  后置摄像头是否可用
 */
+ (BOOL)isRearCameraAvailable;

@end
