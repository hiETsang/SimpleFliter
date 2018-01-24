//
//  XRingProgressView.m
//  LEVE
//
//  Created by canoe on 2017/12/9.
//  Copyright © 2017年 dashuju. All rights reserved.
//

#import "XRingProgressView.h"
#import "UIView+X.h"

@interface XRingProgressView()

@property(nonatomic, strong) CAShapeLayer *backLayer;

@property(nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation XRingProgressView

-(void)setProgress:(float)progress
{
    [self addAnimationWithLayer:self.progressLayer WithCurrentProgress:_progress EndProgress:progress duration:0.f];
    
    _progress = progress;
}

-(void)setProgress:(float)progress animationDuration:(float)duration
{
    //animation
    [self addAnimationWithLayer:self.progressLayer WithCurrentProgress:_progress EndProgress:progress duration:duration];
    
    _progress = progress;
}

-(void)setBackLineColor:(UIColor *)backLineColor
{
    _backLineColor = backLineColor;
    self.backLayer.strokeColor = backLineColor.CGColor;
}

-(void)setProgressLineColor:(UIColor *)progressLineColor
{
    _progressLineColor = progressLineColor;
    self.progressLayer.strokeColor = progressLineColor.CGColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
    }
    return self;
}

-(void)initData
{
    self.backLineColor = RGB(244, 244, 244);
    self.backLineLength = 18;
    self.backLineWidth = 1.0;
    
    self.progressLineColor = RGBA(255, 255, 0, 1.0);
    self.progressLineLength = 26;
    self.progressLineWidth = 3.0;
    
    self.lineTotalCount = 90;
    
    _progress = 0.f;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [self configLayer];
}

-(void)configLayer
{
    //底层圆环
    float space = self.progressLineLength - self.backLineLength;
    
    CAShapeLayer *backBorder = [CAShapeLayer layer];
    backBorder.frame = CGRectMake(space/2, space/2, self.x_width - space, self.x_height - space);
    backBorder.strokeColor = self.backLineColor.CGColor;    //边缘线条颜色
    backBorder.fillColor = nil;     //填充的颜色
    //路径圆
    backBorder.path = [UIBezierPath bezierPathWithRoundedRect:backBorder.bounds cornerRadius:CGRectGetWidth(backBorder.bounds)/2].CGPath;
    backBorder.lineWidth = self.backLineLength;   //线条宽度
    
    float backBorderPerimeter = 2 * M_PI * backBorder.bounds.size.width/2;
    //  第一个是 线条长度   第二个是间距    nil时为实线
    backBorder.lineDashPattern = @[@(self.backLineWidth), @(backBorderPerimeter/self.lineTotalCount - self.backLineWidth)];
    
    self.backLayer = backBorder;
    [self.layer addSublayer:backBorder];
    
    
    //进度条
    CAShapeLayer *border = [CAShapeLayer layer];
    border.frame = self.bounds;
    border.strokeColor = self.progressLineColor.CGColor;
    border.fillColor = nil;
    border.path = [UIBezierPath bezierPathWithRoundedRect:border.bounds cornerRadius:CGRectGetWidth(border.bounds)/2].CGPath;
    border.lineWidth = self.progressLineLength;
    float borderPerimeter = 2 * M_PI * border.bounds.size.width/2;
    border.lineDashPattern = @[@(self.progressLineWidth), @(borderPerimeter/self.lineTotalCount - self.progressLineWidth)];
    self.progressLayer = border;
    [self.layer addSublayer:border];
    
    
    self.progressLayer.strokeStart = 0.f;
    self.progressLayer.strokeEnd = self.progress;
}


-(void)addAnimationWithLayer:(CAShapeLayer *)layer WithCurrentProgress:(float)currentProgress EndProgress:(float)progress duration:(float)duration
{
    layer.strokeStart = 0.f;   // 设置起点为 0
    layer.strokeEnd = currentProgress;     // 设置终点为 0
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(currentProgress);
    animation.toValue = @(progress);
    animation.duration = duration;
    // 保持动画结束时的状态
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    // 动画缓慢的进入，中间加速，然后减速的到达目的地。
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [layer addAnimation:animation forKey:@""];
}

@end
