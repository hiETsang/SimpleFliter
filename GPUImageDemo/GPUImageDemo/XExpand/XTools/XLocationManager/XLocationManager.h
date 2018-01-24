//
//  XLocationManager.h
//  LEVE
//
//  Created by canoe on 2018/1/5.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^LocationSuccess)(double lat ,double lng);
typedef void (^GetAddressSuccess)(NSString *address);
typedef void (^GetCitySuccess)(NSString *city);
typedef void (^LocationFailed)(NSError *error);

@interface XLocationManager : NSObject

+ (XLocationManager *)shareManager;

/**
 是否一次性获取定位信息，default is NO
 */
@property(assign, nonatomic) BOOL stopAfterUpdates;

/**
 获取当前定位

 @param success 成功返回经纬度
 @param failure 错误信息
 */
- (void)getLocationWithSuccess:(LocationSuccess)success failure:(LocationFailed)failure;

/**
 获取详细地址

 @param success 详细地址
 @param failure 错误信息
 */
- (void)getAddressWithSuccess:(GetAddressSuccess)success failure:(LocationFailed)failure;

/**
 获取城市

 @param success 城市名称
 @param failure 错误信息
 */
- (void)getCityWithSuccess:(GetCitySuccess)success failure:(LocationFailed)failure;

/**
 停止定位
 */
- (void)stop;

@end
