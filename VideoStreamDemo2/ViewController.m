//
//  ViewController.m
//  VideoStreamDemo2
//
//  Created by 刘 大兵 on 12-5-17.
//  Copyright (c) 2012年 中华中等专业学校. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CustomMoviePlayerController.h"

@implementation ViewController
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    linkArray = [[NSMutableArray alloc]initWithObjects:@"http://61.160.227.6/rtencode_m3u8?bl=/f4v/61/140783661.h264_2.f4v&t=8&em=1&se=c629000050724fef&k=8bb5b375af9ab17fa859074fb394455fcd7505",@"http://61.160.230.12/rtencode_m3u8?bl=/f4v/85/140698785.h264_2.f4v&t=8&em=1&se=b245000050723fb4&k=0dfa39da8293f0684c6cd84fb395905fcd7505",@"http://58.215.144.42/rtencode_m3u8?bl=/f4v/46/140739646.h264_1.f4v&t=8&em=1&se=751300005072e2d8&k=8d77cf2355c3bf817f6e364fb396005fcd7505", nil];
}

- (void)dealloc {
    [linkArray release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return interfaceOrientation!=UIInterfaceOrientationPortraitUpsideDown;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return linkArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *movieCell = [DataTable dequeueReusableCellWithIdentifier:@"movieCell"];
    if (movieCell==nil) {
        movieCell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"movieCell"]autorelease];
    }
    NSString *linkStr = [linkArray objectAtIndex:indexPath.row];
    movieCell.textLabel.text = linkStr;
    MPMoviePlayerController *movieController = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:linkStr]];
    [movieController requestThumbnailImagesAtTimes:[NSArray arrayWithObject:[NSNumber numberWithDouble:0]] timeOption:MPMovieTimeOptionNearestKeyFrame];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(movieThumbnailLoadComplete:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:movieController];
    return movieCell;
}

-(void)movieThumbnailLoadComplete:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"userInfo:%@",userInfo);
	NSNumber *timecode = 
    [userInfo objectForKey: @"MPMoviePlayerThumbnailTimeKey"];	
	UIImage *image = 
    [userInfo objectForKey: @"MPMoviePlayerThumbnailImageKey"];
}
     
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *linkStr = [linkArray objectAtIndex:indexPath.row];
    NSURL *linkURL = [NSURL URLWithString:linkStr];
    //简单视频播放
//    MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc]initWithContentURL:linkURL];
//    [self presentMoviePlayerViewControllerAnimated:movieController];
//    [movieController release];
    CustomMoviePlayerController *movieController = [[CustomMoviePlayerController alloc]init];
    movieController.movieURL = linkURL;
    [self presentModalViewController:movieController animated:YES];
    [movieController release];
}
@end
