//
//  XAuthorityTool.h
//  LEVE
//
//  Created by canoe on 2018/1/2.
//  Copyright © 2018年  All rights reserved.
//

/**
                                    app权限获取管理
 plist设置：
 <key>NSContactsUsageDescription</key>
 <string>请求访问通讯录</string>
 <key>NSMicrophoneUsageDescription</key>
 <string>请求访问麦克风</string>
 <key>NSPhotoLibraryUsageDescription</key>
 <string>请求访问相册</string>
 <key>NSCameraUsageDescription</key>
 <string>请求访问相机</string>
 <key>NSLocationAlwaysUsageDescription</key>
 <string>始终访问地理位置</string>
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>在使用期间访问地理位置</string>
 <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
 <string>需要访问地理位置</string>
 <key>NSLocationAlwaysUsageDescription</key>
 <string>始终访问地理位置</string>
 <key>NSLocationUsageDescription</key>
 <string>需要访问地理位置</string>
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>在使用期间访问地理位置</string>
 <key>NSCalendarsUsageDescription</key>
 <string>请求访问日历</string>
 */

/**
 使用：
 1.调用hasAuthor方法判断是否获取权限或是没有请求过权限
 2.没有请求过调用obtainAuthorizedStausCompletionBlock：来进行第一次请求权限
 3.根据获得的状态进行后续提示
 */




#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, XAuthorityState) {
    XAuthorityStateSuccess,        //获取权限成功
    XAuthorityStateFailed,         //获取权限失败
    XAuthorityStateNotDetermined,  //用户还没有决定
};

@interface XAuthorityTool : NSObject

#pragma mark - 相册权限 -
//是否有相册权限
+(XAuthorityState)hasPhotoAuthor;
//请求权限 显示系统提示框
+(void)obtainPHPhotoAuthorizedStausCompletionBlock:(void (^)(BOOL hasAuthor))block;

#pragma mark - 麦克风权限 -
+(XAuthorityState)hasMicrophoneAuthor;
+ (void)obtainAVMediaAudioAuthorizedStatusCompletionBlock:(void (^)(BOOL hasAuthor))block;

#pragma mark - 相机权限 -
+(XAuthorityState)hasCameraAuthor;
+(void)obtainAVMediaVideoAuthorizedStatusCompletionBlock:(void (^)(BOOL hasAuthor))block;

#pragma mark - 日历权限 -
+(XAuthorityState)hasEventAuthor;
+(void)obtainEventAuthorizedStatusCompletionBlock:(void (^)(BOOL hasAuthor))block;

#pragma mark - 通讯录权限 -
+(XAuthorityState)hasContactAuthor;
+(void)obtainContactAuthorizedStatusCompletionBlock:(void (^)(BOOL hasAuthor))block;

#pragma mark - 获取定位权限 -
//定位服务是否开启  需要确认定位服务开启然后判断权限
+(BOOL)locationServicesEnabled;
//是否有定位权限
+(XAuthorityState)hasLocationAuthor;


/** 弹出跳转权限设置提示框 */
+ (void)showRequestAuthorViewWithMassage:(NSString *)str;
/** 跳到设置界面 */
+ (void)setRequestOpenURL;


@end
