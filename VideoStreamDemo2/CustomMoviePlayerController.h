//
//  CustomMoviePlayerController.h
//  VideoStreamDemo2
//
//  Created by 刘 大兵 on 12-5-17.
//  Copyright (c) 2012年 中华中等专业学校. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPlayerView.h"
#import "MBProgressHUD.h"

@interface CustomMoviePlayerController : UIViewController<UIPopoverControllerDelegate>{
    IBOutlet CustomPlayerView *moviePlayeView;
    IBOutlet UIButton *playButton;
    IBOutlet UISlider *movieProgressSlider;
    //视频的总时间
    CGFloat totalMovieDuration;
    IBOutlet UILabel *currentTimeLabel;
    IBOutlet UILabel *totalTimeLabel;
    MBProgressHUD *loadingView;
}
@property(nonatomic,retain) NSURL *movieURL;
-(IBAction)doneClick:(id)sender;
-(IBAction)playClick:(id)sender;
-(IBAction)movieProgressDragged:(id)sender;
@end
