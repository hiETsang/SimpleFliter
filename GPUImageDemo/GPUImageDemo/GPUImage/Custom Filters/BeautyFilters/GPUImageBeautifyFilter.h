//
//  GPUImageBeautifyFilter.h
//  BeautifyFaceDemo
//
//  Created by guikz on 16/4/28.
//  Copyright © 2016年 guikz. All rights reserved.
//

#import "GPUImage.h"

//美颜效果1  比较的亮
@class GPUImageCombinationFilter;

@interface GPUImageBeautifyFilter : GPUImageFilterGroup {
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
}

@end
