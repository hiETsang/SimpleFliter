//
//  XiCouldManager.m
//  IcouldSyncDemo
//
//  Created by canoe on 2018/1/12.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import "XiCouldManager.h"
#import "XDocument.h"

@interface XiCouldManager ()

@property (strong, nonatomic) NSMetadataQuery *query;  /* 查询文档对象 */

@end

@implementation XiCouldManager

+ (instancetype)sharedManager
{
    static XiCouldManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XiCouldManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self iCloudEnable]) {
            if (!self.query) {
                self.query = [[NSMetadataQuery alloc] init];
                self.query.searchScopes = @[NSMetadataQueryUbiquitousDocumentsScope];
                //注意查询状态是通过通知的形式告诉监听对象的
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataQueryFinish:) name:NSMetadataQueryDidFinishGatheringNotification object:self.query];//数据获取完成通知
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataQueryDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.query];//查询更新通知
            }
            //开始查询
            [self.query startQuery];
        }
    }
    return self;
}

-(void)reloadMetadataQuery
{
    [self.query startQuery];
}

-(void)metadataQueryFinish:(NSNotification *)notification
{
    NSLog(@"metadataQueryFinish数据获取成功！");
    if (self.MetadataQueryDidFinishGathering) {
        self.MetadataQueryDidFinishGathering(self.query.results);
    }
}

-(void)metadataQueryDidUpdate:(NSNotification *)notification
{
    NSLog(@"metadataQueryUpdate数据获取成功！");
    if (self.MetadataQueryDidUpdate) {
        self.MetadataQueryDidUpdate(self.query.results);
    }
}

- (BOOL)iCloudEnable {
    
    // 获得文件管理器
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // 判断iCloud是否可用
    // 参数传nil表示使用默认容器
    NSURL *url = [manager URLForUbiquityContainerIdentifier:nil];
    // 如果URL不为nil, 则表示可用
    if (url != nil) {
        
        return YES;
    }
    
    NSLog(@"iCloud 不可用");
    return NO;
}

- (BOOL)isExistIniCloudByName:(NSString *)name
{
    NSURL *iCloudUrl = [self iCloudFilePathByName:name];
    NSFileManager *manager  = [NSFileManager defaultManager];
    return [manager isUbiquitousItemAtURL:iCloudUrl];
}


- (NSURL *)iCloudFilePathByName:(NSString *)name {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // 判断iCloud是否可用
    // 参数传nil表示使用默认容器
    NSURL *url = [manager URLForUbiquityContainerIdentifier:nil];
    
    if (url == nil) {
        
        return nil;
    }
    
    url = [url URLByAppendingPathComponent:@"Documents"];
    NSURL *iCloudPath = [NSURL URLWithString:name relativeToURL:url];
//    NSLog(@"%@", iCloudPath);
    return iCloudPath;
}

// 本地的文件路径生成URL
- (NSURL *)localFileUrl:(NSString *)fileName {
    
    // 获取Documents目录
    NSURL *fileUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    // 拼接文件名称
    NSURL *url = [fileUrl URLByAppendingPathComponent:fileName];
//    NSLog(@"%@", url);
    return url;
}

- (void)uploadToiCloud:(NSString *)name localFile:(NSString *)localFile callBack:(loadBlock)block {
    
    NSURL *iCloudUrl = [self iCloudFilePathByName:name];
    NSURL *localUrl = [self localFileUrl:localFile];
    
    XDocument *localDoc = [[XDocument alloc]initWithFileURL:localUrl];
    XDocument *iCloudDoc = [[XDocument alloc]initWithFileURL:iCloudUrl];
    
    [localDoc openWithCompletionHandler:^(BOOL success) {
        if (success) {
            iCloudDoc.data = localDoc.data;
            [iCloudDoc saveToURL:iCloudUrl forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                
                [localDoc closeWithCompletionHandler:^(BOOL success) {
                }];
                
                if (block) {
                    block(success);
                }
            }];
        }
    }];
}

- (void)downloadFromiCloud:(NSString*)name localfile:(NSString*)localFile callBack:(downloadBlock)block {
    
    NSURL *iCloudUrl = [self iCloudFilePathByName:name];
    NSURL *localUrl = [self localFileUrl:localFile];
    
    XDocument *localDoc = [[XDocument alloc]initWithFileURL:localUrl];
    XDocument *iCloudDoc = [[XDocument alloc]initWithFileURL:iCloudUrl];
    
    [iCloudDoc openWithCompletionHandler:^(BOOL success) {
        if (success) {
            
            localDoc.data = iCloudDoc.data;
            [localDoc saveToURL:localUrl forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                [iCloudDoc closeWithCompletionHandler:^(BOOL success) {
                }];
                
                if (block) {
                    block(success,localDoc.data);
                }
            }];
        }
    }];
}

- (BOOL)removeFileIniCloud:(NSString *)name
{
    if (name.length <= 0) {
        NSLog(@"请传入需要删除的文件名 ！");
        return NO;
    }
    
    if ([self isExistIniCloudByName:name] == NO) {
        NSLog(@"需要删除的文件不存在 ！");
        return YES;
    }
    
    NSURL *url = [self iCloudFilePathByName:name];
    NSError *error = nil;
    //删除文档文件
    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (error) {
        NSLog(@"删除文档过程中发生错误，错误信息：%@",error.localizedDescription);
        return NO;
    }else
    {
        return YES;
    }
}


@end
