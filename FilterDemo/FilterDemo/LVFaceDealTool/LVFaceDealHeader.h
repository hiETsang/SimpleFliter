//
//  LVFaceDealHeader.h
//  FilterDemo
//
//  Created by canoe on 2017/11/20.
//  Copyright © 2017年 canoe. All rights reserved.
//

#ifndef LVFaceDealHeader_h
#define LVFaceDealHeader_h

#import <CommonCrypto/CommonDigest.h>
#import <OpenGLES/ES2/glext.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "st_mobile_human_action.h"  // 人体动作(脸部、 部)
#import "st_mobile_beautify.h"      //美颜操作
#import "st_mobile_filter.h"        //滤镜操作
#import "st_mobile_common.h"        //SDK常用自定义
//#import "st_mobile_face.h"          //人脸关键点
#import "st_mobile_face_attribute.h"//人脸属性检测操作
#import "st_mobile_license.h"       //鉴权操作
#import "st_mobile_object.h"        //通用物体跟踪
#import "st_mobile_sticker.h"       //贴纸

/***  当前屏幕宽度 */
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
/***  当前屏幕高度 */
#define kScreenHeight  [[UIScreen mainScreen] bounds].size.height

#import "STParamUtil.h"
#import "STMobileLog.h"

#endif /* LVFaceDealHeader_h */
