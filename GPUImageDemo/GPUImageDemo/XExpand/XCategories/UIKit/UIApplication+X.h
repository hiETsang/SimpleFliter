//
//  UIApplication+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/18.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (X)

/**
 应用程序大小
 */
- (NSString *)applicationSize;


/**
 当前状态键盘位置
 */
- (CGRect)keyboardFrame;


@end
