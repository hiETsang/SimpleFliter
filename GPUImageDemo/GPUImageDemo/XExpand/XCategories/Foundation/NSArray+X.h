//
//  NSArray+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/25.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (X)

//随机从数组中取值
- (nullable id)randomObject;

//如果没有值返回nil
- (nullable id)objectOrNilAtIndex:(NSUInteger)index;

@end

@interface  NSMutableArray (X)

//移除数组第一个值
- (void)removeFirstObject;

//移除数组最后一个值
- (void)removeLastObject;

//在某一位置插入数组
- (void)insertObjects:(NSArray *_Nullable)objects atIndex:(NSUInteger)index;

//反转数组  Example: Before @[ @1, @2, @3 ], After @[ @3, @2, @1 ].
- (void)reverse;

//随机打乱数组中的值的顺序
- (void)shuffle;

@end
