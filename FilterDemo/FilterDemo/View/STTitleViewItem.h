//
//  STTitleView.h
//  SenseMeEffects
//
//  Created by Sunshine on 16/08/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STParamUtil.h"

@interface STTitleViewItem : UIView

@property (nonatomic, readwrite, assign) STTitleViewStyle titleViewStyle;
@property (nonatomic, readwrite, assign) STEffectsType effectsType;

@property (nonatomic, readwrite, assign, getter=isSelected) BOOL selected;

@property (nonatomic, readwrite, strong) UIImage *normalImage;
@property (nonatomic, readwrite, strong) UIImage *selectedImage;
@property (nonatomic, readwrite, strong) UIImageView *imageView;

@property (nonatomic, readwrite, strong) UILabel *titleLabel;
@property (nonatomic, readwrite, copy) NSString *strTitle;
@property (nonatomic, readwrite, strong) UIColor *titleColor;
@property (nonatomic, readwrite, strong) UIColor *selectedTitleColor;
@property (nonatomic, readwrite, strong) UIFont *titleFont;

- (CGFloat)titleViewWidth;
- (void)adjustSubviewFrame;

@end
