//
//  UIButton+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/8.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 实用方法
typedef void (^TouchedBlock)(NSInteger tag);
@interface UIButton (X)

/**
 快速创建文字按钮（默认状态）

 @param title 文字
 @param titleColor 文字颜色
 @param font 字体
 @param color 按钮背景颜色
 @return 按钮
 */
+ (UIButton *)buttonTextTypeWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font backColor:(UIColor *)color;


/**
 快速创建图片按钮(默认状态)

 @param imageName 图片名称
 @param title 标题(默认字体14号黑色)
 @return 按钮
 */
+ (UIButton *)buttonImageTypeWithImageName:(NSString *)imageName title:(NSString *)title;



/**
 *  @brief  使用颜色设置按钮背景
 *
 *  @param backgroundColor 背景颜色
 *  @param state           按钮状态
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;


/** 点击block回调 */
-(void)addActionHandler:(TouchedBlock)touchHandler;

@end




#pragma mark - 点击加载转圈
@interface UIButton (XIndicator)
/**
 隐藏文字，在中心加一个小菊花
 */
- (void) showIndicator;

/**
 隐藏小菊花，文字出来
 */
- (void) hideIndicator;

@end


#pragma mark - 扩大按钮点击范围
@interface UIButton (XEnlargeEdge)
/**
 *  修改Btn的点击范围
 */
- (void)setEnlargeEdge:(CGFloat) size;
/**
 *  修改Btn的点击范围
 */
- (void)setEnlargeEdgeWithOffSet:(UIEdgeInsets)offset;

@end



#pragma mark - 设置按钮文字和图片的间距
typedef NS_ENUM(NSInteger, XImagePosition) {
    XImagePositionLeft = 0,              //图片在左，文字在右，默认
    XImagePositionRight = 1,             //图片在右，文字在左
    XImagePositionTop = 2,               //图片在上，文字在下
    XImagePositionBottom = 3,            //图片在下，文字在上
};
@interface UIButton (XImagePosition)

/**
 *  利用UIButton的titleEdgeInsets和imageEdgeInsets来实现文字和图片的自由排列
 *  注意：这个方法需要在设置图片和文字之后才可以调用，且button的大小要大于 图片大小+文字大小+spacing
 *
 *  @param spacing 图片和文字的间隔
 */
- (void)setImagePosition:(XImagePosition)postion spacing:(CGFloat)spacing;

@end



