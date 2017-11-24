//
//  STScrollTitleView.h
//  SenseMeEffects
//
//  Created by Sunshine on 16/08/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTitleViewItem.h"
#import "STParamUtil.h"


typedef void (^STTitleOnClickBlock)(STTitleViewItem *titleView, NSInteger index, STEffectsType type);


@interface STScrollTitleView : UIView

@property (nonatomic, readwrite, strong) NSArray<NSString *> *arrTitles;
@property (nonatomic, readwrite, strong) NSArray<UIImage *> *arrNormalImages;
@property (nonatomic, readwrite, strong) NSArray<UIImage *> *arrSelectedImages;
@property (nonatomic, readwrite, strong) NSArray<NSNumber *> *arrEffectsType;

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray *)titles
                  effectsType:(NSArray *)effectsType
                 titleOnClick:(STTitleOnClickBlock)onClickBlock;

- (instancetype)initWithFrame:(CGRect)frame
                 normalImages:(NSArray *)normalImages
               selectedImages:(NSArray *)selectedImages
                  effectsType:(NSArray *)effectsType
                 titleOnClick:(STTitleOnClickBlock)onClickBlock;


//- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex;
- (void)adjustTitleOffsetToCurrentIndex:(NSInteger)currentIndex;
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;

- (void)reloadTitlesWithNewTitles:(NSArray *)titles effectsType:(NSArray *)effectsType;
- (void)reloadTitlesWithNewNormalImages:(NSArray *)normalImages selectedImages:(NSArray *)selectedImages effectsType:(NSArray *)effectsType;

@end

