//
//  STScrollTitleView.m
//  SenseMeEffects
//
//  Created by Sunshine on 16/08/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import "STScrollTitleView.h"

#define TITLE_MARGIN 25


@interface STScrollTitleView () <UIScrollViewDelegate> {
    CGFloat _currentWidth;
    NSUInteger _currentIndex;
    NSUInteger _oldIndex;
}

@property (nonatomic, readwrite, strong) UIView *pointView;  //选中后title下的小点
@property (nonatomic, readwrite, strong) UIScrollView *scrollView;

//缓存所有标题
@property (nonatomic, readwrite, strong) NSMutableArray *titleViews;
@property (nonatomic, readwrite, strong) NSMutableArray *titleWidths;

@property (nonatomic, readwrite, copy) STTitleOnClickBlock onClickBlock;

@end

@implementation STScrollTitleView

- (instancetype)initWithFrame:(CGRect)frame normalImages:(NSArray *)normalImages selectedImages:(NSArray *)selectedImages effectsType:(NSArray *)effectsType titleOnClick:(STTitleOnClickBlock)onClickBlock {
    
    return [self initWithFrame:frame normalImages:normalImages selectedImages:selectedImages titles:nil effectsType:effectsType titleOnClick:onClickBlock];
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles effectsType:(NSArray *)effectsType titleOnClick:(STTitleOnClickBlock)onClickBlock {
    return [self initWithFrame:frame normalImages:nil selectedImages:nil titles:titles effectsType:effectsType titleOnClick:onClickBlock];
}


- (instancetype)initWithFrame:(CGRect)frame normalImages:(NSArray *)normalImages selectedImages:(NSArray *)selectedImages titles:(NSArray *)titles effectsType:(NSArray *)effectsType titleOnClick:(STTitleOnClickBlock)onClickBlock {
    self = [super initWithFrame:frame];
    if (self) {
        
        _arrNormalImages = normalImages;
        _arrSelectedImages = selectedImages;
        _arrTitles = titles;
        _arrEffectsType = effectsType;
        _onClickBlock = onClickBlock;
        
        _currentIndex = 0;
        _oldIndex = 0;
        _currentWidth = frame.size.width;
        
        _scrollView.delegate = self;
        
        [self addSubview:self.scrollView];
        [self addSubview:self.pointView];
        
        
        [self setupTitleViews];
        [self layoutTitleViews];
    }
    return self;
}

- (void)setupTitleViews {
    
    [self.titleViews removeAllObjects];
    [self.titleWidths removeAllObjects];
    
    if (_arrTitles) {
        
        if (_arrTitles.count == 0) {
            return;
        }
        
        NSInteger index = 0;
        
        for (NSString *title in _arrTitles) {
            STTitleViewItem *titleView = [[STTitleViewItem alloc] initWithFrame:CGRectZero];
            titleView.tag = index;
            
            titleView.effectsType = _arrEffectsType[index].integerValue;
            
            titleView.titleFont = [UIFont systemFontOfSize:15.0];
            titleView.strTitle = title;
            titleView.titleColor = UIColorFromRGB(0x666666);
            titleView.selectedTitleColor = UIColorFromRGB(0xbc47ff);
            titleView.titleViewStyle = STTitleViewStyleOnlyCharacter;
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewOnClick:)];
            [titleView addGestureRecognizer:tapGes];
            
            CGFloat titleViewWidth = [titleView titleViewWidth];
            
            [self.titleWidths addObject:@(titleViewWidth)];
            [self.titleViews addObject:titleView];
            [self.scrollView addSubview:titleView];
            ++index;
        }
        
    } else {
        
        if (_arrNormalImages.count == 0) {
            return;
        }
        NSInteger index = 0;
        
        
        for (UIImage *image in _arrNormalImages) {
            
            STTitleViewItem *titleView = [[STTitleViewItem alloc] initWithFrame:CGRectZero];
            titleView.tag = index;
            titleView.effectsType = _arrEffectsType[index].integerValue;
            
            titleView.normalImage = image;
            titleView.selectedImage = _arrSelectedImages[index];
            titleView.titleViewStyle = STTitleViewStyleOnlyImage;
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewOnClick:)];
            [titleView addGestureRecognizer:tapGes];
            
            CGFloat titleViewWidth = [titleView titleViewWidth];
            
            [self.titleWidths addObject:@(titleViewWidth)];
            [self.titleViews addObject:titleView];
            [self.scrollView addSubview:titleView];
            
            ++index;
        }
    }
    
}

- (void)layoutTitleViews {
    
    if (self.titleViews.count == 0) {
        return;
    }
    
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    
    CGFloat titleX = 0.0;
    CGFloat titleY = 0.0;
    CGFloat titleW = 0.0;
    CGFloat titleH = self.frame.size.height;
    
    NSInteger index = 0;
    float lastLabelMaxX = TITLE_MARGIN;
    float addedMargin = 0.0;
    
//    float allTitlesWidth = TITLE_MARGIN;
//    for (int i = 0; i < self.titleWidths.count; ++i) {
//        allTitlesWidth = allTitlesWidth + [self.titleWidths[i] floatValue] + TITLE_MARGIN;
//    }
//    addedMargin = allTitlesWidth < self.scrollView.bounds.size.width ? (self.scrollView.bounds.size.width - allTitlesWidth) / self.titleWidths.count : 0;
    
    for (STTitleViewItem *titleView in self.titleViews) {
        
        titleW = [self.titleWidths[index] floatValue];
        
        if (index == 0) {
            titleX = lastLabelMaxX / 2;
        } else {
            titleX = lastLabelMaxX + addedMargin / 2;
        }
        
        lastLabelMaxX = titleW + titleX + TITLE_MARGIN;
        
        titleView.frame = CGRectMake(titleX, titleY, titleW, titleH);
        
        [titleView adjustSubviewFrame];
        
        ++index;
    }
    
    STTitleViewItem *currentTitleView = (STTitleViewItem *)self.titleViews[_currentIndex];
    if (currentTitleView) {
        currentTitleView.selected = YES;
        
        if (self.onClickBlock) {
            self.onClickBlock(currentTitleView, currentTitleView.tag, currentTitleView.effectsType);
        }
    }
    
    
    STTitleViewItem *lastTitleView = (STTitleViewItem *)self.titleViews.lastObject;
    if (lastTitleView) {
        self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastTitleView.frame) + 20, 0.0);
    }
}

- (void)titleViewOnClick:(UITapGestureRecognizer *)tapGes {
    
    STTitleViewItem *currentView = (STTitleViewItem *)tapGes.view;
    
    if (!currentView) {
        return;
    }
    
    _currentIndex = currentView.tag;
    
    [self adjustUIWhenTitleViewTaped:YES animated:YES];
}

- (void)adjustUIWhenTitleViewTaped:(BOOL)taped animated:(BOOL)animated {
    if (_currentIndex == _oldIndex && taped) {
        return;
    }
    
    STTitleViewItem *oldTitleView = (STTitleViewItem *)self.titleViews[_oldIndex];
    STTitleViewItem *currentTitleView = (STTitleViewItem *)self.titleViews[_currentIndex];
    
    CGFloat animatedTime = animated ? 0.30 : 0.0;
    
    __weak __typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:animatedTime animations:^{
            
        oldTitleView.selected = NO;
        currentTitleView.selected = YES;
        
    } completion:^(BOOL finished) {
        
        [weakSelf adjustTitleOffsetToCurrentIndex:_currentIndex];
        
    }];
    
    _oldIndex = _currentIndex;
    
    if (self.onClickBlock) {
        self.onClickBlock(currentTitleView, _currentIndex, currentTitleView.effectsType);
    }
}


- (void)reloadTitlesWithNewTitles:(NSArray *)titles effectsType:(NSArray *)effectsType {
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _currentIndex = 0;
    _oldIndex = 0;
    
    [self.titleViews removeAllObjects];
    [self.titleWidths removeAllObjects];
    self.arrTitles = nil;
    self.arrNormalImages = nil;
    self.arrSelectedImages = nil;
    self.arrTitles = [titles copy];
    
    if (self.arrTitles.count == 0) {
        return;
    }
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [self setupTitleViews];
    [self layoutTitleViews];
    [self setSelectedIndex:0 animated:YES];
}

- (void)reloadTitlesWithNewNormalImages:(NSArray *)normalImages selectedImages:(NSArray *)selectedImages effectsType:(NSArray *)effectsType {
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _currentIndex = 0;
    _oldIndex = 0;
    
    [self.titleViews removeAllObjects];
    [self.titleWidths removeAllObjects];
    
    self.arrTitles = nil;
    self.arrNormalImages = nil;
    self.arrSelectedImages = nil;
    
    self.arrNormalImages = [normalImages copy];
    self.arrSelectedImages = [selectedImages copy];
    
    if (self.arrNormalImages.count == 0) {
        return;
    }
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    [self setupTitleViews];
    [self layoutTitleViews];
    [self setSelectedIndex:0 animated:YES];
}

- (void)adjustTitleOffsetToCurrentIndex:(NSInteger)currentIndex {
    _oldIndex = currentIndex;
    
    int index = 0;
    
    for (STTitleViewItem *titleView in _titleViews) {
        if (index != currentIndex) {
            titleView.selected = NO;
        } else {
            titleView.selected = YES;
        }
        ++index;
    }
    
    if (self.scrollView.contentSize.width != self.scrollView.bounds.size.width + 20) {
        
        STTitleViewItem *currentTitleView = (STTitleViewItem *)_titleViews[currentIndex];
        
        CGFloat offsetX = currentTitleView.center.x - _currentWidth * 0.5;
        
        if (offsetX < 0) {
            offsetX = 0;
        }
        
        CGFloat maxOffsetX = self.scrollView.contentSize.width - _currentWidth;
        
        if (maxOffsetX < 0) {
            maxOffsetX = 0;
        }
        
        if (offsetX > maxOffsetX) {
            offsetX = maxOffsetX;
        }
        
        [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];

    }
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated {
    
    _currentIndex = index;
    
    [self adjustUIWhenTitleViewTaped:NO animated:YES];
    
}

- (UIScrollView *)scrollView {
    if(!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.pagingEnabled = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (NSMutableArray *)titleViews {
    if (!_titleViews) {
        _titleViews = [NSMutableArray array];
    }
    return _titleViews;
}

- (NSMutableArray *)titleWidths {
    if (!_titleWidths) {
        _titleWidths = [NSMutableArray array];
    }
    return _titleWidths;
}

@end
