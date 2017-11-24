//
//  LVGetEffectsSourceTool.m
//  FilterDemo
//
//  Created by canoe on 2017/11/21.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "LVGetEffectsSourceTool.h"
#import "LVFaceDealHeader.h"

@implementation LVGetEffectsSourceTool
#pragma mark - 检查 license
+ (BOOL)checkActiveCode
{
    //读取SenseME.lic文件的内容
    NSString *strLicensePath = [[NSBundle mainBundle] pathForResource:@"SENSEME" ofType:@"lic"];
    NSData *dataLicense = [NSData dataWithContentsOfFile:strLicensePath];
    
    NSString *strKeySHA1 = @"SENSEME";
    NSString *strKeyActiveCode = @"ACTIVE_CODE";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *strStoredSHA1 = [userDefaults objectForKey:strKeySHA1];
    NSString *strLicenseSHA1 = [LVGetEffectsSourceTool getSHA1StringWithData:dataLicense];
    
    st_result_t iRet = ST_OK;
    if (strStoredSHA1.length > 0 && [strLicenseSHA1 isEqualToString:strStoredSHA1]) {
        
        // Get current active code
        // In this app active code was stored in NSUserDefaults
        // It also can be stored in other places
        NSData *activeCodeData = [userDefaults objectForKey:strKeyActiveCode];
        //检查激活码是否可用
        iRet = st_mobile_check_activecode(strLicensePath.UTF8String,(const char *)[activeCodeData bytes],(int)[activeCodeData length]);
        if (ST_OK == iRet) {
            // check success
            return YES;
        }
    }
    
    //如果检查失败，重新生成一个，并更新本地激活码
    char active_code[1024];
    int active_code_len = 1024;
    // use file
    iRet = st_mobile_generate_activecode(
                                         strLicensePath.UTF8String,
                                         active_code,
                                         &active_code_len
                                         );
    
    if (ST_OK != iRet) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"使用 license 文件生成激活码时失败，可能是授权文件过期。" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return NO;
        
    } else {
        
        // Store active code
        NSData *activeCodeData = [NSData dataWithBytes:active_code length:active_code_len];
        
        [userDefaults setObject:activeCodeData forKey:strKeyActiveCode];
        [userDefaults setObject:strLicenseSHA1 forKey:strKeySHA1];
        
        [userDefaults synchronize];
    }
    
    return YES;
}

+ (NSString *)getSHA1StringWithData:(NSData *)data
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *strSHA1 = [NSMutableString string];
    
    for (int i = 0 ; i < CC_SHA1_DIGEST_LENGTH ; i ++) {
        
        [strSHA1 appendFormat:@"%02x" , digest[i]];
    }
    
    return strSHA1;
}




#pragma mark - 获取贴纸滤镜等数组

+ (NSArray *)getStickerModelsByType:(STEffectsType)type {
    
    NSArray *stickerZipPaths = [STParamUtil getStickerPathsByType:type];
    
    NSMutableArray *arrModels = [NSMutableArray array];
    
    for (int i = 0; i < stickerZipPaths.count; i ++) {
        
        STCollectionViewDisplayModel *model = [[STCollectionViewDisplayModel alloc] init];
        model.strPath = stickerZipPaths[i];
        
        UIImage *thumbImage = [UIImage imageWithContentsOfFile:[[model.strPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"]];
        model.image = thumbImage ? thumbImage : [UIImage imageNamed:@"none.png"];
        model.strName = @"";
        model.index = i;
        model.isSelected = NO;
        model.modelType = type;
        
        [arrModels addObject:model];
    }
    return [arrModels copy];
}

+ (NSArray *)getFilterModels {
    
    NSArray *filterZipPaths = [STParamUtil getFilterModelPaths];
    
    NSMutableArray *arrModels = [NSMutableArray array];
    
    STCollectionViewDisplayModel *model1 = [[STCollectionViewDisplayModel alloc] init];
    model1.strPath = NULL;
    model1.strName = @"nature";
    model1.image = [UIImage imageNamed:@"filter_style_original.png"];
    model1.index = 0;
    model1.isSelected = YES;
    model1.modelType = STEffectsTypeBeautyFilter;
    [arrModels addObject:model1];
    
    STCollectionViewDisplayModel *model2 = [[STCollectionViewDisplayModel alloc] init];
    model2.strPath = NULL;
    model2.image = [UIImage imageNamed:@"filter_style_original.png"];
    model2.strName = @"null";
    model2.index = 1;
    model2.isSelected = NO;
    model2.modelType = STEffectsTypeBeautyFilter;
    [arrModels addObject:model2];
    
    for (int i = 2; i < filterZipPaths.count + 2; ++i) {
        
        STCollectionViewDisplayModel *model = [[STCollectionViewDisplayModel alloc] init];
        model.strPath = filterZipPaths[i - 2];
        model.strName = [[model.strPath.lastPathComponent stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"filter_style_" withString:@""];
        
        UIImage *thumbImage = [UIImage imageWithContentsOfFile:[[model.strPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"]];
        
        model.image = thumbImage ?: [UIImage imageNamed:@"none"];
        model.index = i;
        model.isSelected = NO;
        model.modelType = STEffectsTypeBeautyFilter;
        
        [arrModels addObject:model];
    }
    return [arrModels copy];
}

+ (NSArray *)getObjectTrackModels {
    
    NSArray *objectTrackPaths = [STParamUtil getTrackerPaths];
    
    NSMutableArray *arrModels = [NSMutableArray array];
    
    for (int i = 0; i < objectTrackPaths.count; ++i) {
        
        STCollectionViewDisplayModel *model = [[STCollectionViewDisplayModel alloc] init];
        
        model.strPath = objectTrackPaths[i];
        UIImage *thumbImage = [UIImage imageWithContentsOfFile:model.strPath];
        
        model.image = thumbImage ?: [UIImage imageNamed:@"none"];
        model.strName = @"";
        model.index = i;
        model.isSelected = NO;
        model.modelType = STEffectsTypeObjectTrack;
        
        [arrModels addObject:model];
    }
    return [arrModels copy];
}



@end
