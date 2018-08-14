//
//  DealVideoController.m
//  GPUImageDemo
//
//  Created by canoe on 2018/3/1.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import "DealVideoController.h"
#import <SCRecorder.h>
#import "UIView+X.h"
#import "UIButton+X.h"

@interface DealVideoController ()

@property(nonatomic, strong) NSURL *videoURL;
@property(nonatomic, strong) SCSwipeableFilterView *filterSwitcherView;
@property (strong, nonatomic) SCPlayer *player;

@end

@implementation DealVideoController

-(SCSwipeableFilterView *)filterSwitcherView
{
    if (!_filterSwitcherView) {
        _filterSwitcherView = [[SCSwipeableFilterView alloc] initWithFrame:self.view.bounds];
        _filterSwitcherView.filters = @[[SCFilter emptyFilter],
                                        [SCFilter filterWithCIFilterName:@"CIPhotoEffectFade"],
                                        [SCFilter filterWithCIFilterName:@"CIPhotoEffectInstant"],
                                        [SCFilter filterWithCIFilterName:@"CIPhotoEffectNoir"],
                                        [SCFilter filterWithCIFilterName:@"CIPhotoEffectTonal"]
                                        ];
        _filterSwitcherView.backgroundColor = [UIColor clearColor];
        _filterSwitcherView.contentMode = UIViewContentModeScaleAspectFill;
        _filterSwitcherView.contextType = SCContextTypeAuto;
    }
    return _filterSwitcherView;
}

-(instancetype)initWithVideoUrl:(NSURL *)url
{
    self = [super init];
    if(self) {
        self.videoURL = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.filterSwitcherView];
    
    self.player = [SCPlayer player];
    self.player.loopEnabled = YES;
    [self.player setItemByUrl:self.videoURL];
    self.player.SCImageView = self.filterSwitcherView;
    
    UIButton *button = [self.view addButtonTextTypeWithTitle:@"back" titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16] backColor:nil];
    button.frame = CGRectMake(0, 20, 40, 40);
    
    __weak __typeof(self)weakSelf = self;
    [button addActionHandler:^(NSInteger tag) {
        [weakSelf dismissViewControllerAnimated:NO completion:nil];
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.player play];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
