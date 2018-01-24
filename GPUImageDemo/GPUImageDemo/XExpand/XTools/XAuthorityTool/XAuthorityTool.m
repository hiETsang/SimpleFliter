//
//  XAuthorityTool.m
//  LEVE
//
//  Created by canoe on 2018/1/2.
//  Copyright © 2018年  All rights reserved.
//



#import "XAuthorityTool.h"
#import "UIWindow+X.h"
@import Photos;                             //获取相册权限
@import AVFoundation;                       //获取音频及相机权限
@import Contacts;                           //获取通讯录权限
@import AddressBook;                        //ios 9.0 之前
@import EventKit;                           //获取日历权限
@import CoreLocation;                       //定位

@implementation XAuthorityTool


#pragma mark - 相册权限

+(XAuthorityState)hasPhotoAuthor
{
    PHAuthorizationStatus photoAuthorSatus = [PHPhotoLibrary authorizationStatus];
    
    if (photoAuthorSatus == PHAuthorizationStatusDenied || photoAuthorSatus == PHAuthorizationStatusRestricted) {
        return XAuthorityStateFailed;
    }else if(photoAuthorSatus == PHAuthorizationStatusNotDetermined)
    {
        return XAuthorityStateNotDetermined;
    }else
    {
        return XAuthorityStateSuccess;
    }
}

+(void)obtainPHPhotoAuthorizedStausCompletionBlock:(void (^)(BOOL))block
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == 3) {
                //DLog(@"相册开启权限:获取");
                block(YES);
            }else{
                //DLog(@"相册开启权限:暂无");
                block(NO);
            }
        });
    }];
}


#pragma mark - 麦克风
+(XAuthorityState)hasMicrophoneAuthor
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusDenied) {
        //DLog(@"麦克风权限:拒绝(Denied)");
        return XAuthorityStateFailed;
    }else if (status == AVAuthorizationStatusNotDetermined){
        //DLog(@"麦克风权限:未进行授权选择(NotDetermined)");
        return XAuthorityStateNotDetermined;
    }else if (status == AVAuthorizationStatusRestricted){
        //DLog(@"麦克风权限:未授权(Restricted)");
        return XAuthorityStateFailed;
    }
    //DLog(@"麦克风权限:已授权(Authorized)"); //AVAuthorizationStatusAuthorized
    return XAuthorityStateSuccess;
}

+(void)obtainAVMediaAudioAuthorizedStatusCompletionBlock:(void (^)(BOOL))block
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                //DLog(@"麦克风开启权限:获取");
                block(YES);
            }else{
                //DLog(@"麦克风开启权限:拒绝或未授权");
                block(NO);
            }
        });
    }];
}

#pragma mark - 相机权限

+(XAuthorityState)hasCameraAuthor
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        //没有开启相机权限
        return XAuthorityStateFailed;
    }else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        return XAuthorityStateNotDetermined;
    }else
    {
        return XAuthorityStateSuccess;
    }
}

+(void)obtainAVMediaVideoAuthorizedStatusCompletionBlock:(void (^)(BOOL))block
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                //            DLog(@"相机开启权限:已授权");
                block(YES);
            }else{
                //            DLog(@"相机开启权限:拒绝或未授权");
                block(NO);
            }
        });
    }];
}


#pragma mark - 日历权限
+(XAuthorityState)hasEventAuthor
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (status == EKAuthorizationStatusRestricted || status == EKAuthorizationStatusDenied)
    {
        //没有开启权限
        return XAuthorityStateFailed;
    }else if(status == EKAuthorizationStatusNotDetermined)
    {
        return XAuthorityStateNotDetermined;
    }else
    {
        return XAuthorityStateSuccess;
    }
}

+(void)obtainEventAuthorizedStatusCompletionBlock:(void (^)(BOOL hasAuthor))block
{
    EKEventStore *store = [[EKEventStore alloc] init];
    if (store){
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //第一次授权后
                block(YES);
            }else{
                block(NO);
            }
        }];
    }
}

#pragma mark - 通讯录权限
+(XAuthorityState)hasContactAuthor
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        
        if (status == CNAuthorizationStatusNotDetermined) {                         //用户从未进行过授权等处理，首次访问相应内容会提示用户进行授权
            return XAuthorityStateNotDetermined;
        }else if (status == CNAuthorizationStatusAuthorized){                       //已经授权应用访问通讯录
            return XAuthorityStateSuccess;
        }else if (status == CNAuthorizationStatusRestricted) {                      //此应用程序没有被授权访问的通讯录
            return XAuthorityStateFailed;
        }else if (status == CNAuthorizationStatusDenied) {                          //用户拒绝当前应用访问通讯录
            return XAuthorityStateFailed;
        }else{
            return XAuthorityStateFailed;
        }
    }else{
        //ios 9.0 之前版本
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        
        if (status == kABAuthorizationStatusNotDetermined) {                            //用户从未进行过授权等处理，首次访问相应内容会提示用户进行授权
            return XAuthorityStateNotDetermined;
        }else if(status == kABAuthorizationStatusAuthorized){                           //已经授权应用访问通讯录
            return XAuthorityStateSuccess;
        } else if (status == kABAuthorizationStatusRestricted) {                        //此应用程序没有被授权访问的通讯录
            return XAuthorityStateFailed;
        } else if (status == kABAuthorizationStatusDenied) {                            //用户拒绝当前应用访问通讯录
            return XAuthorityStateFailed;
        } else {
            return XAuthorityStateFailed;
        }
    }
}

+(void)obtainContactAuthorizedStatusCompletionBlock:(void (^)(BOOL hasAuthor))block
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        if (contactStore == NULL) {
            block(NO);
        }
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (error) {
                block(NO);
            }else{
                if (granted) {
                    block(YES);
                }else{
                    block(NO);
                }
            }
        }];
    }else
    {
        __block ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        if (addressBookRef == NULL) {
            block(NO);
        }
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                block(YES);
            }else{
                block(NO);
            }
            if (addressBookRef) {
                CFRelease(addressBookRef);
                addressBookRef = NULL;
            }
        });
    }
}

#pragma mark - 获取定位权限
+(BOOL)locationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

+(XAuthorityState)hasLocationAuthor
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined) {                            //第一次获取定位
        return XAuthorityStateNotDetermined;
    }else if (status == kCLAuthorizationStatusAuthorizedAlways) {                   //授权应用可以一直获取定位
        return XAuthorityStateSuccess;
    }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {                //授权当前应用在使用中获取定位
        return XAuthorityStateSuccess;
    }else if (status == kCLAuthorizationStatusDenied) {                             //用户拒绝当前应用访问获取定位
        return XAuthorityStateFailed;
    }else if (status == kCLAuthorizationStatusRestricted) {                         //此应用程序没有被授权访问的获取定位
        return XAuthorityStateFailed;
    }else{
        return XAuthorityStateFailed;
    }
}

#pragma mark - 跳转设置提示框
+(void)showRequestAuthorViewWithMassage:(NSString *)str
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [XAuthorityTool setRequestOpenURL];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [[UIApplication sharedApplication].keyWindow.currentViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 跳到设置界面
+ (void)setRequestOpenURL {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}


@end
