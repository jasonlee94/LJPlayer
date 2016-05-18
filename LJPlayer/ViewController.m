//
//  ViewController.m
//  LJPlayer
//
//  Created by JasonLee on 16/5/17.
//  Copyright © 2016年 JasonLee. All rights reserved.
//

#import "ViewController.h"
#import "LJPlayerView.h"


@interface ViewController ()

@property (nonatomic,strong) LJPlayerView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    _playerView = [[LJPlayerView alloc] initWithFrame:CGRectMake(0, 20, 320, 200)];
    _playerView.videoURL = [NSURL URLWithString:@"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4"];
    _playerView.playerLayerGravity = LJPlayerLayerGravityResizeAspect;
    [self.view addSubview:self.playerView];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];



}

@end
