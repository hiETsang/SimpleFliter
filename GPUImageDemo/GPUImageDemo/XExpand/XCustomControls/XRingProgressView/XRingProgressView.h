//
//  XRingProgressView.h
//  LEVE
//
//  Created by canoe on 2017/12/9.
//  Copyright © 2017年 dashuju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMacros.h"

//圆环进度条

@interface XRingProgressView : UIView

//线的总根数   (线之间的间距是根据根数和宽度计算自动得出)
@property(nonatomic, assign) NSInteger lineTotalCount;

//底层框的颜色
@property(nonatomic, strong) UIColor *backLineColor;

//底层框每一根线的长度
@property(nonatomic, assign) float backLineLength;

//底层框每一根线的宽度
@property(nonatomic, assign) float backLineWidth;



//进度条的颜色
@property(nonatomic, strong) UIColor *progressLineColor;
//进度条每一根线的长度
@property(nonatomic, assign) float progressLineLength;
//进度条每一根线的宽度
@property(nonatomic, assign) float progressLineWidth;


//圆环进度
@property(nonatomic, assign) float progress;

//带动画的圆环进度
-(void)setProgress:(float)progress animationDuration:(float)duration;

@end
