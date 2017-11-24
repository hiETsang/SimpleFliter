//
//  LVGetEffectsSourceTool.h
//  FilterDemo
//
//  Created by canoe on 2017/11/21.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STParamUtil.h"
#import "STCollectionViewDisplayModel.h"

@interface LVGetEffectsSourceTool : NSObject

/**
 检查SDK权限
 */
+ (BOOL)checkActiveCode;
+ (NSString *)getSHA1StringWithData:(NSData *)data;

/**
 获取贴纸collectionView展示的模型
 */
+ (NSArray *)getStickerModelsByType:(STEffectsType)type;


/**
 获取滤镜collectionView展示的模型
 */
+ (NSArray *)getFilterModels;


/**
 获取物体跟踪collectionView展示的模型
 */
+ (NSArray *)getObjectTrackModels;

@end
