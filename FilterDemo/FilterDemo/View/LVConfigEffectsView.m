//
//  LVConfigEffectsView.m
//  FilterDemo
//
//  Created by canoe on 2017/11/21.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "LVConfigEffectsView.h"
#import "LVFaceDealHeader.h"
#import "LVGetEffectsSourceTool.h"


@implementation LVConfigEffectsView

#pragma mark - 模型数组懒加载
- (NSArray *)arr2DStickers {
    if (!_arr2DStickers) {
        _arr2DStickers = [LVGetEffectsSourceTool getStickerModelsByType:STEffectsTypeSticker2D];
    }
    return _arr2DStickers;
}

- (NSArray *)arr3DStickers {
    if (!_arr3DStickers) {
        _arr3DStickers = [LVGetEffectsSourceTool getStickerModelsByType:STEffectsTypeSticker3D];
    }
    return _arr3DStickers;
}

- (NSArray *)arrGestureStickers {
    if (!_arrGestureStickers) {
        _arrGestureStickers = [LVGetEffectsSourceTool getStickerModelsByType:STEffectsTypeStickerGesture];
    }
    return _arrGestureStickers;
}

- (NSArray *)arrSegmentStickers {
    if (!_arrSegmentStickers) {
        _arrSegmentStickers = [LVGetEffectsSourceTool getStickerModelsByType:STEffectsTypeStickerSegment];
    }
    return _arrSegmentStickers;
}

- (NSArray *)arrFacedeformationStickers {
    if (!_arrFacedeformationStickers) {
        _arrFacedeformationStickers = [LVGetEffectsSourceTool getStickerModelsByType:STEffectsTypeStickerFaceDeformation];
    }
    return _arrFacedeformationStickers;
}

- (NSArray *)arrObjectTrackers {
    if (!_arrObjectTrackers) {
        _arrObjectTrackers = [LVGetEffectsSourceTool getObjectTrackModels];
    }
    return _arrObjectTrackers;
}

- (NSArray *)arrFilters {
    if (!_arrFilters) {
        _arrFilters = [LVGetEffectsSourceTool getFilterModels];
    }
    return _arrFilters;
}

- (NSMutableArray *)arrBeautyViews {
    if (!_arrBeautyViews) {
        _arrBeautyViews = [NSMutableArray array];
    }
    return _arrBeautyViews;
}

#pragma mark - 美颜的子View  (顶部滚动，滤镜，基础美颜，美形)
- (STScrollTitleView *)beautyScrollTitleView {
    if (!_beautyScrollTitleView) {
        
        STWeakSelf;
        
        _beautyScrollTitleView = [[STScrollTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40) titles:@[@"滤镜", @"基础美颜", @"美形"] effectsType:@[@(STEffectsTypeBeautyFilter), @(STEffectsTypeBeautyBase), @(STEffectsTypeBeautyShape)] titleOnClick:^(STTitleViewItem *titleView, NSInteger index, STEffectsType type) {
            [weakSelf handleEffectsType:type];
        }];
        _beautyScrollTitleView.backgroundColor = UIColorFromRGB(0xffffff);
        _beautyScrollTitleView.alpha = 0.6;
    }
    return _beautyScrollTitleView;
}

- (STCollectionView *)beautyCollectionView {
    
    if (!_beautyCollectionView) {
        
        __weak typeof(self) weakSelf = self;
        _beautyCollectionView = [[STCollectionView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 120) withModels:nil andDelegateBlock:^(STCollectionViewDisplayModel *model) {
            weakSelf.noneStickerImageView.highlighted = NO;
            if ([weakSelf.delegate respondsToSelector:@selector(didSelectedFilterModel:)]) {
                [weakSelf.delegate didSelectedFilterModel:model];
            }
        }];
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(65, 90);
        
        flowLayout.minimumLineSpacing = 5;
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        
        [_beautyCollectionView setCollectionViewLayout:flowLayout];
        
        _beautyCollectionView.arrFilterModels = self.arrFilters;
        _beautyCollectionView.backgroundColor = UIColorFromRGB(0xffffff);
        _beautyCollectionView.alpha = 0.85;
        
    }
    return _beautyCollectionView;
    
}


- (UIView *)beautyBaseView {
    
    if (!_beautyBaseView) {
        
        _beautyBaseView = [[UIView alloc] initWithFrame:self.beautyCollectionView.frame];
        
        STSliderView *dermabrasionView = [[[NSBundle mainBundle] loadNibNamed:@"STSliderView" owner:nil options:nil] firstObject];
        dermabrasionView.frame = CGRectMake(0, 5, kScreenWidth, 35);
        dermabrasionView.imageView.image = [UIImage imageNamed:@"mopi.png"];
        dermabrasionView.titleLabel.textColor = UIColorFromRGB(0x555555);
        dermabrasionView.titleLabel.font = [UIFont systemFontOfSize:11];
        dermabrasionView.titleLabel.text = @"磨皮";
        
        dermabrasionView.minLabel.textColor = UIColorFromRGB(0x555555);
        dermabrasionView.minLabel.font = [UIFont systemFontOfSize:15];
        dermabrasionView.minLabel.text = @"";
        
        dermabrasionView.maxLabel.textColor = UIColorFromRGB(0x555555);
        dermabrasionView.maxLabel.font = [UIFont systemFontOfSize:15];
        
        dermabrasionView.slider.thumbTintColor = UIColorFromRGB(0xbc47ff);
        dermabrasionView.slider.minimumTrackTintColor = UIColorFromRGB(0xbc47ff);
        dermabrasionView.slider.maximumValue = 100;
        [dermabrasionView.slider addTarget:self action:@selector(beautifySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _dermabrasionView = dermabrasionView;
        dermabrasionView.slider.tag = STViewTagSmoothSlider;
        
        
        STSliderView *ruddyView = [[[NSBundle mainBundle] loadNibNamed:@"STSliderView" owner:nil options:nil] firstObject];
        ruddyView.frame = CGRectMake(0, 40, kScreenWidth, 35);
        ruddyView.imageView.image = [UIImage imageNamed:@"hongrun.png"];
        ruddyView.titleLabel.textColor = UIColorFromRGB(0x555555);
        ruddyView.titleLabel.font = [UIFont systemFontOfSize:11];
        ruddyView.titleLabel.text = @"红润";
        
        ruddyView.minLabel.textColor = UIColorFromRGB(0x555555);
        ruddyView.minLabel.font = [UIFont systemFontOfSize:15];
        ruddyView.minLabel.text = @"";
        
        ruddyView.maxLabel.textColor = UIColorFromRGB(0x555555);
        ruddyView.maxLabel.font = [UIFont systemFontOfSize:15];
        
        ruddyView.slider.thumbTintColor = UIColorFromRGB(0xbc47ff);
        ruddyView.slider.minimumTrackTintColor = UIColorFromRGB(0xbc47ff);
        ruddyView.slider.maximumValue = 100;
        [ruddyView.slider addTarget:self action:@selector(beautifySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _ruddyView = ruddyView;
        ruddyView.slider.tag = STViewTagReddenSlider;
        
        
        STSliderView *whitenView = [[[NSBundle mainBundle] loadNibNamed:@"STSliderView" owner:nil options:nil] firstObject];
        whitenView.frame = CGRectMake(0, 75, kScreenWidth, 40);
        
        whitenView.imageView.image = [UIImage imageNamed:@"meibai.png"];
        
        whitenView.titleLabel.textColor = UIColorFromRGB(0x555555);
        whitenView.titleLabel.font = [UIFont systemFontOfSize:11];
        whitenView.titleLabel.text = @"美白";
        
        whitenView.minLabel.textColor = UIColorFromRGB(0x555555);
        whitenView.minLabel.font = [UIFont systemFontOfSize:15];
        whitenView.minLabel.text = @"";
        
        whitenView.maxLabel.textColor = UIColorFromRGB(0x555555);
        whitenView.maxLabel.font = [UIFont systemFontOfSize:15];
        
        whitenView.slider.thumbTintColor = UIColorFromRGB(0xbc47ff);
        whitenView.slider.minimumTrackTintColor = UIColorFromRGB(0xbc47ff);
        whitenView.slider.maximumValue = 100;
        [whitenView.slider addTarget:self action:@selector(beautifySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _whitenView = whitenView;
        whitenView.slider.tag = STViewTagWhitenSlider;
        
        [_beautyBaseView addSubview:dermabrasionView];
        [_beautyBaseView addSubview:ruddyView];
        [_beautyBaseView addSubview:whitenView];
        
        _beautyBaseView.hidden = YES;
        _beautyBaseView.backgroundColor = UIColorFromRGB(0xffffff);
        _beautyBaseView.alpha = 0.85;
        
    }
    return _beautyBaseView;
}


- (UIView *)beautyShapeView {
    
    if (!_beautyShapeView) {
        
        _beautyShapeView = [[UIView alloc] initWithFrame:self.beautyCollectionView.frame];
        
        STSliderView *thinFaceView = [[[NSBundle mainBundle] loadNibNamed:@"STSliderView" owner:nil options:nil] firstObject];
        thinFaceView.frame = CGRectMake(0, 5, kScreenWidth, 35);
        thinFaceView.imageView.image = [UIImage imageNamed:@"thin_face.png"];
        thinFaceView.titleLabel.textColor = UIColorFromRGB(0x555555);
        thinFaceView.titleLabel.font = [UIFont systemFontOfSize:11];
        thinFaceView.titleLabel.text = @"瘦脸";
        
        thinFaceView.minLabel.textColor = UIColorFromRGB(0x555555);
        thinFaceView.minLabel.font = [UIFont systemFontOfSize:15];
        thinFaceView.minLabel.text = @"";
        
        thinFaceView.maxLabel.textColor = UIColorFromRGB(0x555555);
        thinFaceView.maxLabel.font = [UIFont systemFontOfSize:15];
        
        thinFaceView.slider.thumbTintColor = UIColorFromRGB(0xbc47ff);
        thinFaceView.slider.minimumTrackTintColor = UIColorFromRGB(0xbc47ff);
        thinFaceView.slider.maximumValue = 100;
        [thinFaceView.slider addTarget:self action:@selector(beautifySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        thinFaceView.slider.tag = STViewTagShrinkFaceSlider;
        _thinFaceView = thinFaceView;
        
        
        STSliderView *enlargeEyesView = [[[NSBundle mainBundle] loadNibNamed:@"STSliderView" owner:nil options:nil] firstObject];
        enlargeEyesView.frame = CGRectMake(0, 40, kScreenWidth, 35);
        enlargeEyesView.imageView.image = [UIImage imageNamed:@"enlarge_eyes.png"];
        enlargeEyesView.titleLabel.textColor = UIColorFromRGB(0x555555);
        enlargeEyesView.titleLabel.font = [UIFont systemFontOfSize:11];
        enlargeEyesView.titleLabel.text = @"大眼";
        
        enlargeEyesView.minLabel.textColor = UIColorFromRGB(0x555555);
        enlargeEyesView.minLabel.font = [UIFont systemFontOfSize:15];
        enlargeEyesView.minLabel.text = @"";
        
        enlargeEyesView.maxLabel.textColor = UIColorFromRGB(0x555555);
        enlargeEyesView.maxLabel.font = [UIFont systemFontOfSize:15];
        
        enlargeEyesView.slider.thumbTintColor = UIColorFromRGB(0xbc47ff);
        enlargeEyesView.slider.minimumTrackTintColor = UIColorFromRGB(0xbc47ff);
        enlargeEyesView.slider.maximumValue = 100;
        [enlargeEyesView.slider addTarget:self action:@selector(beautifySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        enlargeEyesView.slider.tag = STViewTagEnlargeEyeSlider;
        _enlargeEyesView = enlargeEyesView;
        
        
        
        STSliderView *smallFaceView = [[[NSBundle mainBundle] loadNibNamed:@"STSliderView" owner:nil options:nil] firstObject];
        smallFaceView.frame = CGRectMake(0, 75, kScreenWidth, 35);
        smallFaceView.imageView.image = [UIImage imageNamed:@"small_face.png"];
        smallFaceView.titleLabel.textColor = UIColorFromRGB(0x555555);
        smallFaceView.titleLabel.font = [UIFont systemFontOfSize:11];
        smallFaceView.titleLabel.text = @"小脸";
        
        smallFaceView.minLabel.textColor = UIColorFromRGB(0x555555);
        smallFaceView.minLabel.font = [UIFont systemFontOfSize:15];
        smallFaceView.minLabel.text = @"";
        
        smallFaceView.maxLabel.textColor = UIColorFromRGB(0x555555);
        smallFaceView.maxLabel.font = [UIFont systemFontOfSize:15];
        
        smallFaceView.slider.thumbTintColor = UIColorFromRGB(0xbc47ff);
        smallFaceView.slider.minimumTrackTintColor = UIColorFromRGB(0xbc47ff);
        smallFaceView.slider.maximumValue = 100;
        [smallFaceView.slider addTarget:self action:@selector(beautifySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        smallFaceView.slider.tag = STViewTagShrinkJawSlider;
        _smallFaceView = smallFaceView;
        
        
        [_beautyShapeView addSubview:thinFaceView];
        [_beautyShapeView addSubview:enlargeEyesView];
        [_beautyShapeView addSubview:smallFaceView];
        
        _beautyShapeView.hidden = YES;
        _beautyShapeView.backgroundColor = UIColorFromRGB(0xffffff);
        _beautyShapeView.alpha = 0.85;
        
    }
    return _beautyShapeView;
}

#pragma mark - 特效的子View  (顶部滚动，贴纸，2D，3D)
- (STScrollTitleView *)scrollTitleView {
    if (!_scrollTitleView) {
        
        STWeakSelf;
        
        _scrollTitleView = [[STScrollTitleView alloc] initWithFrame:CGRectMake(57, 0, kScreenWidth - 57, 40) normalImages:[self getNormalImages] selectedImages:[self getSelectedImages] effectsType:@[@(STEffectsTypeSticker2D), @(STEffectsTypeSticker3D), @(STEffectsTypeStickerGesture), @(STEffectsTypeStickerSegment), @(STEffectsTypeStickerFaceDeformation), @(STEffectsTypeObjectTrack)] titleOnClick:^(STTitleViewItem *titleView, NSInteger index, STEffectsType type) {
            [weakSelf handleEffectsType:type];
        }];
        
        _scrollTitleView.backgroundColor = UIColorFromRGB(0xffffff);
        _scrollTitleView.alpha = 0.6;
    }
    return _scrollTitleView;
}

- (STCollectionView *)collectionView {
    if (!_collectionView) {
        
        __weak typeof(self) weakSelf = self;
        _collectionView = [[STCollectionView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 140) withModels:nil andDelegateBlock:^(STCollectionViewDisplayModel *model) {
                weakSelf.noneStickerImageView.highlighted = NO;
            if ([weakSelf.delegate respondsToSelector:@selector(didSelectedEffectModel:)]) {
                [weakSelf.delegate didSelectedEffectModel:model];
            }
        }];
        
        _collectionView.arr2DModels = self.arr2DStickers;
        _collectionView.arr3DModels = self.arr3DStickers;
        _collectionView.arrGestureModels = self.arrGestureStickers;
        _collectionView.arrSegmentModels = self.arrSegmentStickers;
        _collectionView.arrFaceDeformationModels = self.arrFacedeformationStickers;
        _collectionView.arrObjectTrackModels = self.arrObjectTrackers;
        
        _collectionView.backgroundColor = UIColorFromRGB(0xffffff);
        _collectionView.alpha = 0.85;
        
    }
    return _collectionView;
}


- (NSArray *)getNormalImages {
    
    NSMutableArray *res = [NSMutableArray array];
    
    UIImage *sticker2d = [UIImage imageNamed:@"2d.png"];
    UIImage *sticker3d = [UIImage imageNamed:@"3d.png"];
    UIImage *stickerGesture = [UIImage imageNamed:@"sticker_gesture.png"];
    UIImage *stickerSegment = [UIImage imageNamed:@"sticker_segment.png"];
    UIImage *stickerDeformation = [UIImage imageNamed:@"sticker_face_deformation.png"];
    UIImage *objectTrack = [UIImage imageNamed:@"common_object_track.png"];
    
    [res addObject:sticker2d];
    [res addObject:sticker3d];
    [res addObject:stickerGesture];
    [res addObject:stickerSegment];
    [res addObject:stickerDeformation];
    [res addObject:objectTrack];
    
    return [res copy];
}

- (NSArray *)getSelectedImages {
    
    NSMutableArray *res = [NSMutableArray array];
    
    UIImage *sticker2d = [UIImage imageNamed:@"2d_selected.png"];
    UIImage *sticker3d = [UIImage imageNamed:@"3d_selected.png"];
    UIImage *stickerGesture = [UIImage imageNamed:@"sticker_gesture_selected.png"];
    UIImage *stickerSegment = [UIImage imageNamed:@"sticker_segment_selected.png"];
    UIImage *stickerDeformation = [UIImage imageNamed:@"sticker_face_deformation_selected.png"];
    UIImage *objectTrack = [UIImage imageNamed:@"common_object_track_selected.png"];
    
    [res addObject:sticker2d];
    [res addObject:sticker3d];
    [res addObject:stickerGesture];
    [res addObject:stickerSegment];
    [res addObject:stickerDeformation];
    [res addObject:objectTrack];
    
    return [res copy];
}

#pragma mark -

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self createUI];
    }
    return self;
}

-(void)createUI
{
    self.beautyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 160)];
    [self addSubview:self.beautyView];
    self.beautyView.backgroundColor = [UIColor whiteColor];
    self.effectsView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 160)];
    [self addSubview:self.effectsView];
    self.effectsView.backgroundColor = [UIColor whiteColor];
    self.beautyView.hidden = YES;
    self.effectsView.hidden = YES;
    
    self.effectsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.effectsButton.frame = CGRectMake(0, 160, kScreenWidth/2, 40);
    [self addSubview:self.effectsButton];
    self.effectsButton.backgroundColor = [UIColor whiteColor];
    [self.effectsButton setTitle:@"特效" forState:UIControlStateNormal];
    [self.effectsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.effectsButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.effectsButton addTarget:self action:@selector(effectsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.beautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beautyButton.frame = CGRectMake(kScreenWidth/2, 160, kScreenWidth/2, 40);
    [self addSubview:self.beautyButton];
    self.beautyButton.backgroundColor = [UIColor whiteColor];
    [self.beautyButton setTitle:@"美颜" forState:UIControlStateNormal];
    [self.beautyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.beautyButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.beautyButton addTarget:self action:@selector(beautyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self configBeautyView];
    [self configEffectsView];
    
    [self beautyButtonClick:self.beautyButton];
}

//美颜
-(void)configBeautyView
{
    [self.beautyView addSubview:self.beautyScrollTitleView];
    [self.beautyView addSubview:self.beautyCollectionView];
    [self.beautyView addSubview:self.beautyBaseView];
    [self.beautyView addSubview:self.beautyShapeView];
    
    [self.arrBeautyViews addObject:self.beautyCollectionView];
    [self.arrBeautyViews addObject:self.beautyBaseView];
    [self.arrBeautyViews addObject:self.beautyShapeView];
}

//贴纸
-(void)configEffectsView
{
    self.noneStickerImageView.hidden = NO;
    [self.effectsView addSubview:self.scrollTitleView];
    [self.effectsView addSubview:self.collectionView];
}

-(UIImageView *)noneStickerImageView
{
    if (_noneStickerImageView == nil) {
        UIView *noneStickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 57, 40)];
        noneStickerView.backgroundColor = [UIColor whiteColor];
        noneStickerView.alpha = 0.6;
        noneStickerView.layer.shadowColor = UIColorFromRGB(0x141618).CGColor;
        noneStickerView.layer.shadowOpacity = 0.5;
        noneStickerView.layer.shadowOffset = CGSizeMake(3, 3);
        
        UIImage *image = [UIImage imageNamed:@"none_sticker.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((57 - image.size.width) / 2, (40 - image.size.height) / 2, image.size.width, image.size.height)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = image;
        imageView.highlightedImage = [UIImage imageNamed:@"none_sticker_selected.png"];
        _noneStickerImageView = imageView;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapNoneSticker:)];
        [noneStickerView addGestureRecognizer:tapGesture];
        [noneStickerView addSubview:imageView];
        
        [self.effectsView addSubview:noneStickerView];
    }
    return _noneStickerImageView;
}

#pragma mark - 点击选择特效和美颜
-(void)effectsButtonClick:(UIButton *)effectsButton
{
    if (effectsButton.isSelected) {
        effectsButton.selected = NO;
        self.effectsView.hidden = YES;
        return;
    }
    effectsButton.selected = YES;
    self.beautyButton.selected = NO;
    self.beautyView.hidden = YES;
    self.effectsView.hidden = NO;
}

-(void)beautyButtonClick:(UIButton *)beautyButton
{
    if (beautyButton.isSelected) {
        beautyButton.selected = NO;
        self. beautyView.hidden = YES;
        return;
    }
    beautyButton.selected = YES;
    self.effectsButton.selected = NO;
    self.beautyView.hidden = NO;
    self.effectsView.hidden = YES;
}

#pragma mark - 点击scrollView的按钮（滤镜，瘦脸，贴纸等）
- (void)handleEffectsType:(STEffectsType)type {
    
    switch (type) {
            
        case STEffectsTypeSticker2D:
            
            self.collectionView.arrModels = self.arr2DStickers;
            [self.collectionView reloadData];
            break;
            
        case STEffectsTypeStickerFaceDeformation:
            
            self.collectionView.arrModels = self.arrFacedeformationStickers;
            [self.collectionView reloadData];
            break;
            
        case STEffectsTypeStickerSegment:
            
            self.collectionView.arrModels = self.arrSegmentStickers;
            [self.collectionView reloadData];
            break;
            
        case STEffectsTypeStickerGesture:
            self.collectionView.arrModels = self.arrGestureStickers;
            [self.collectionView reloadData];
            break;
            
        case STEffectsTypeSticker3D:
            self.collectionView.arrModels = self.arr3DStickers;
            [self.collectionView reloadData];
            break;
            
        case STEffectsTypeObjectTrack:
            self.collectionView.arrModels = self.arrObjectTrackers;
            [self.collectionView reloadData];
            break;
            
        case STEffectsTypeStickerFaceChange:
            
            break;
        case STEffectsTypeBeautyFilter:
        {
            [self hideBeautyViewExcept:self.beautyCollectionView];
            self.beautyCollectionView.arrModels = self.arrFilters;
            [self.beautyCollectionView reloadData];
        }
            break;
            
        case STEffectsTypeNone:
            break;
            
        case STEffectsTypeBeautyShape:
        {
            [self hideBeautyViewExcept:self.beautyShapeView];
        }
            break;
            
        case STEffectsTypeBeautyBase:
        {
            [self hideBeautyViewExcept:self.beautyBaseView];
        }
            break;
    }
}

- (void)hideBeautyViewExcept:(UIView *)view {
    for (UIView *beautyView in self.arrBeautyViews) {
        beautyView.hidden = !(view == beautyView);
    }
}

//点击去除特效按钮
-(void)onTapNoneSticker:(UITapGestureRecognizer *)tap
{
    self.noneStickerImageView.highlighted = YES;
    [self.collectionView clearSelectedStateExcept:STEffectsTypeNone];
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedRemoveAllEffectButton)]) {
        [self.delegate didSelectedRemoveAllEffectButton];
    }
}

#pragma mark - 滑杆滑动
-(void)beautifySliderValueChanged:(UISlider *)slider
{
    if ([self.delegate respondsToSelector:@selector(didSliderValueChanged:)]) {
        [self.delegate didSliderValueChanged:slider];
    }
}


@end
