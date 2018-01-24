//
//  UITableView+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/21.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (X)

/**
 一般，在insert,delete,select,reload row时使用，动画效果更加同步和顺滑。
 在动画块内，不建议使用reloadData方法，如果使用，会影响动画。在动画块内进行insert,delete,select,reload row操作。
 使用这个方法会自动调用刷新行高的方法。
 */
- (void)updateWithBlock:(void (^)(UITableView *tableView))block;


- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

- (void)insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void)deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

//取消所有选中
- (void)clearSelectedRowsAnimated:(BOOL)animated;

@end
