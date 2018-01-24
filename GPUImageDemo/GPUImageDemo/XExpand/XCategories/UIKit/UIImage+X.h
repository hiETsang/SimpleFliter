//
//  UIImage+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/19.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (X)


/**
 获取视频第一帧

 @param url 视频地址
 @param size 图片大小
 @return 第一帧图片
 */
+ (nullable UIImage *)firstFrameWithVideoURL:(nullable NSURL *)url size:(CGSize)size;

@end


#pragma mark - 图片压缩
@interface UIImage (XCompress)
/**
 获得指定大小的图片   (压：质量)

 @param image 需要压缩的图片
 @param maxLength 压缩图片的最大值
 @return 压缩后的data
 */
+ (nullable NSData *)compressImageQuality:(nullable UIImage *)image toByte:(NSInteger)maxLength;

/**
 *  获得指定size的图片     (缩：尺寸)
 *
 *  @param image   原始图片
 *  @param newSize 指定的size
 *
 *  @return 调整后的图片
 */
+ (nullable UIImage *) resizeImage:(nullable UIImage *) image withNewSize:(CGSize) newSize;

/**
 *  通过指定图片最长边，获得等比例的图片size
 *
 *  @param image       原始图片
 *  @param imageLength 图片允许的最长宽度（高度）
 *
 *  @return 获得等比例的size
 */
+ (CGSize) scaleImage:(nullable UIImage *) image withLength:(CGFloat) imageLength;

@end




#pragma mark - 图片裁剪旋转等
@interface UIImage (XModify)

/**
 修正图片方向

 @return 修正后的图片
 */
- (nullable UIImage *)fixOrientation;

/**
 向左旋转90度

 @return 旋转后的图片
 */
- (nullable UIImage *)imageByRotateLeft90;

/**
 向右旋转90度
 
 @return 旋转后的图片
 */
- (nullable UIImage *)imageByRotateRight90;

/**
 旋转180度
 
 @return 旋转后的图片
 */
- (nullable UIImage *)imageByRotate180;

/**
 垂直翻转
 
 @return 旋转后的图片
 */
- (nullable UIImage *)imageByFlipVertical;

/**
 水平翻转
 
 @return 旋转后的图片
 */
- (nullable UIImage *)imageByFlipHorizontal;

/**
 旋转指定角度

 @param radians 角度 正数往左负数往右
 @param fitSize 是否自动适应大小
 @return 旋转后的图片
 */
- (nullable UIImage *)imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize;

/**
 图片裁剪

 @param rect 裁剪位置
 @return 裁剪后的图片
 */
- (nullable UIImage *)imageByCropToRect:(CGRect)rect;


/**
 图片按最窄边裁剪正方形

 @return 裁剪后的图片
 */
- (nullable UIImage *)imageByCropToSquare;

/**
 设置图片边距

 @param insets 边距
 @param color 边距填充颜色
 @return 设置后的图片
 */
- (nullable UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(nullable UIColor *)color;

/**
 图片切圆角
 
 @param radius 圆角弧度
 @param corners 切圆角方式
 @param borderWidth 边框宽度
 @param borderColor 边框颜色
 @param borderLineJoin 边框分格
 @return 切圆角后的图片
 */
- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                                       corners:(UIRectCorner)corners
                                   borderWidth:(CGFloat)borderWidth
                                   borderColor:(nullable UIColor *)borderColor
                                borderLineJoin:(CGLineJoin)borderLineJoin;
- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                                   borderWidth:(CGFloat)borderWidth
                                   borderColor:(nullable UIColor *)borderColor;
- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius;
@end


#pragma mark - GIF图片
@interface UIImage (XGif)

+ (nullable UIImage *)imageWithAnimatedGIFNamed:(nullable NSString *)name;

+ (nullable UIImage *)imageWithAnimatedGIFWithData:(nullable NSData *)data;

- (nullable UIImage *)compressAnimatedImageByScalingAndCroppingToSize:(CGSize)size;

@end
