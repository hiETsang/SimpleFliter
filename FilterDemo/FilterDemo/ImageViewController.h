//
//  ImageViewController.h
//  FilterDemo
//
//  Created by canoe on 2017/11/22.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
@property(nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;
@end
