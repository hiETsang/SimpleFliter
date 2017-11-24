//
//  LVCaptureController.h
//  CaptureDemo
//
//  Created by canoe on 2017/11/2.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

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

extern NSString *const LVCameraErrorDomain;
typedef enum : NSUInteger {
    LVCameraErrorCodeCameraPermission = 10, //相机权限错误
    LVCameraErrorCodeMicrophonePermission = 11, //麦克风权限错误
    LVCameraErrorCodeSession = 12, //会话错误
    LVCameraErrorCodeVideoNotEnabled = 13 //不允许录制
} LVSimpleCameraErrorCode;

@interface LVCaptureController : UIViewController

/**
 前后摄像头切换
 */
@property (nonatomic, copy) void (^onDeviceChange)(LVCaptureController *camera, AVCaptureDevice *device);

/**
 开始录制
 */
@property (nonatomic, copy) void (^onStartRecording)(LVCaptureController* camera);

/**
 返回错误信息
 */
@property (nonatomic, copy) void (^onError)(LVCaptureController *camera, NSError *error);

//拍照预览界面
@property (strong, nonatomic) UIView *preview;

//白平衡模式    Default: AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance
@property (nonatomic) AVCaptureWhiteBalanceMode whiteBalanceMode;

//摄像头       Default：LVCapturePositionRear
@property (nonatomic ,assign) LVCapturePosition position;

//闪光灯       Default：LVCaptureFlashOff
@property (nonatomic ,readonly) LVCaptureFlash flash;

//镜像        Default：LVCaptureMirrorAuto
@property (nonatomic ,assign) LVCaptureMirror mirror;

//是否允许缩放 Default：YES
@property (nonatomic ,assign ,getter=isZoomingEnabled) BOOL zoomingEnabled;

//点击聚焦    Default：YES
@property (nonatomic ,assign) BOOL tapToFocus;

//是否使用设备的方向 Default：YES
@property (nonatomic) BOOL useDeviceOrientation;

/**
 切换摄像头

 @return 当前摄像头
 */
-(LVCapturePosition)changePosition;

/**
 初始化函数
 
 @param quality 输出图片质量
 @param position 摄像头位置
 @param recordingEnabled 是否需要录像
 @return LVCaptureController
 */
-(instancetype) initWithQuality:(NSString *)quality position:(LVCapturePosition)position enableRecording:(BOOL)recordingEnabled;

-(instancetype) initWithQuality:(NSString *)quality position:(LVCapturePosition)position;

-(instancetype) initWithQuality:(NSString *)quality;

//开始会话
-(void)start;

//停止会话
-(void)stop;

/**
 拍照

 @param onCapture 返回图片或者错误信息
 @param exactSeenImage 是否需要根据显示的区域进行裁剪
 @param animationBlock 自定义动画
 */
-(void)capture:(void (^)(LVCaptureController *capture,UIImage *image, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage animationBlock:(void (^)(AVCaptureVideoPreviewLayer *layer))animationBlock;
-(void)capture:(void (^)(LVCaptureController *camera, UIImage *image, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage;
-(void)capture:(void (^)(LVCaptureController *camera, UIImage *image, NSError *error))onCapture;

//---------------视频---------------

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

/**
 设置预览图层的位置

 @param vc 展示的VC
 @param frame 位置区域
 */
- (void)attachToViewController:(UIViewController *)vc withFrame:(CGRect)frame;

//更新闪光灯模式
- (BOOL)updateFlashMode:(LVCaptureFlash)cameraFlash;

//点击聚焦图层和聚焦动画
-(void)clickFocusBox:(CALayer *)layer animation:(CAAnimation *)animation;

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
