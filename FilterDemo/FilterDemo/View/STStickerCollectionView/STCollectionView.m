//
//  STStickersCollectionView.m
//
//  Created by HaifengMay on 16/11/8.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

#import "STCollectionView.h"
#import "STCollectionViewCell.h"

@interface STCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) STCollectionViewDelegateBlock delegateBlock;

@end

@implementation STCollectionView

- (instancetype)initWithFrame:(CGRect)frame withModels:(NSArray <STCollectionViewDisplayModel *> *) arrModels andDelegateBlock:(STCollectionViewDelegateBlock) delegateBlock
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(60, 60);
    flowLayout.minimumLineSpacing = 5;
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    flowLayout.footerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 30);
    
    self = [super initWithFrame:frame collectionViewLayout:flowLayout];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        self.alwaysBounceVertical = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.arrModels = [arrModels copy];
        self.delegateBlock = delegateBlock;
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[STCollectionViewCell class] forCellWithReuseIdentifier:@"STCollectionViewCell"];
        [self registerClass:[STCollectionLabelCell class] forCellWithReuseIdentifier:@"STCollectionLabelCell"];
    }
    return self;
}

#pragma mark - dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.arrModels.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedModel) {
        [self clearSelectedStateExcept:self.selectedModel.modelType];
    }
    
    UICollectionViewCell *resCell = nil;
    
    if (self.arrFilterModels.count > 0) {
        STCollectionLabelCell *cell = [self dequeueReusableCellWithReuseIdentifier:@"STCollectionLabelCell" forIndexPath:indexPath];
        
        STCollectionViewDisplayModel *model = self.arrFilterModels[indexPath.row];
        cell.imageView.image = model.image;
        cell.lblName.text = model.strName;
        cell.maskContainerView.hidden = !(model.isSelected);
        cell.imageMaskView.hidden = !(model.isSelected);
        cell.lblMaskView.hidden = !(model.isSelected);
        cell.lblName.highlighted = model.isSelected;
        resCell = cell;
    } else {
        STCollectionViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:@"STCollectionViewCell" forIndexPath:indexPath];
        
        STCollectionViewDisplayModel *model = self.arrModels[indexPath.row];
        cell.imageView.image = model.image;
        cell.maskView.layer.borderColor = model.isSelected ? UIColorFromRGB(0x47c9ff).CGColor : [UIColor clearColor].CGColor;
        cell.maskView.hidden = !(model.isSelected);
        resCell = cell;
    }
    return resCell;
}



#pragma mark - delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //if (self.selectedIndex != indexPath.row) {
        
//    NSInteger preIndex = self.selectedIndex;
//    self.arrModels[preIndex].isSelected = NO;
    
    for (STCollectionViewDisplayModel *displayModel in self.arrModels) {
        displayModel.isSelected = NO;
    }
    
    STCollectionViewDisplayModel *model = self.arrModels[indexPath.row];
    model.isSelected = YES;
    
    self.selectedModel = model;
    self.selectedIndex = indexPath.row;
    
    [collectionView reloadData];
    
    if (self.delegateBlock) {
        
        self.delegateBlock(model);
    }
    //}
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition
{
    [super selectItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    
    [self collectionView:self didSelectItemAtIndexPath:indexPath];
}

#pragma mark -

- (void)clearSelectedStateExcept:(STEffectsType)type {
    switch (type) {
            
        case STEffectsTypeNone:
            
            for (STCollectionViewDisplayModel *model in self.arr2DModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arr3DModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrGestureModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrSegmentModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrFaceDeformationModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrObjectTrackModels) {
                model.isSelected = NO;
            }
            
            break;
            
        case STEffectsTypeSticker2D:
            
            for (STCollectionViewDisplayModel *model in self.arr3DModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrGestureModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrSegmentModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrFaceDeformationModels) {
                model.isSelected = NO;
            }
            
            break;
            
        case STEffectsTypeSticker3D:
            
            for (STCollectionViewDisplayModel *model in self.arr2DModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrGestureModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrSegmentModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrFaceDeformationModels) {
                model.isSelected = NO;
            }
            
            break;
            
        case STEffectsTypeStickerGesture:
            
            for (STCollectionViewDisplayModel *model in self.arr2DModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arr3DModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrSegmentModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrFaceDeformationModels) {
                model.isSelected = NO;
            }
            
            break;
            
        case STEffectsTypeStickerSegment:
            
            for (STCollectionViewDisplayModel *model in self.arr2DModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arr3DModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrGestureModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrFaceDeformationModels) {
                model.isSelected = NO;
            }
            
            break;
            
        case STEffectsTypeStickerFaceDeformation:
            
            for (STCollectionViewDisplayModel *model in self.arr2DModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arr3DModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrGestureModels) {
                model.isSelected = NO;
            }
            for (STCollectionViewDisplayModel *model in self.arrSegmentModels) {
                model.isSelected = NO;
            }
            
            break;
        default:
            break;
    }
}


@end
