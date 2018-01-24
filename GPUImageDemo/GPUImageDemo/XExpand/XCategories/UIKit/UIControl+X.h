//
//  UIControl+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/18.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIControlActionBlock)(id weakSender);

@interface UIControlActionBlockWrapper : NSObject
@property (nonatomic, copy) UIControlActionBlock actionBlock;
@property (nonatomic, assign) UIControlEvents controlEvents;
- (void)invokeBlock:(id)sender;
@end

@interface UIControl (X)

/**
 给某一事件添加回调
 
 @param controlEvents 事件
 @param actionBlock 回调
 */
- (void)addControlEvents:(UIControlEvents)controlEvents withBlock:(UIControlActionBlock)actionBlock;


/**
 移除某一事件的回调

 @param controlEvents 事件
 */
- (void)removeActionBlocksForControlEvents:(UIControlEvents)controlEvents;

@end
