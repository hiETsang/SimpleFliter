//
//  STCollectionView.h
//
//  Created by HaifengMay on 16/11/8.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

/*
 * 用于显示sticker  贴纸
 */

#import <UIKit/UIKit.h>
#import "STParamUtil.h"
#import "STCollectionViewDisplayModel.h"

typedef void(^STCollectionViewDelegateBlock)(STCollectionViewDisplayModel *model);

@interface STCollectionView : UICollectionView

- (instancetype)initWithFrame:(CGRect)frame withModels:(NSArray <STCollectionViewDisplayModel *> *) arrModels andDelegateBlock:(STCollectionViewDelegateBlock) delegateBlock;

- (void)clearSelectedStateExcept:(STEffectsType)type;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray <STCollectionViewDisplayModel *> *arrModels;

@property (nonatomic, readwrite, strong) NSArray<STCollectionViewDisplayModel *> *arr2DModels;
@property (nonatomic, readwrite, strong) NSArray<STCollectionViewDisplayModel *> *arr3DModels;
@property (nonatomic, readwrite, strong) NSArray<STCollectionViewDisplayModel *> *arrGestureModels;
@property (nonatomic, readwrite, strong) NSArray<STCollectionViewDisplayModel *> *arrSegmentModels;
@property (nonatomic, readwrite, strong) NSArray<STCollectionViewDisplayModel *> *arrFaceDeformationModels;
@property (nonatomic, readwrite, strong) NSArray<STCollectionViewDisplayModel *> *arrFilterModels;
@property (nonatomic, readwrite, strong) NSArray<STCollectionViewDisplayModel *> *arrObjectTrackModels;

@property (nonatomic, readwrite, strong) STCollectionViewDisplayModel *selectedModel;

@end
