//
//  FJAllMediaPreviewViewController.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/22.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJAllMediaPreviewViewController.h"
#import "FJMediaObject.h"
#import "FJAVCatpureCommonHeader.h"
#import <MediaPlayer/MediaPlayer.h>

@interface FJMediaView : UIView

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation FJMediaView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
    }
    return self;
}

@end

@interface FJAllMediaPreviewViewController () <UIScrollViewDelegate>

@property (nonatomic,strong) MPMoviePlayerController *player;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) NSUInteger page;

@end

@implementation FJAllMediaPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self _buildUI];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)_buildUI {
    
    // UIScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    self.scrollView = scrollView;
    
    // Top Bar
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64.0)];
    topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self.view addSubview:topView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64.0, 64.0)];
    [backButton setImage:[FJStorage podImage:@"nav_back_w" class:[self class]] forState:UIControlStateNormal];
    [backButton setImage:[FJStorage podImage:@"nav_back_w" class:[self class]] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(_tapBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 64.0, 0, 64.0, 64.0)];
    [deleteButton setImage:[FJStorage podImage:@"nav_delete_w" class:[self class]] forState:UIControlStateNormal];
    [deleteButton setImage:[FJStorage podImage:@"nav_delete_w" class:[self class]] forState:UIControlStateHighlighted];
    [deleteButton addTarget:self action:@selector(_tapDelete) forControlEvents:UIControlEventTouchUpInside];
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(64.0, 0, self.view.bounds.size.width - 128.0, 64.0)];
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.font = [UIFont systemFontOfSize:20.0];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:backButton];
    [topView addSubview:deleteButton];
    [topView addSubview:self.countLabel];
    self.topView = topView;
    [self _refresh];
}

- (void)_refresh {
    
    for (FJMediaView *mediaView in self.scrollView.subviews) {
        if ([mediaView isKindOfClass:[FJMediaView class]]) {
            [mediaView removeFromSuperview];
        }
    }
    for (int i = 0; i < self.medias.count; i++) {
        FJMediaObject *media = [self.medias objectAtIndex:i];
        FJMediaView *mediaView = [[FJMediaView alloc] initWithFrame:CGRectMake(i * self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
        mediaView.imageView.image = media.image;
        mediaView.tag = 1000 + i;
        [self.scrollView addSubview:mediaView];
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * self.medias.count, self.scrollView.bounds.size.height);
    self.page = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    self.countLabel.text = [NSString stringWithFormat:@"%d/%d", (int)self.page + 1, (int)self.medias.count];
    
    [self _autoPlayVideo];
}

- (void)_tapBack {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_tapDelete {
    
    [self.medias removeObjectAtIndex:self.page];
    if (self.medias.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self _refresh];
    }
}

- (void)_autoPlayVideo {
    
    FJMediaObject *media = [self.medias fj_safeObjectAtIndex:self.page];
    if (media == nil) {
        return;
    }
    if (media.isVideo) {
        if (self.player == nil) {
            MPMoviePlayerController *player = [[MPMoviePlayerController alloc] init];
            self.player = player;
            player.view.frame = self.view.bounds;
            player.view.tag = 2000;
            player.controlStyle = MPMovieControlStyleNone;
            player.shouldAutoplay = YES;
            player.movieSourceType = MPMovieSourceTypeFile;
            MF_WEAK_SELF
            [self fj_addNotification:MPMoviePlayerPlaybackDidFinishNotification notifyParameterBlock:^(NSDictionary *userInfo) {
                FJMediaView *mediaView = (FJMediaView *)[weakSelf.scrollView viewWithTag:(1000 + weakSelf.page)];
                    UIView *playerView = [mediaView viewWithTag:2000];
                    playerView.hidden = YES;
                }
            ];
        }
        FJMediaView *mediaView = (FJMediaView *)[self.scrollView viewWithTag:(1000 + self.page)];
        [mediaView addSubview:self.player.view];
        self.player.contentURL = media.videoURL;
        self.player.view.hidden = NO;
        [self.player play];
    }else {
        [self.player stop];
        self.player.view.hidden = YES;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (self.page == scrollView.contentOffset.x / scrollView.bounds.size.width) {
        return;
    }
    self.page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.countLabel.text = [NSString stringWithFormat:@"%d/%d", (int)self.page + 1, (int)self.medias.count];
    
    [self _autoPlayVideo];
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
