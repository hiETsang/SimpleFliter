//
//  UINavigationController+X.m
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/21.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "UINavigationController+X.h"

@implementation UINavigationController (X)

@end

@implementation UINavigationController (XPageManage)

/**
 返回到指定的页面
 
 @param vcClass 该页面的class
 */
-(BOOL) popToAppiontViewController:(Class)vcClass
{
    if (![self containViewController:vcClass]) {
        return NO;
    }
    
    for (UIViewController *vc in self.viewControllers) {
        if ([vc isKindOfClass:vcClass]) {
            [self popToViewController:vc animated:YES];
            return YES;
        }
    }
    return NO;
}

/**
 返回到某个不存在的页面
 
 @param viewController 跳转页面class
 @param aClass 前一个页面class
 */
-(void) popToNoExistViewController:(UIViewController *)viewController behindOfViewController:(Class)aClass
{
    if (![self containViewController:aClass]) {
        return;
    }
    
    NSMutableArray *pageArray = [self.viewControllers mutableCopy];
    for (int i = 0; i < pageArray.count; i++)
    {
        id vc = pageArray[i];
        //找到要插入页面的前一个界面
        if ([vc isKindOfClass:aClass])
        {
            //插入界面栈
            [pageArray insertObject:viewController atIndex:i + 1];
            [self setViewControllers:pageArray animated:NO];
            [self popToViewController:viewController animated:YES];
            return;
        }
    }
}

/**
 返回到某个不存在的页面
 
 @param viewController 跳转页面class
 @param aClass 后一个页面class
 */
-(void) popToNoExistViewController:(UIViewController *)viewController inFrontOfTheViewController:(Class)aClass
{
    if (![self containViewController:aClass]) {
        return;
    }
    
    NSMutableArray *pageArray = [self.viewControllers mutableCopy];
    for (int i = 0; i < pageArray.count; i++)
    {
        id vc = pageArray[i];
        //找到要插入页面的后一个界面
        if ([vc isKindOfClass:aClass])
        {
            //插入界面栈
            [pageArray insertObject:viewController atIndex:i];
            [self setViewControllers:pageArray animated:NO];
            [self popToViewController:viewController animated:YES];
            return;
        }
    }
}

/**
 插入一个页面
 */
- (void)insertNoExistViewController:(UIViewController *)viewController behindOfTheViewController:(Class)aClass{
    
    NSMutableArray *pageArray = [self.viewControllers mutableCopy];
    for (NSInteger i = 0; i < pageArray.count; i++) {
        id vc = pageArray[i];
        
        if ([vc isKindOfClass:aClass]) {
            //插入界面
            [pageArray insertObject:viewController atIndex:i + 1];
            [self setViewControllers:pageArray animated:NO];
            return;
        }
    }
    
}

/**
 删除某一个页面
 
 @param vcClass 该页面class
 */
-(void) deleteAppiontViewController:(Class)vcClass
{
    if (![self containViewController:vcClass]) {
        return;
    }
    
    NSMutableArray *pageArray = [self.viewControllers mutableCopy];
    for (int i = 0; i < pageArray.count; i++)
    {
        id vc = pageArray[i];
        //找到要插入页面的后一个界面
        if ([vc isKindOfClass:vcClass])
        {
            //插入界面栈
            [pageArray removeObject:vc];
            [self setViewControllers:pageArray animated:NO];
            return;
        }
    }
}

- (BOOL) containViewController:(Class)aClass
{
    for (UIViewController *vc in self.viewControllers) {
        if ([vc isKindOfClass:aClass]) {
            return YES;
        }
    }
    NSLog(@"当前NavgationController中不存在 ----> %@ !!!",NSStringFromClass(aClass));
    return NO;
}

@end
