//
//  XPlistFileManager.h
//  IcouldSyncDemo
//
//  Created by canoe on 2018/1/12.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XPlistFileManager : NSObject

//沙盒路径
+ (NSString *)documentsDirectory;

//判断沙盒Doucument路径下是否有某文件
+ (BOOL)isExistInSandBoxDoucumentWithFileName:(NSString *)fileName;

//新建plist文件，如果该文件已经存在，那么则会覆盖掉原来的内容
+ (NSString *)createPlistInSandBoxDoucumentWithContent:(id)content name:(NSString *)name;

//删除plist文件
+ (BOOL)deletePlistInSandBoxDoucumentWithFileName:(NSString *)fileName;

//获取plist文件路径
+ (NSString *)getPlistPathWithName:(NSString *)name;

@end
