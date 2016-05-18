//
//  LJPlayerView.h
//  LJPlayer
//
//  Created by JasonLee on 16/5/17.
//  Copyright © 2016年 JasonLee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, LJPlayerLayerGravity) {
    LJPlayerLayerGravityResize,           // 非均匀模式
    LJPlayerLayerGravityResizeAspect,     // 等比例填充
    LJPlayerLayerGravityResizeAspectFill  // 等比例填充(维度会被裁剪)
};

@interface LJPlayerView : UIView


/** videoURL*/
@property (nonatomic,strong) NSURL *videoURL;

/** 显示模式*/
@property (nonatomic,assign) LJPlayerLayerGravity playerLayerGravity;

@end
