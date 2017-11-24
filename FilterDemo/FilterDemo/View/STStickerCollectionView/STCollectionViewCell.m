//
//  STCollectionViewCell.m
//
//  Created by HaifengMay on 16/11/8.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

#import "STCollectionViewCell.h"

@interface STCollectionViewCell ()

@end


@implementation STCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.cornerRadius = 5;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 10)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.imageView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.imageView];
        
        self.maskView = [[UIView alloc] initWithFrame:self.bounds];
        self.maskView.backgroundColor = UIColorFromRGB(0x000000);
        self.maskView.alpha = 0.5;
        self.maskView.layer.cornerRadius = 5;
        self.maskView.layer.borderWidth = 6 / [UIScreen mainScreen].scale;
        self.maskView.layer.borderColor = [UIColor clearColor].CGColor;
        self.maskView.hidden = YES;
        [self addSubview:self.maskView];
        
    }
    return self;
}
@end

@implementation STCollectionLabelCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.cornerRadius = 7.0;
        
        self.layer.shadowColor = UIColorFromRGB(0x472b68).CGColor;
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowOffset = CGSizeZero;
        
        self.maskContainerView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, self.frame.size.width - 4, self.frame.size.height - 4)];
        self.maskContainerView.layer.cornerRadius = 7.0;
        self.maskContainerView.clipsToBounds = YES;
        self.maskContainerView.backgroundColor = [UIColor clearColor];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.maskContainerView.bounds;
        gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xc460e1).CGColor, (__bridge id)UIColorFromRGB(0x7fd8ee).CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        [self.maskContainerView.layer addSublayer:gradientLayer];
        self.maskContainerView.hidden = YES;
        [self addSubview:self.maskContainerView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, self.frame.size.width - 4, self.frame.size.height - 20)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.cornerRadius = 7.0;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectMake(2, CGRectGetMaxY(self.imageView.frame), CGRectGetWidth(self.imageView.frame), 20)];
        self.lblName.textAlignment = NSTextAlignmentCenter;
        self.lblName.font = [UIFont systemFontOfSize:11];
        self.lblName.textColor = UIColorFromRGB(0x555555);
        self.lblName.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:self.lblName];
        
        self.imageMaskView = [[UIView alloc] initWithFrame:self.imageView.bounds];
        self.imageMaskView.alpha = 0.5;
        self.imageMaskView.backgroundColor = [UIColor blackColor];
        self.imageMaskView.hidden = YES;
        [self.imageView addSubview:self.imageMaskView];
        
    }
    return self;
}

@end
