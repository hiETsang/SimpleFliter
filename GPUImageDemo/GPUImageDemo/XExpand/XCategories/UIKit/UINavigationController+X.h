//
//  UINavigationController+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/21.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (X)

@end

@interface UINavigationController (XPageManage)

/**
 返回到指定的页面
 
 @param vcClass 该页面的class
 */
-(BOOL) popToAppiontViewController:(Class)vcClass;

/**
 返回到某个没有创建的页面
 
 @param viewController 跳转页面
 @param aClass 前一个页面class
 */
-(void) popToNoExistViewController:(UIViewController *)viewController behindOfViewController:(Class)aClass;

/**
 返回到某个没有创建的页面
 
 @param viewController 跳转页面
 @param aClass 后一个页面class
 */
-(void) popToNoExistViewController:(UIViewController *)viewController inFrontOfTheViewController:(Class)aClass;

/**
 在指定的位置之后插入一个页面
 
 @param viewController 该页面class
  @param aClass 需要插入页面的前一个页面class
 */
- (void)insertNoExistViewController:(UIViewController *)viewController behindOfTheViewController:(Class)aClass;

/**
 删除已经存在的某一个页面
 
 @param vcClass 该页面class
 */
-(void) deleteAppiontViewController:(Class)vcClass;

@end
