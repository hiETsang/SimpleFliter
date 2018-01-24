//
//  UITextField+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/21.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (X)

/**
 *  @brief  当前选中的字符串范围
 *
 *  @return NSRange
 */
- (NSRange)selectedRange;
/**
 *  @brief  选中所有文字
 */
- (void)selectAllText;
/**
 *  @brief  选中指定范围的文字
 *
 *  @param range NSRange范围
 */
- (void)setSelectedRange:(NSRange)range;

@end
