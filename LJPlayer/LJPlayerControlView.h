//
//  LJPlayerControlView.h
//  LJPlayer
//
//  Created by JasonLee on 16/5/17.
//  Copyright © 2016年 JasonLee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJPlayerControlView : UIView

@property (weak, nonatomic) IBOutlet UIView *topBackView;
@property (weak, nonatomic) IBOutlet UIButton *playBackBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomBackView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *playerProgressView;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)showControllView;

- (void)hiddenControllView;

@end
