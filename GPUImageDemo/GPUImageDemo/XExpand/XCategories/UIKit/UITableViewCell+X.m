//
//  UITableViewCell+X.m
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/21.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "UITableViewCell+X.h"

@implementation UITableViewCell (X)

/**
 *  @brief  加载同类名的nib
 *
 *  @return nib
 */
+(UINib*)nib{
    return  [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

@end
