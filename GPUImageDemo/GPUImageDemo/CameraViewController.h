//
//  CameraViewController.h
//  GPUImageDemo
//
//  Created by canoe on 2018/1/24.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#pragma mark - 人脸识别代理
@protocol XFaceDetectionDelegate<NSObject>

/**
 @param hasFace 是否有人脸
 @param faceCount 人脸张数
 */
-(void)faceDetectionSuccess:(BOOL)hasFace faceCount:(NSUInteger)faceCount;


/**
 在检测的范围内只有一张人脸时返回 如果openDetection==NO返回所有的图片
 @param image 检测到人脸时的图片，截取的是检测的范围（返回的图片都是原图）
 */
-(void)faceDetectionSuccessWithImage:(UIImage *)image;
@end

typedef enum : NSUInteger {
    LVCameraErrorCodeCameraPermission = 10, //相机权限错误
    LVCameraErrorCodeMicrophonePermission = 11, //麦克风权限错误
    LVCameraErrorCodeSession = 12, //会话错误
    LVCameraErrorCodeVideoNotEnabled = 13 //不允许录制
} LVSimpleCameraErrorCode;
@interface CameraViewController : UIViewController

#pragma mark - 美颜滤镜
@property(nonatomic, assign) BOOL openBeautyFilter;//是否开启美颜功能
@property(nonatomic, assign) BOOL allowSwitchFilter;//是否允许切换滤镜

#pragma mark - 人脸识别
@property(nonatomic, assign) BOOL openFaceDetection;//是否打开人脸识别，默认关闭
@property(nonatomic,weak) id<XFaceDetectionDelegate> faceDetectionDelegate;
@property(nonatomic) CGRect detectionRect;//需要人脸检测的范围，默认全屏

#pragma mark - 相机操作


@end
