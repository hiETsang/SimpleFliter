//
//  UIDevice+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/18.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

//是否是ipad
#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
//设备系统版本
#define DEVICE_IOS_VERSION [[UIDevice currentDevice].systemVersion floatValue]
//设备版本是否大于i
#define DEVICE_HARDWARE_BETTER_THAN(i) [[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:i]
//设备是否有retain屏
#define DEVICE_HAS_RETINA_DISPLAY (fabs([UIScreen mainScreen].scale - 2.0) <= fabs([UIScreen mainScreen].scale - 2.0)*DBL_EPSILON)


typedef enum
{
    NOT_AVAILABLE,
    
    IPHONE_2G,
    IPHONE_3G,
    IPHONE_3GS,
    IPHONE_4,
    IPHONE_4_CDMA,
    IPHONE_4S,
    IPHONE_5,
    IPHONE_5_CDMA_GSM,
    IPHONE_5C,
    IPHONE_5C_CDMA_GSM,
    IPHONE_5S,
    IPHONE_5S_CDMA_GSM,
    IPHONE_6,
    IPHONE_6_PLUS,
    IPHONE_6S,
    IPHONE_6S_PLUS,
    IPHONE_SE,
    IPHONE_7,
    IPHONE_7_PLUS,
    IPHONE_8,
    IPHONE_8_PLUS,
    IPHONE_X,
    
    
    IPOD_TOUCH_1G,
    IPOD_TOUCH_2G,
    IPOD_TOUCH_3G,
    IPOD_TOUCH_4G,
    IPOD_TOUCH_5G,
    
    IPAD,
    IPAD_2,
    IPAD_2_WIFI,
    IPAD_2_CDMA,
    IPAD_3,
    IPAD_3G,
    IPAD_3_WIFI,
    IPAD_3_WIFI_CDMA,
    IPAD_4,
    IPAD_4_WIFI,
    IPAD_4_GSM_CDMA,
    
    IPAD_MINI,
    IPAD_MINI_WIFI,
    IPAD_MINI_WIFI_CDMA,
    IPAD_MINI_RETINA_WIFI,
    IPAD_MINI_RETINA_WIFI_CDMA,
    
    IPAD_AIR_WIFI,
    IPAD_AIR_WIFI_GSM,
    IPAD_AIR_WIFI_CDMA,
    
    SIMULATOR
} Hardware;


@interface UIDevice (X)
/** 返回系统版本字符串 例：iPhone7,2 */

- (NSString*)hardwareString;

/** 返回设备版本号枚举值 例：IPHONE_X */
- (Hardware)hardware;

/** 返回设备描述字符串 例：iPhone 5 (Global) */
- (NSString*)hardwareDescription;

/** 返回设备描述字符串简写 例：iPhone 6 */
- (NSString *)hardwareSimpleDescription;

/** 当前设备版本是否大于某一个版本 是返回YES */
- (BOOL)isCurrentDeviceHardwareBetterThan:(Hardware)hardware;

/** 当前设备是否是4英寸显示 是返回YES **/
- (BOOL)isIphoneWith4inchDisplay;

//mac地址
+ (NSString *)macAddress;

//Return the current device CPU 频率
+ (NSUInteger)cpuFrequency;
// Return the current device BUS 频率
+ (NSUInteger)busFrequency;
//current device RAM size
+ (NSUInteger)ramSize;
//Return the current device CPU number
+ (NSUInteger)cpuNumber;

/// 获取iOS系统的版本号
+ (NSString *)systemVersion;

/// 获取手机内存总量, 返回的是字节数
+ (NSUInteger)totalMemoryBytes;
/// 获取手机可用内存, 返回的是字节数
+ (NSUInteger)freeMemoryBytes;

/// 获取手机硬盘空闲空间, 返回的是字节数
+ (long long)freeDiskSpaceBytes;
/// 获取手机硬盘总空间, 返回的是字节数
+ (long long)totalDiskSpaceBytes;

@end
