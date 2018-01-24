//
//  XLocationManager.m
//  LEVE
//
//  Created by canoe on 2018/1/5.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import "XLocationManager.h"
#import "XAuthorityTool.h"
#import "UIDevice+X.h"

@interface XLocationManager ()<CLLocationManagerDelegate>
{
    CLLocationManager *manager;
    LocationSuccess successBlock;
    LocationFailed failedBlock;
    GetAddressSuccess addressBlock;
    GetCitySuccess cityBlock;
}

@end

@implementation XLocationManager

+ (XLocationManager *) shareManager {
    static XLocationManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[XLocationManager alloc] init];
    });
    return shared;
}

-(void)startLocation
{
    if([XAuthorityTool locationServicesEnabled] && [XAuthorityTool hasLocationAuthor] != XAuthorityStateFailed)
    {
        // 打开定位 然后得到数据
        manager = [[CLLocationManager alloc] init];
        manager.delegate = self;
        //控制定位精度,越高耗电量越
        manager.desiredAccuracy = kCLLocationAccuracyBest;
        // 1. 适配 动态适配
        if ([manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [manager requestWhenInUseAuthorization];
            [manager requestAlwaysAuthorization];
        }
        // 2. 另外一种适配 systemVersion 有可能是 8.1.1
        float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (osVersion >= 8) {
            [manager requestWhenInUseAuthorization];
            [manager requestAlwaysAuthorization];
        }
        [manager startUpdatingLocation];
    }else
    {
        [XAuthorityTool showRequestAuthorViewWithMassage:@"是否前去开启定位服务?"];
    }
}

-(void)stop
{
    [manager stopUpdatingLocation];
    manager = nil;
}

- (void)getLocationWithSuccess:(LocationSuccess)success failure:(LocationFailed)failure
{
    successBlock = success;
    failedBlock = failure;
    [self startLocation];
}

-(void)getAddressWithSuccess:(GetAddressSuccess)success failure:(LocationFailed)failure
{
    addressBlock = success;
    failedBlock = failure;
    [self startLocation];
}

-(void)getCityWithSuccess:(GetCitySuccess)success failure:(LocationFailed)failure
{
    cityBlock = success;
    failedBlock = failure;
    [self startLocation];
}

#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *loc = [locations lastObject];
    CLLocationCoordinate2D l = loc.coordinate;
    double lat = l.latitude;
    double lnt = l.longitude;
    successBlock ? successBlock(lat, lnt) : nil;
    
    CLGeocoder *geocoder= [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks,NSError *error)
     {
         if (placemarks.count > 0) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSString * lastCity = [NSString stringWithFormat:@"%@%@",placemark.administrativeArea,placemark.locality];
             
             NSString * lastAddress = [NSString stringWithFormat:@"%@%@%@%@%@%@",placemark.country,placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare,placemark.subThoroughfare];//详细地址
             if (cityBlock) {
                 cityBlock(lastCity);
             }
             if (addressBlock) {
                 addressBlock(lastAddress);
             }
         }
     }];
    
    if (self.stopAfterUpdates == YES) {
        [self stop];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    failedBlock ? failedBlock(error) : nil;
    if ([error code] == kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}

@end
