//
//  LJPlayerView.m
//  LJPlayer
//
//  Created by JasonLee on 16/5/17.
//  Copyright © 2016年 JasonLee. All rights reserved.
//

#import "LJPlayerView.h"
#import "LJPlayerControlView.h"


//播放器的几种状态
typedef NS_ENUM(NSInteger, LJPlayerState) {
    LJPlayerStateFailed,     // 播放失败
    LJPlayerStateBuffering,  //缓冲中
    LJPlayerStatePlaying,    //播放中
    LJPlayerStateStopped,    //停止播放
    LJPlayerStatePause       //暂停播放
};

@interface LJPlayerView()

@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) LJPlayerControlView *playerControlView;
/** 播放状态*/
@property (nonatomic,assign) LJPlayerState state;


@property (nonatomic,assign) CGRect tmpRect;
@property (nonatomic,copy) NSString *totalTime;

@property (nonatomic,assign) BOOL isPlayControlShow;

@end


@implementation LJPlayerView

-(void)dealloc
{
    self.playerItem = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)play
{
    [self.player play];
    self.playerControlView.playBtn.selected = YES;

}

- (void)pause
{
    [self.player pause];
    self.playerControlView.playBtn.selected = NO;

}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tmpRect = frame;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    self.playerControlView.frame = self.bounds;
    [self layoutIfNeeded];
}

-(void)setVideoURL:(NSURL *)videoURL
{
    if(videoURL == nil)return;
    _videoURL = videoURL;
    
    
    [self addNotification];
    [self configLJPlayer];
    
}
-(void)setState:(LJPlayerState)state
{
    _state = state;
    state == LJPlayerStateBuffering ? ([self.playerControlView.activityIndicator startAnimating]) : ([self.playerControlView.activityIndicator stopAnimating]);
}

- (void)addNotification
{
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 播放按钮点击事件
    [self.playerControlView.playBtn addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
  
//    // 返回按钮点击事件
//    [self.playerControlView.playBackBtn addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    // 全屏按钮点击事件
    [self.playerControlView.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.playerControlView.playSlider addTarget:self action:@selector(touchDownSlider:) forControlEvents:UIControlEventTouchDown];
    [self.playerControlView.playSlider addTarget:self action:@selector(valueChangeSlider:) forControlEvents:UIControlEventValueChanged];
    [self.playerControlView.playSlider addTarget:self action:@selector(endSlider:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpOutside|UIControlEventTouchUpInside];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
}
- (void)deviceOrientationChange
{
    UIDeviceOrientation orientation             = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:{
            self.playerControlView.fullScreenBtn.selected = NO;
            [self setFrame:_tmpRect];
            self.playerControlView.playBackBtn.hidden = NO;

        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            self.playerControlView.fullScreenBtn.selected = YES;
            [self setFrame:CGRectMake(0, 0, LJScreenWidth, LJScreenHeight)];
            self.playerControlView.playBackBtn.hidden = YES;

        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            self.playerControlView.fullScreenBtn.selected = YES;
            [self setFrame:CGRectMake(0, 0, LJScreenWidth, LJScreenHeight)];
            self.playerControlView.playBackBtn.hidden = YES;

        }
            break;
        
        default:
            break;
    }
    
}

- (void)touchDownSlider:(UISlider *)slider
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
- (void)valueChangeSlider:(UISlider *)slider
{
    if(self.player.currentItem.status == AVPlayerStatusReadyToPlay){
        [self pause];
        
        CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = floorf(total * slider.value);
        
        //转换成CMTime才能给player来控制播放进度
        
        CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
        // 拖拽的时长
        NSInteger proMin        = (NSInteger)CMTimeGetSeconds(dragedCMTime) / 60;//当前秒
        NSInteger proSec        = (NSInteger)CMTimeGetSeconds(dragedCMTime) % 60;//当前分钟
        
        NSString *currentTime   = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
        
        
        if (total > 0) {
            self.playerControlView.currentTimeLabel.text  = currentTime;
        }else {
            // 此时设置slider值为0
            slider.value = 0;
        }
        
    }else { // player状态加载失败
        // 此时设置slider值为0
        slider.value = 0;
    }
    
}
- (void)endSlider:(UISlider *)slider
{

    CGFloat total = self.playerItem.duration.value/self.playerItem.duration.timescale;
    NSInteger dragedTime = floorf(total *slider.value);
    CMTime cmTime = CMTimeMake(dragedTime, 1);
    [self.player seekToTime:cmTime];

    [self play];
    [self autoHiddenControllView];
}


- (void)fullScreenAction:(UIButton *)senderBtn
{
    senderBtn.selected = !senderBtn.selected;
    if(senderBtn.selected){
        [self changeOrientation:UIInterfaceOrientationLandscapeRight];
        [self setFrame:CGRectMake(0, 0, LJScreenWidth, LJScreenHeight)];
    }else{
        [self changeOrientation:UIInterfaceOrientationPortrait];
        [self setFrame:_tmpRect];
    }
}

- (void)changeOrientation:(UIInterfaceOrientation)senderOrientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = senderOrientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)configLJPlayer
{
    // 初始化playerItem
    self.playerItem  = [AVPlayerItem playerItemWithURL:self.videoURL];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    // 初始化playerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    // 此处为默认视频填充模式
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加playerLayer到self.layer
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
//    [self play];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self createGesture];
    
}

- (void)createGesture{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
}

- (void)tapAction:(UIGestureRecognizer *)senderTap
{
    if (senderTap.state == UIGestureRecognizerStateRecognized) {
       
        self.isPlayControlShow ? ([self hideControlView]) : ([self showControlView]);
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem) {return;}
    
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    if (playerItem) {
        
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}


- (NSTimeInterval)getBufferZones {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    // 获取缓冲区域
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    // 计算缓冲总进度
    NSTimeInterval result     = startSeconds + durationSeconds;
    return result;
}


- (void)setPlayerLayerGravity:(LJPlayerLayerGravity)playerLayerGravity
{
    _playerLayerGravity = playerLayerGravity;
    
    switch (playerLayerGravity) {
        case LJPlayerLayerGravityResize:
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            break;
        case LJPlayerLayerGravityResizeAspect:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case LJPlayerLayerGravityResizeAspectFill:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            break;
    }

}
-(LJPlayerControlView *)playerControlView
{
    if(_playerControlView == nil){
        _playerControlView = [[[NSBundle mainBundle] loadNibNamed:@"LJPlayerControlView" owner:nil options:nil] lastObject];
        [self addSubview:_playerControlView];
    }
    return _playerControlView;
}

#pragma mark --------- KVC ---------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                
                [self play];

                self.state = LJPlayerStatePlaying;
                
                CGFloat totalSecond = _playerItem.duration.value / _playerItem.duration.timescale;// 转换成秒
                _totalTime = [self convertTime:totalSecond];// 转换成播放时间
                self.playerControlView.totalTimeLabel.text = [NSString stringWithFormat:@"%@",_totalTime];
                [self monitoringPlayback:self.playerItem];// 监听播放状态

                
                
            } else if (self.player.currentItem.status == AVPlayerItemStatusFailed){
                
                self.state = LJPlayerStateFailed;
                
                NSError *error = [self.player.currentItem error];
                NSLog(@"视频加载失败===%@",error.description);
                
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self getBufferZones];
            CMTime duration             = self.playerItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            [self.playerControlView.playerProgressView setProgress:timeInterval / totalDuration animated:NO];
            
            
            
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            
            // 当缓冲是空的时候
            if (self.playerItem.playbackBufferEmpty) {
                self.state = LJPlayerStateBuffering;
                NSLog(@"缓冲为空");
                [self pause];
                
            }
            
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            
            // 当缓冲好的时候
            if (self.playerItem.playbackLikelyToKeepUp && self.state == LJPlayerStateBuffering){
                self.state = LJPlayerStatePlaying;
                [self play];
                NSLog(@"缓冲完毕");
            }
            
        }
    }
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
        NSString *timeString = [weakSelf convertTime:currentSecond];
        
        CGFloat totalSecond = playerItem.duration.value/playerItem.duration.timescale;
        weakSelf.playerControlView.playSlider.value = currentSecond/totalSecond;
        
        weakSelf.playerControlView.currentTimeLabel.text = [NSString stringWithFormat:@"%@",timeString];
        
    }];
    
    
}

- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

#pragma mark --------- 通知 ---------
- (void)appDidEnterBackground
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self pause];
    self.state = LJPlayerStatePause;
}

- (void)appDidEnterPlayGround
{
    [self showControlView];
    [self play];
    self.state = LJPlayerStatePlaying;
}

- (void)showControlView
{
    if(self.isPlayControlShow){
        return;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.playerControlView.bottomBackView.alpha = 1;
        self.playerControlView.topBackView.alpha = 1;
    } completion:^(BOOL finished) {
        self.isPlayControlShow = YES;
        [self autoHiddenControllView];

    }];
   
}

- (void)autoHiddenControllView
{
    if(!self.isPlayControlShow){
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:6];
    
}
- (void)hideControlView
{
    if(!self.isPlayControlShow){
        return;
    }
    [UIView animateWithDuration:0.25f animations:^{
        self.playerControlView.bottomBackView.alpha = 0;
        self.playerControlView.topBackView.alpha = 0;
    } completion:^(BOOL finished) {
        self.isPlayControlShow = NO;
    }];
    
}

- (void)startAction:(UIButton *)senderBtn
{
    senderBtn.selected = !senderBtn.selected;
    if(senderBtn.selected){
        [self play];
    }else{
        [self pause];
    }
}
@end
