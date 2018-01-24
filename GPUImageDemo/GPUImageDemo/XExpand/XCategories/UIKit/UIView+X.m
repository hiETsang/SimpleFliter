//
//  UIView+X.m
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/4.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "UIView+X.h"
#import <objc/runtime.h>
static char kActionHandlerTapBlockKey;
static char kActionHandlerTapGestureKey;
static char kActionHandlerLongPressBlockKey;
static char kActionHandlerLongPressGestureKey;

@implementation UIView (X)
#pragma mark - 实用方法

/**
 移除所有子视图
 */
- (void)removeAllSubviews {
    while (self.subviews.count) {
        [self.subviews.lastObject removeFromSuperview];
    }
}


/**
 当前View的ViewController
 */
- (UIViewController *)viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

/**
 *  @brief  view截图
 *
 *  @return 截图
 */
- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    if( [self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }
    else
    {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}

/** 切圆角 */
-(void)cornerRadius: (CGFloat)radius
        borderWidth: (CGFloat)width
              color: (UIColor *_Nullable)color
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

/**
 *  设置阴影
 */
-(void)shadowWithColor: (UIColor *)color
                offset: (CGSize)offset
               opacity: (CGFloat)opacity
                radius: (CGFloat)radius
{
    self.clipsToBounds = NO;
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
}

/**
 ** lineView:       需要绘制成虚线的view
 ** lineLength:     虚线的宽度
 ** lineSpacing:    虚线的间距
 ** lineColor:      虚线的颜色
 **/
+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(lineView.frame), 0);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

@end

@implementation UIView (XQuickInit)

/**
 快速创建文字按钮（默认状态）
 
 @param title 文字
 @param titleColor 文字颜色
 @param font 字体
 @param color 按钮背景颜色
 @return 按钮
 */
- (UIButton *)addButtonTextTypeWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font backColor:(UIColor *)color
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button setBackgroundColor:color];
    [self addSubview:button];
    return button;
}

/**
 快速创建图片按钮(默认状态)
 
 @param imageName 图片名称
 @param title 标题(默认字体14号黑色)
 @return 按钮
 */
- (UIButton *)addButtonImageTypeWithImageName:(NSString *)imageName title:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:button];
    return button;
}

/**
 添加Label
 
 @param title 标题
 @param font 字体
 @param color 颜色
 @return Label
 */
-(UILabel *_Nullable)addLabelWithTitle:(NSString *_Nullable)title
                                  font:(UIFont *_Nullable)font
                             textColor:(UIColor *_Nullable)color
{
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = font;
    label.textColor = color;
    [self addSubview:label];
    return label;
}

/**
 添加ImageView到当前View
 
 @param image 图片
 @return ImageView
 */
-(UIImageView *_Nullable)addImageViewWithImage:(NSString *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    return imageView;
}


/**
 添加TextField到当前View
 
 @param style 风格
 @param placeholder 提示
 @param titleColor 颜色
 @param font 字体
 @return textfield
 */
-(UITextField *_Nullable)addTextFieldWithStyle:(UITextBorderStyle)style
                                   placeholder:(NSString *_Nullable)placeholder
                                    titleColor:(UIColor *_Nullable)titleColor
                                          font:(UIFont *_Nullable)font
{
    UITextField *textfield = [[UITextField alloc] init];
    textfield.borderStyle = style;
    textfield.placeholder = placeholder;
    textfield.textColor = titleColor;
    textfield.font = font;
    [self addSubview:textfield];
    return textfield;
}

@end



#pragma mark - 代码简写
@implementation UIView (XFrame)
- (CGFloat)x_left {
    return self.frame.origin.x;
}


-(void)setX_left:(CGFloat)x_left
{
    CGRect frame = self.frame;
    frame.origin.x = x_left;
    self.frame = frame;
}

- (CGFloat)x_top {
    return self.frame.origin.y;
}

-(void)setX_top:(CGFloat)x_top
{
    CGRect frame = self.frame;
    frame.origin.y = x_top;
    self.frame = frame;
}

- (CGFloat)x_right {
    return self.frame.origin.x + self.frame.size.width;
}

-(void)setX_right:(CGFloat)x_right
{
    CGRect frame = self.frame;
    frame.origin.x = x_right - frame.size.width;
    self.frame = frame;
}


- (CGFloat)x_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

-(void)setX_bottom:(CGFloat)x_bottom
{
    CGRect frame = self.frame;
    frame.origin.y = x_bottom - frame.size.height;
    self.frame = frame;
}


- (CGFloat)x_width {
    return self.frame.size.width;
}

-(void)setX_width:(CGFloat)x_width
{
    CGRect frame = self.frame;
    frame.size.width = x_width;
    self.frame = frame;
}

- (CGFloat)x_height {
    return self.frame.size.height;
}

-(void)setX_height:(CGFloat)x_height
{
    CGRect frame = self.frame;
    frame.size.height = x_height;
    self.frame = frame;
}


- (CGFloat)x_centerX {
    return self.center.x;
}

-(void)setX_centerX:(CGFloat)x_centerX
{
    self.center = CGPointMake(x_centerX, self.center.y);
}


- (CGFloat)x_centerY {
    return self.center.y;
}

-(void)setX_centerY:(CGFloat)x_centerY
{
    self.center = CGPointMake(self.center.x, x_centerY);
}

- (CGPoint)x_origin {
    return self.frame.origin;
}

-(void)setX_origin:(CGPoint)x_origin
{
    CGRect frame = self.frame;
    frame.origin = x_origin;
    self.frame = frame;
}

- (CGSize)x_size {
    return self.frame.size;
}

-(void)setX_size:(CGSize)x_size
{
    CGRect frame = self.frame;
    frame.size = x_size;
    self.frame = frame;
}

@end






#pragma mark - 添加手势
@implementation UIView (XGesture)

- (void)addTapActionWithBlock:(GestureActionBlock)block
{
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &kActionHandlerTapGestureKey);
    if (!gesture)
    {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &kActionHandlerTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}
- (void)handleActionForTapGesture:(UITapGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized)
    {
        GestureActionBlock block = objc_getAssociatedObject(self, &kActionHandlerTapBlockKey);
        if (block)
        {
            block(gesture);
        }
    }
}
- (void)addLongPressActionWithBlock:(GestureActionBlock)block
{
    UILongPressGestureRecognizer *gesture = objc_getAssociatedObject(self, &kActionHandlerLongPressGestureKey);
    if (!gesture)
    {
        gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionForLongPressGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kActionHandlerLongPressGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &kActionHandlerLongPressBlockKey, block, OBJC_ASSOCIATION_COPY);
}
- (void)handleActionForLongPressGesture:(UITapGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized)
    {
        GestureActionBlock block = objc_getAssociatedObject(self, &kActionHandlerLongPressBlockKey);
        if (block)
        {
            block(gesture);
        }
    }
}

@end




#pragma mark - 抖动动画
@implementation UIView (XShake)
- (void)shake {
    [self _shake:10 direction:1 currentTimes:0 withDelta:5 speed:0.03 shakeDirection:ShakeDirectionHorizontal completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:0.03 shakeDirection:ShakeDirectionHorizontal completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta completion:(void(^)(void))handler {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:0.03 shakeDirection:ShakeDirectionHorizontal completion:handler];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:interval shakeDirection:ShakeDirectionHorizontal completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval completion:(void(^)(void))handler {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:interval shakeDirection:ShakeDirectionHorizontal completion:handler];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:interval shakeDirection:shakeDirection completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection completion:(void (^)(void))completion {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:interval shakeDirection:shakeDirection completion:completion];
}

- (void)_shake:(int)times direction:(int)direction currentTimes:(int)current withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection completion:(void (^)(void))completionHandler {
    [UIView animateWithDuration:interval animations:^{
        self.layer.affineTransform = (shakeDirection == ShakeDirectionHorizontal) ? CGAffineTransformMakeTranslation(delta * direction, 0) : CGAffineTransformMakeTranslation(0, delta * direction);
    } completion:^(BOOL finished) {
        if(current >= times) {
            [UIView animateWithDuration:interval animations:^{
                self.layer.affineTransform = CGAffineTransformIdentity;
            } completion:^(BOOL finished){
                if (completionHandler != nil) {
                    completionHandler();
                }
            }];
            return;
        }
        [self _shake:(times - 1)
           direction:direction * -1
        currentTimes:current + 1
           withDelta:delta
               speed:interval
      shakeDirection:shakeDirection
          completion:completionHandler];
    }];
}

@end





#pragma mark - 添加边框
@implementation UIView (XBorderLine)
-(CALayer *)addViewBorderWithcolor:(UIColor *)color border:(float)border type:(UIViewBorderLineType)borderLineType
{
    
    return [self addViewBorderWithcolor:color border:border type:borderLineType margin:0];
}

-(CALayer *)addViewBorderWithcolor:(UIColor *)color border:(float)border type:(UIViewBorderLineType)borderLineType margin:(CGFloat)margin
{
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = color.CGColor;
    switch (borderLineType) {
        case UIViewBorderLineTypeTop:{
            lineLayer.frame = CGRectMake(0, margin, self.frame.size.width, border);
            break;
        }
        case UIViewBorderLineTypeRight:{
            lineLayer.frame = CGRectMake(self.frame.size.width - margin, 0, border, self.frame.size.height);
            break;
        }
        case UIViewBorderLineTypeBottom:{
            lineLayer.frame = CGRectMake(0, self.frame.size.height - margin, self.frame.size.width,border);
            break;
        }
        case UIViewBorderLineTypeLeft:{
            lineLayer.frame = CGRectMake(margin, 0, border, self.frame.size.height);
            break;
        }
            
        default:{
            lineLayer.frame = CGRectMake(0, self.frame.size.height - margin, self.frame.size.width, border);
            break;
        }
    }
    
    [self.layer addSublayer:lineLayer];
    return lineLayer;
}

@end


