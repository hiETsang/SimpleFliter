//
//  STTitleView.m
//  SenseMeEffects
//
//  Created by Sunshine on 16/08/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import "STTitleViewItem.h"

@interface STTitleViewItem ()

@property (nonatomic, readwrite, assign) CGSize titleSize;
@property (nonatomic, readwrite, assign) CGFloat imageHeight;
@property (nonatomic, readwrite, assign) CGFloat imageWidth;
@property (nonatomic, readwrite, assign, getter=isShowImage) BOOL showImage;
@property (nonatomic, readwrite, strong) UIView *contentView;

@property (nonatomic, readwrite, strong) UIView *pointView;

@end

@implementation STTitleViewItem

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)adjustSubviewFrame {
    
    CGRect contentViewFrame = self.bounds;
    contentViewFrame.size.width = [self titleViewWidth];
    contentViewFrame.origin.x = (self.frame.size.width - contentViewFrame.size.width) / 2;
    self.contentView.frame = contentViewFrame;
    
    [self addSubview:self.contentView];
    
    switch (self.titleViewStyle) {
            
        case STTitleViewStyleOnlyImage:
            self.imageView.frame = self.contentView.bounds;
            [self.contentView addSubview:self.imageView];
            break;
            
        case STTitleViewStyleOnlyCharacter:
            self.titleLabel.frame = self.contentView.bounds;
            [self.contentView addSubview:self.titleLabel];
            break;
            
        default:
            break;
    }
    
    self.pointView.center = CGPointMake(self.contentView.center.x, CGRectGetMaxY(self.contentView.frame) - 3);
    [self addSubview:self.pointView];
    self.pointView.hidden = YES;
}

- (CGFloat)titleViewWidth {
    CGFloat width = 0.0f;
    
    switch (self.titleViewStyle) {
            
        case STTitleViewStyleOnlyImage:
            width = _imageWidth;
            break;
            
        case STTitleViewStyleOnlyCharacter:
            width = _titleSize.width;
            break;
            
        default:
            break;
    }
    return width;
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    _imageWidth = normalImage.size.width;
    _imageHeight = normalImage.size.height;
    
    self.imageView.image = normalImage;
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    self.imageView.highlightedImage = selectedImage;
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
}

- (void)setStrTitle:(NSString *)strTitle {
    _strTitle = strTitle;
    self.titleLabel.text = strTitle;
    
    CGRect bounds = [strTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.titleLabel.font} context:nil];
    _titleSize = bounds.size;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.imageView.highlighted = selected;
    self.titleLabel.highlighted = selected;
    self.pointView.hidden = !selected;
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor;
    self.titleLabel.highlightedTextColor = selectedTitleColor;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UIView *)pointView {
    
    if (!_pointView) {
        
        _pointView = [[UIView alloc] init];
        _pointView.frame = CGRectMake(0, 0, 6, 6);
        _pointView.layer.cornerRadius = 3;
        _pointView.backgroundColor = UIColorFromRGB(0xbc47ff);
        _pointView.alpha = 0.6;
    }
    return _pointView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
