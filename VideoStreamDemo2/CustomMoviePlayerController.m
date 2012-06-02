//
//  CustomMoviePlayerController.m
//  VideoStreamDemo2
//
//  Created by 刘 大兵 on 12-5-17.
//  Copyright (c) 2012年 中华中等专业学校. All rights reserved.
//

#import "CustomMoviePlayerController.h"

@interface CustomMoviePlayerController()
-(void)initPlayer;
-(void)monitorMovieProgress;
-(NSString*)convertMovieTimeToText:(CGFloat)time;
-(void)initMoviewPreview;
-(CustomPlayerView*)previewViewCreate:(CGFloat)xOffsetInSlider;
@end

@implementation CustomMoviePlayerController
@synthesize movieURL;
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    loadingView = [[MBProgressHUD alloc]initWithView:self.view];
    loadingView.labelText = @"正在加载...";
    [self.view addSubview:loadingView];
    [self initPlayer];
    [self monitorMovieProgress];
    [self initMoviewPreview];

}

- (void)dealloc {
    [movieURL release];
    [loadingView release];
    //释放对视频播放完成的监测
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:moviePlayeView.player.currentItem];
    //释放掉对playItem的观察
    [moviePlayeView.player.currentItem removeObserver:self
                                           forKeyPath:@"status" 
                                              context:nil];
    [moviePlayeView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return interfaceOrientation!=UIInterfaceOrientationPortraitUpsideDown;
}

-(void)initPlayer{
    //显示loadingView
    [loadingView show:YES];
    //使用playerItem获取视频的信息，当前播放时间，总时间等
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:movieURL];
    //player是视频播放的控制器，可以用来快进播放，暂停等
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    [moviePlayeView setPlayer:player];
    [moviePlayeView.player play];
    //计算视频总时间
    CMTime totalTime = playerItem.duration;
    //因为slider的值是小数，要转成float，当前时间和总时间相除才能得到小数,因为5/10=0
    totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    //NSLog(@"totalMovieDuration:%f",totalMovieDuration);
    //在totalTimeLabel上显示总时间
    totalTimeLabel.text = [self convertMovieTimeToText:totalMovieDuration];
    
    //检测视频加载状态，加载完成隐藏loadingView
    [moviePlayeView.player.currentItem addObserver:self
                                        forKeyPath:@"status" 
                                           options:NSKeyValueObservingOptionNew
                                           context:nil];
    //添加视频播放完成的notifation
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:moviePlayeView.player.currentItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    NSLog(@"keyPath:%@,object:%@",keyPath,NSStringFromClass([object class]));
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem*)object;
        if (playerItem.status==AVPlayerStatusReadyToPlay) {
            //视频加载完成，隐藏loadingView
            [loadingView hide:YES];
        }
    }
}

-(NSString*)convertMovieTimeToText:(CGFloat)time{
    //把秒数转换成文字
    if (time<60.f) {
        return [NSString stringWithFormat:@"%.0f秒",time];
    }else{
        return [NSString stringWithFormat:@"%.2f",time/60];
    }
}

-(void)monitorMovieProgress{
    //使用movieProgressSlider反应视频播放的进度
    //第一个参数反应了检测的频率
    [moviePlayeView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time){
        //获取当前时间
        CMTime currentTime = moviePlayeView.player.currentItem.currentTime;
        //转成秒数
        CGFloat currentPlayTime = (CGFloat)currentTime.value/currentTime.timescale;
        movieProgressSlider.value = currentPlayTime/totalMovieDuration;
        //用label显示当前播放的秒数
        //判断秒数是否满一分钟,如果不满一分钟显示秒,如果满一分钟，显示分钟
        currentTimeLabel.text = [self convertMovieTimeToText:currentPlayTime];
        //NSLog(@"currentTimeLabel.text:%@",currentTimeLabel.text);
    }];
}

-(void)moviePlayDidEnd:(NSNotification*)notification{
    //视频播放完成，回退到视频列表页面
    [self doneClick:nil];
}

-(IBAction)doneClick:(id)sender{
    //停止播放，不然页面dimiss了以后，还有播放的声音
    [moviePlayeView.player pause];
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)playClick:(id)sender{
    //播放暂停控制，进入页面就开始播放视频，然后播放按钮的文字是暂停
    //点击一下播放视频停止，按钮文字变成播放
    //判断是播放还是暂停状态
    if ([[playButton titleForState:UIControlStateNormal]isEqualToString:@"暂停"]) {
        //从播放状态进入暂停
        [moviePlayeView.player pause];
        [playButton setTitle:@"播放" forState:UIControlStateNormal];
    }else{
        //从暂停状态进入播放
        [moviePlayeView.player play];
        [playButton setTitle:@"暂停" forState:UIControlStateNormal];
    }
}

-(IBAction)movieProgressDragged:(id)sender{
    //拖动改变视频播放进度
    //计算出拖动的当前秒数
    NSInteger dragedSeconds = floorf(totalMovieDuration*movieProgressSlider.value);
    NSLog(@"dragedSeconds:%d",dragedSeconds);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    [moviePlayeView.player pause];
    [moviePlayeView.player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
        [moviePlayeView.player play];
    }];
}

-(void)initMoviewPreview{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(progessSliderLongPress:)];
    [movieProgressSlider addGestureRecognizer:longPress];
    [longPress release];
}

-(void)progessSliderLongPress:(UILongPressGestureRecognizer*)theLong{
    //因为长按手势的方法最少会被调用两次，所以为了不重复弹出popOver进行判断，只调用一次弹出popOver
    if (theLong.state==UIGestureRecognizerStateBegan) {
        //长按以后弹出popView在长按的位置
        CGPoint touchPoint = [theLong locationInView:self.view];
        //只能显示在进度条上方
        CGRect popOverFrame = CGRectMake(touchPoint.x-100, movieProgressSlider.frame.origin.y, 200, 150);
        UIViewController *previewMovieController = [[UIViewController alloc]init];
        //通过长按手势在slider的位置，计算视频预览的时间
        CGPoint touchPointInSlider = [theLong locationInView:movieProgressSlider];
        CustomPlayerView *previewView = [self previewViewCreate:touchPointInSlider.x];
        
        previewMovieController.view.backgroundColor = [UIColor whiteColor];
                previewMovieController.view = previewView;
        UIPopoverController *popoverController = [[UIPopoverController alloc]initWithContentViewController:previewMovieController];
        //更改popover的contentSize
        popoverController.delegate = self;
        popoverController.popoverContentSize = CGSizeMake(200, 150);
        //箭头向下，指向进度条
        [popoverController presentPopoverFromRect:popOverFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        //播放视频
        [previewView.player play];
        [previewMovieController release];
        //不能在这里使用release和autorelease，因为popOver正在使用，release会导致crash
        //[popoverController release];
    }
}

//为了使调用视频预览的代码更清晰，把创建playerView的代码和创建popover的分开
-(CustomPlayerView*)previewViewCreate:(CGFloat)xOffsetInSlider{
    //        NSLog(@"touchPoint:%@,touchPointInSlider:%@",NSStringFromCGPoint(touchPoint),NSStringFromCGPoint(touchPointInSlider));
    //把touchPointInSlider。x除以slider的宽度可以计算出预览的进度
    CGFloat previewValue = xOffsetInSlider/movieProgressSlider.bounds.size.width;
    //如果长按在进度条的中间，那么previewValue就是0。5，乘以视频的总时间，就知道了视频预览的时间
    NSInteger previewSeconds = floorf(previewValue*totalMovieDuration);
    //秒数舍弃小数部分，转换成cmTime
    CMTime previewCMTime = CMTimeMake(previewSeconds, 1);
    //初始化视频预览的view
    CustomPlayerView *previewView = [[CustomPlayerView alloc]initWithFrame:CGRectMake(0, 0, 200, 150)];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:movieURL];
    //跳到视频预览的时间
    [playerItem seekToTime:previewCMTime];
    //player是视频播放的控制器，可以用来快进播放，暂停等
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    [previewView setPlayer:player];
    return [previewView autorelease];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    //popOver已经使用完毕，release是可以的
    [popoverController release];
}
@end
