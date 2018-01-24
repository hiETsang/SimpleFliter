//
//  NSObject+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/8.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (X)
/*!
 *  替换两个方法
 *
 *   className
 *   originalSelector 原始方法
 *   swizzledSelector 替换的方法
 */
+ (void)aop_originalSelector:(SEL _Nullable )originalSelector
            swizzledSelector:(SEL _Nullable )swizzledSelector;

@end

#pragma mark - 对象添加
@interface NSObject (XAssociatedObject)
/**
 *  @brief  附加一个stong对象
 *
 *  @param value 被附加的对象
 *  @param key   被附加对象的key
 */
- (void)associateValue:(id _Nullable )value withKey:(void *_Nullable)key; // Strong reference
/**
 *  @brief  附加一个weak对象
 *
 *  @param value 被附加的对象
 *  @param key   被附加对象的key
 */
- (void)weaklyAssociateValue:(id _Nullable )value withKey:(void *_Nullable)key;

/**
 *  @brief  根据附加对象的key取出附加对象
 *
 *  @param key 附加对象的key
 *
 *  @return 附加对象
 */
- (id _Nullable )associatedValueForKey:(void *_Nullable)key;
@end



#pragma mark - KVO

@interface NSObject (XKVOBlocks)
/**
 KVO

 @param keyPath 需要监听变化的属性
 @param block 变化返回的block
 */
- (void)addObserverBlockForKeyPath:(NSString*_Nullable)keyPath
                             block:(void (^_Nullable)(id _Nonnull obj, id _Nonnull oldVal, id _Nonnull newVal))block;

/**
 移除需要监听的属性

 @param keyPath 需要监听变化的属性
 */
- (void)removeObserverBlocksForKeyPath:(NSString*_Nullable)keyPath;

/**
 移除所有监听的block
 */
- (void)removeObserverBlocks;
@end


#pragma mark - 便捷方法
@interface NSObject (XReflection)
//类名
- (NSString *_Nonnull)className;
+ (NSString *_Nonnull)className;
//父类名称
- (NSString *_Nonnull)superClassName;
+ (NSString *_Nonnull)superClassName;

//实例属性字典
-(NSDictionary *_Nullable)propertyDictionary;

//属性名称列表
- (NSArray*_Nullable)propertyKeys;
+ (NSArray *_Nullable)propertyKeys;

//属性详细信息列表
- (NSArray *_Nullable)propertiesInfo;
+ (NSArray *_Nullable)propertiesInfo;

//格式化后的属性列表
+ (NSArray *_Nullable)propertiesWithCodeFormat;

//方法列表
-(NSArray*_Nullable)methodList;
+(NSArray*_Nullable)methodList;

-(NSArray*_Nullable)methodListInfo;

//创建并返回一个指向所有已注册类的指针列表
+ (NSArray *_Nullable)registedClassList;
//实例变量
+ (NSArray *_Nullable)instanceVariable;

//协议列表
-(NSDictionary *_Nullable)protocolList;
+ (NSDictionary *_Nullable)protocolList;


- (BOOL)hasPropertyForKey:(NSString*_Nonnull)key;
- (BOOL)hasIvarForKey:(NSString*_Nonnull)key;

@end
