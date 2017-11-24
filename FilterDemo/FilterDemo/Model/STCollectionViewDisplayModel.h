//
//  STCollectionViewDisplayModel.h
//  FilterDemo
//
//  Created by canoe on 2017/11/21.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STParamUtil.h"

@interface STCollectionViewDisplayModel : NSObject
@property (nonatomic, copy) NSString *strPath;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *strName;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, readwrite, assign) STEffectsType modelType;
@end
