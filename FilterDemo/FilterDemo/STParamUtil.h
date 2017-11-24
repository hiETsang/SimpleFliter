//
//  STParamUtil.h
//
//  Created by HaifengMay on 16/11/5.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

/*
 * function: 主要用来获取一些系统的参数，如 CPU占用率，帧率等
 */
#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define STWeakSelf __weak __typeof(self) weakSelf = self;


typedef NS_ENUM(NSInteger, STTitleViewStyle) {
    STTitleViewStyleOnlyImage = 0,
    STTitleViewStyleOnlyCharacter
};

typedef NS_ENUM(NSInteger, STEffectsType) {
    
    STEffectsTypeSticker2D = 0,
    STEffectsTypeSticker3D,
    STEffectsTypeStickerGesture,
    STEffectsTypeStickerSegment,
    STEffectsTypeStickerFaceChange,
    STEffectsTypeStickerFaceDeformation,
    
    STEffectsTypeObjectTrack,
    
    STEffectsTypeBeautyFilter,
    STEffectsTypeBeautyBase,
    STEffectsTypeBeautyShape,
    
    STEffectsTypeNone
};



@interface STParamUtil : NSObject

/*
 * 返回CPU占用率的分子（分母为100）
 */
+ (float) getCpuUsage;



/**
 获取所有滤镜模型的路径

 @return 路径数组
 */
+ (NSArray *)getFilterModelPaths;



/**
 获取所有贴纸素材包路径

 @return 路径数组
 */
+ (NSArray *)getStickerZipPaths;



/**
 获取通用物体素材路径

 @return 路径数组
 */
+ (NSArray *)getTrackerPaths;


/**
 获取特定类型贴纸素材路径

 @param type STEffectsType
 @return 路径数组
 */
+ (NSArray *)getStickerPathsByType:(STEffectsType)type;

@end
