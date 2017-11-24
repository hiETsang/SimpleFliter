//
//  STParamUtil.m
//
//  Created by HaifengMay on 16/11/5.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

#import "STParamUtil.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>

@implementation STParamUtil

+ (float)getCpuUsage
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

+ (NSArray *)getFilterModelPaths
{
    NSFileManager *fileManger = [[NSFileManager alloc] init];
    
    NSString *strBundlePath = [[NSBundle mainBundle] resourcePath];
    
    NSArray *arrFileNames = [fileManger contentsOfDirectoryAtPath:strBundlePath error:nil];
    
    NSMutableArray *arrModels = [NSMutableArray array];
    
    for (NSString *strFileName in arrFileNames) {
        
        if ([strFileName hasSuffix:@"model"]
            &&
            [strFileName hasPrefix:@"filter_style"]
            ) {
            
            [arrModels addObject:[NSString pathWithComponents:@[strBundlePath , strFileName]]];
        }
    }
    
    NSString *strDocumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    arrFileNames = [fileManger contentsOfDirectoryAtPath:strDocumentsPath error:nil];
    
    for (NSString *strFileName in arrFileNames) {
        
        if ([strFileName hasSuffix:@"model"]
            &&
            [strFileName hasPrefix:@"filter_style"]
            ) {
            
            [arrModels addObject:[NSString pathWithComponents:@[strDocumentsPath , strFileName]]];
        }
    }
    
    return arrModels;
}

+ (NSArray *)getStickerZipPaths
{
    NSFileManager *fileManger = [[NSFileManager alloc] init];
    
    NSString *strBundlePath = [[NSBundle mainBundle] resourcePath];
    
    NSArray *arrFileNames = [fileManger contentsOfDirectoryAtPath:strBundlePath error:nil];
    
    NSMutableArray *arrZipPaths = [NSMutableArray array];
    
    for (NSString *strFileName in arrFileNames) {
        
        if ([strFileName hasSuffix:@"zip"]) {
            
            [arrZipPaths addObject:[NSString pathWithComponents:@[strBundlePath , strFileName]]];
        }
    }
    
    NSString *strDocumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    arrFileNames = [fileManger contentsOfDirectoryAtPath:strDocumentsPath error:nil];
    
    for (NSString *strFileName in arrFileNames) {
        
        if ([strFileName hasSuffix:@"zip"]) {
            
            [arrZipPaths addObject:[NSString pathWithComponents:@[strDocumentsPath , strFileName]]];
        }
    }
    
    return [arrZipPaths copy];
}

+ (NSArray *)getTrackerPaths {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSString *strBundlePath = [[NSBundle mainBundle] resourcePath];
    
    NSArray *arrFileNames = [fileManager contentsOfDirectoryAtPath:strBundlePath error:nil];
    
    NSMutableArray *arrPaths = [NSMutableArray array];
    
    for (NSString *strFileName in arrFileNames) {
        
        if ([strFileName hasPrefix:@"common_object"]) {
            
            [arrPaths addObject:[NSString pathWithComponents:@[strBundlePath, strFileName]]];
        }
    }
    
    NSString *strDocumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    arrFileNames = [fileManager contentsOfDirectoryAtPath:strDocumentsPath error:nil];
    
    for (NSString *strFileName in arrFileNames) {
        
        if ([strFileName hasPrefix:@"common_object"]) {
            
            [arrPaths addObject:[NSString pathWithComponents:@[strDocumentsPath, strFileName]]];
        }
    }
    
    return [arrPaths copy];
}

+ (NSArray *)getStickerPathsByType:(STEffectsType)type {
    
    NSString *strPrefix;
    
    switch (type) {
        case STEffectsTypeSticker2D:
            strPrefix = @"2d_sticker";
            break;
            
        case STEffectsTypeSticker3D:
            strPrefix = @"3d_sticker";
            break;
            
        case STEffectsTypeStickerGesture:
            strPrefix = @"hand_gesture_sticker";
            break;
            
        case STEffectsTypeStickerFaceDeformation:
            strPrefix = @"deformation_sticker";
            break;
            
        case STEffectsTypeStickerSegment:
            strPrefix = @"segment_sticker";
            break;
            
        case STEffectsTypeBeautyFilter:
            strPrefix = @"filter_";
            break;
            
        default:
            break;
    }
    
    
    NSFileManager *fileManger = [[NSFileManager alloc] init];
    
    NSString *strBundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[strPrefix stringByAppendingString:@".bundle"]];
    
    NSArray *arrFileNames = [fileManger contentsOfDirectoryAtPath:strBundlePath error:nil];
    
    NSMutableArray *arrZipPaths = [NSMutableArray array];
    
    for (NSString *strFileName in arrFileNames) {
        
        if ([strFileName hasSuffix:@"zip"]) {
            
            [arrZipPaths addObject:[NSString pathWithComponents:@[strBundlePath , strFileName]]];
        }
    }
    
    NSString *strDocumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *sticker2dPath = [strDocumentsPath stringByAppendingPathComponent:@"2d_sticker"];
    NSString *sticker3dPath = [strDocumentsPath stringByAppendingPathComponent:@"3d_sticker"];
    NSString *stickerHandGesturePath = [strDocumentsPath stringByAppendingPathComponent:@"hand_gesture_sticker"];
    NSString *stickerSegmentPath = [strDocumentsPath stringByAppendingPathComponent:@"segment_sticker"];
    NSString *stickerDeformationPath = [strDocumentsPath stringByAppendingPathComponent:@"deformation_sticker"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:sticker2dPath]) {
        [fileManger createDirectoryAtPath:sticker2dPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:sticker3dPath]) {
        [fileManger createDirectoryAtPath:sticker3dPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:stickerHandGesturePath]) {
        [fileManger createDirectoryAtPath:stickerHandGesturePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:stickerSegmentPath]) {
        [fileManger createDirectoryAtPath:stickerSegmentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:stickerDeformationPath]) {
        [fileManger createDirectoryAtPath:stickerDeformationPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *stickerPath = [strDocumentsPath stringByAppendingPathComponent:strPrefix];
    
    arrFileNames = [fileManger contentsOfDirectoryAtPath:stickerPath error:nil];
    
    for (NSString *strFileName in arrFileNames) {
        
        if ([strFileName hasSuffix:@"zip"]) {
            
            [arrZipPaths addObject:[NSString pathWithComponents:@[stickerPath , strFileName]]];
        }
    }
    
    return [arrZipPaths copy];
}

@end
