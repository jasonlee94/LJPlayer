LJPlayer 使用方法

将LJPlayerView 、LJPlayerControlView 以及图片拖入到项目目录中，导入AVFoundation

在需要展示视频的地方只需：_playerView = [[LJPlayerView alloc] initWithFrame:CGRectMake(0, 20, 320, 200)];
                          _playerView.videoURL = [NSURL URLWithString:_videoUrl];
                          _playerView.playerLayerGravity = LJPlayerLayerGravityResizeAspect;//视频显示比例方式
                          
设置这三项即可
