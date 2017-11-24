//
//  STCollectionViewCell.h
//
//  Created by HaifengMay on 16/11/8.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STParamUtil.h"

@interface STCollectionViewCell : UICollectionViewCell

@property (nonatomic , strong) UIImageView *imageView;
@property (nonatomic, readwrite, strong) UIView *maskView;

@end

@interface STCollectionLabelCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *lblName;
@property (nonatomic, strong) UIView *imageMaskView;
@property (nonatomic, strong) UIView *lblMaskView;
@property (nonatomic, strong) UIView *maskContainerView;
@end
