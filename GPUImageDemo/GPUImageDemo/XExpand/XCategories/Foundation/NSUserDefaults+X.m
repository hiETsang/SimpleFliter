//
//  NSUserDefaults+X.m
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/25.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "NSUserDefaults+X.h"

@implementation NSUserDefaults (X)
+ (NSString *)stringForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:defaultName];
}

+ (NSArray *)arrayForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:defaultName];
}

+ (NSDictionary *)dictionaryForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:defaultName];
}

+ (NSData *)dataForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] dataForKey:defaultName];
}

+ (NSArray *)stringArrayForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] stringArrayForKey:defaultName];
}

+ (NSInteger)integerForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] integerForKey:defaultName];
}

+ (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (float)floatForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] floatForKey:defaultName];
}
+ (void)setFloat:(float)value forKey:(NSString *)defaultName
{
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (double)doubleForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:defaultName];
}
+ (void)setDouble:(double)value forKey:(NSString *)defaultName
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)boolForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:defaultName];
}
+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSURL *)URLForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] URLForKey:defaultName];
}

#pragma mark - WRITE FOR STANDARD

+ (void)setObject:(id)value forKey:(NSString *)defaultName {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
