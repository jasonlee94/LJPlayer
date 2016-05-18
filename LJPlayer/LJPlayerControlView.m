//
//  LJPlayerControlView.m
//  LJPlayer
//
//  Created by JasonLee on 16/5/17.
//  Copyright © 2016年 JasonLee. All rights reserved.
//

#import "LJPlayerControlView.h"

@implementation LJPlayerControlView

-(void)awakeFromNib
{
    [super awakeFromNib];
     [_playSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_activityIndicator startAnimating];
}


-(void)showControllView
{
    _topBackView.alpha = 1.0f;
    _bottomBackView.alpha = 1.0f;
}

-(void)hiddenControllView
{
    _topBackView.alpha = 0;
    _bottomBackView.alpha = 0;
}
@end
