//
//  XDocument.m
//  IcouldSyncDemo
//
//  Created by canoe on 2018/1/13.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import "XDocument.h"

@implementation XDocument

#pragma mark - 重写父类方法
/**
 *  保存时调用
 *  @param typeName 文档文件类型后缀
 *  @param outError 错误信息输出
 *  @return 文档数据
 */
- (id)contentsForType:(NSString *)typeName
                error:(NSError *__autoreleasing *)outError
{
    if (self.data) {
        return [self.data copy];
    }
    return [NSData data];
}

/**
 *  读取数据时调用
 *  @param contents 文档数据
 *  @param typeName 文档文件类型后缀
 *  @param outError 错误信息输出
 *  @return 读取是否成功
 */
- (BOOL)loadFromContents:(id)contents
                  ofType:(NSString *)typeName
                   error:(NSError *__autoreleasing *)outError
{
    self.data = [contents copy];
    return true;
}

@end
