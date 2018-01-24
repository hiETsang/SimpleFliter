//
//  XiCouldManager.h
//  IcouldSyncDemo
//
//  Created by canoe on 2018/1/12.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^loadBlock)(BOOL success);

typedef void(^downloadBlock)(BOOL success,id obj);

@interface XiCouldManager : NSObject

+ (instancetype)sharedManager;

/**
 iCloud是否可用
 */
- (BOOL)iCloudEnable;

/**
 iCloud是否存在某文件

 @param name 文件名
 @return 存在：YES  不存在：NO
 */
- (BOOL)isExistIniCloudByName:(NSString *)name;

/**
 获取icloud中文件的路径

 @param name 文件名
 @return 文件路径，不存在文件返回nil
 */
- (NSURL *)iCloudFilePathByName:(NSString *)name;

/**
 获取本地文件路径

 @param fileName 文件名
 @return 文件路径，不存在返回nil
 */
- (NSURL *)localFileUrl:(NSString *)fileName;

/**
 上传文件到iCloud，不存在则新建，存在则覆盖

 @param name 存储在iCloud中的名称
 @param localFile 本地文件名称
 @param block 保存状态
 */
- (void)uploadToiCloud:(NSString *)name localFile:(NSString *)localFile callBack:(loadBlock)block ;

/**
 下载iCloud文件到本地沙盒，沙盒中存在则覆盖，不存在则新建

 @param name iCloud文件名
 @param localFile 存储在本地的文件名
 @param block 下载下来的Data数据
 */
- (void)downloadFromiCloud:(NSString*)name localfile:(NSString*)localFile callBack:(downloadBlock)block;

/**
 删除iCloud中的文件名

 @param name 文件名
 @return 删除是否成功，不存在该文件返回YES
 */
- (BOOL)removeFileIniCloud:(NSString *)name;

/**
 MetadataQueryDidFinishGathering iCloud文件索引完成后通知回调(只在初始化的时候回调一次)
 */
@property (nonatomic,copy) void (^MetadataQueryDidFinishGathering)(NSArray<NSMetadataItem *>*array);
-(void)setMetadataQueryDidFinishGathering:(void (^)(NSArray<NSMetadataItem *>*array))MetadataQueryDidFinishGathering;

/**
 MetadataQueryDidUpdate iCloud得到文档数据和修改文档数据时调用(每次更新icloud文件会自动多次回调)
 */
@property (nonatomic,copy) void (^MetadataQueryDidUpdate)(NSArray<NSMetadataItem *>*array);
-(void)setMetadataQueryDidUpdate:(void (^)(NSArray<NSMetadataItem *> *array))MetadataQueryDidUpdate;


@end
