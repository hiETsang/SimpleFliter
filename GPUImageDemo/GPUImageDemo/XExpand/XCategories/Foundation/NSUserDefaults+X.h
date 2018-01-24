//
//  NSUserDefaults+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/25.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (X)

+ (NSString *)stringForKey:(NSString *)defaultName;

+ (NSArray *)arrayForKey:(NSString *)defaultName;

+ (NSDictionary *)dictionaryForKey:(NSString *)defaultName;

+ (NSData *)dataForKey:(NSString *)defaultName;

+ (NSArray *)stringArrayForKey:(NSString *)defaultName;

+ (NSInteger)integerForKey:(NSString *)defaultName;

+ (NSURL *)URLForKey:(NSString *)defaultName;

+ (void)setObject:(id)value forKey:(NSString *)defaultName;



+ (float)floatForKey:(NSString *)defaultName;
+ (void)setFloat:(float)value forKey:(NSString *)defaultName;

+ (double)doubleForKey:(NSString *)defaultName;
+ (void)setDouble:(double)value forKey:(NSString *)defaultName;

+ (BOOL)boolForKey:(NSString *)defaultName;
+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName;

@end
