//
//  XPlistFileManager.m
//  IcouldSyncDemo
//
//  Created by canoe on 2018/1/12.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import "XPlistFileManager.h"

@implementation XPlistFileManager

+(NSString *)documentsDirectory
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

//判断沙盒doucment目录下是否存在某文件
+(BOOL)isExistInSandBoxDoucumentWithFileName:(NSString *)fileName
{
    NSString *filePath = [[XPlistFileManager documentsDirectory] stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath])
    {
        NSLog(@"文件不存在");
        return NO;
    }else{
        NSLog(@"文件存在");
        return YES;
    }
}

+(NSString *)createPlistInSandBoxDoucumentWithContent:(id)content name:(NSString *)name
{
    NSString *filePath = [[XPlistFileManager documentsDirectory] stringByAppendingPathComponent:name];
    [content writeToFile:filePath atomically:YES];
    
    return filePath;
}

+(BOOL)deletePlistInSandBoxDoucumentWithFileName:(NSString *)fileName
{
    NSString *filePath = [[XPlistFileManager documentsDirectory] stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath])
    {
        NSLog(@"文件本来就不存在");
        return YES;
    }else{
        return [fileManager removeItemAtPath:filePath error:nil];
    }
}

+(NSString *)getPlistPathWithName:(NSString *)name
{
    return [[XPlistFileManager documentsDirectory] stringByAppendingPathComponent:name];
}

@end
