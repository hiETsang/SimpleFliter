//
//  LVConfigEffectsView.h
//  FilterDemo
//
//  Created by canoe on 2017/11/21.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STScrollTitleView.h"
#import "STCollectionView.h"
#import "STSliderView.h"

typedef NS_ENUM(NSUInteger, STSliderViewTag) {
    STViewTagShrinkFaceSlider = 100,
    STViewTagEnlargeEyeSlider,
    STViewTagShrinkJawSlider,
    STViewTagSmoothSlider,
    STViewTagReddenSlider,
    STViewTagWhitenSlider
};

@protocol LVConfigEffectsViewDelegate <NSObject>
//点击特效
-(void)didSelectedEffectModel:(STCollectionViewDisplayModel *)model;
//点击去除特效按钮
-(void)didSelectedRemoveAllEffectButton;

//点击滤镜
-(void)didSelectedFilterModel:(STCollectionViewDisplayModel *)model;
//滑动滑杆
-(void)didSliderValueChanged:(UISlider *)sender;

@end

@interface LVConfigEffectsView : UIView

@property(nonatomic, weak) id <LVConfigEffectsViewDelegate> delegate;

@property(nonatomic, strong) UIButton *beautyButton;//美颜按钮
@property(nonatomic, strong) UIButton *effectsButton;//特效按钮

@property(nonatomic, strong) UIView *beautyView;//美颜View
@property(nonatomic, strong) UIView *effectsView;//特效View

@property (nonatomic, readwrite, strong) UIImageView *noneStickerImageView;//无贴纸View

@property (nonatomic, readwrite, strong) STScrollTitleView *scrollTitleView;//特效顶部按钮滚动
@property (nonatomic, readwrite, strong) STScrollTitleView *beautyScrollTitleView;//美颜顶部按钮滚动

@property (nonatomic, readwrite, strong) STCollectionView *collectionView;//选中的特效collectionView
@property (nonatomic, readwrite, strong) STCollectionView *beautyCollectionView;//美颜collectionView
@property (nonatomic, readwrite, strong) UIView *beautyShapeView;       //美形View
@property (nonatomic, readwrite, strong) UIView *beautyBaseView;        //基础美颜View

@property (nonatomic, readwrite, strong) NSMutableArray *arrBeautyViews;//美颜的View数组

@property (nonatomic, readwrite, strong) STSliderView *thinFaceView;
@property (nonatomic, readwrite, strong) STSliderView *enlargeEyesView;
@property (nonatomic, readwrite, strong) STSliderView *smallFaceView;
@property (nonatomic, readwrite, strong) STSliderView *dermabrasionView;
@property (nonatomic, readwrite, strong) STSliderView *ruddyView;
@property (nonatomic, readwrite, strong) STSliderView *whitenView;

@property (nonatomic, readwrite, strong) NSArray *arr2DStickers;//2d贴纸
@property (nonatomic, readwrite, strong) NSArray *arr3DStickers;//3d贴纸
@property (nonatomic, readwrite, strong) NSArray *arrGestureStickers;//手势贴纸
@property (nonatomic, readwrite, strong) NSArray *arrSegmentStickers;//背景分割
@property (nonatomic, readwrite, strong) NSArray *arrFacedeformationStickers;//脸部变形
@property (nonatomic, readwrite, strong) NSArray *arrObjectTrackers;//跟踪物体
@property (nonatomic, readwrite, strong) NSArray *arrFilters;//滤镜
@end
