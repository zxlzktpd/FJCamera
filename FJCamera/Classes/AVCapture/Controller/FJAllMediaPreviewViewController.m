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
@property (nonatomic, strong) UIImageView *mediaTypeImageView;
@property (nonatomic, copy) void(^tapBlock)(void);

@end

@implementation FJMediaView

- (instancetype)initWithFrame:(CGRect)frame isVideo:(BOOL)isVideo tapBlock:(void(^)(void))tapBlock {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        
        self.mediaTypeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 64.0) / 2.0, (frame.size.height - 64.0) / 2.0, 64.0, 64.0)];
        self.mediaTypeImageView.contentMode = UIViewContentModeScaleAspectFit;
        if (isVideo) {
            self.mediaTypeImageView.image = [FJStorage podImage:@"ic_video_logo" class:[self class]];
            self.tapBlock = tapBlock;
        }
        [self addSubview:self.mediaTypeImageView];
        UIButton *button = [[UIButton alloc] initWithFrame:self.mediaTypeImageView.frame];
        [self addSubview:button];
        [button addTarget:self action:@selector(_tap) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)_tap {
    
    if (self.mediaTypeImageView.image && self.tapBlock) {
        self.tapBlock();
    }
}

@end

@interface FJAllMediaPreviewViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) MPMoviePlayerController *player;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) NSUInteger page;

@end

@implementation FJAllMediaPreviewViewController

- (MPMoviePlayerController *)player {
    
    if (_player == nil) {
        _player = [[MPMoviePlayerController alloc] init];
        _player.view.frame = self.view.bounds;
        _player.view.backgroundColor = [UIColor clearColor];
        _player.shouldAutoplay = YES;
        _player.controlStyle = MPMovieControlStyleFullscreen;
        _player.movieSourceType = MPMovieSourceTypeFile;
    }
    return _player;
}

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
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)_buildUI {
    
    MF_WEAK_SELF
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
    
    // Player
    if (_player == nil) {
        [self.view addSubview:self.player.view];
        self.player.view.hidden = YES;
        [self fj_addNotification:MPMoviePlayerPlaybackDidFinishNotification notifyParameterBlock:^(NSDictionary *userInfo) {
            weakSelf.player.view.hidden = YES;
        }];
    }
    
    [self _refresh];
}

- (void)_refresh {
    
    MF_WEAK_SELF
    for (FJMediaView *mediaView in self.scrollView.subviews) {
        if ([mediaView isKindOfClass:[FJMediaView class]]) {
            [mediaView removeFromSuperview];
        }
    }
    for (int i = 0; i < self.medias.count; i++) {
        __block FJMediaObject *media = [self.medias objectAtIndex:i];
        FJMediaView *mediaView = [[FJMediaView alloc] initWithFrame:CGRectMake(i * self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height) isVideo:media.isVideo tapBlock:^{
            weakSelf.player.contentURL = media.videoURL;
            weakSelf.player.view.hidden = NO;
            [weakSelf.view bringSubviewToFront:weakSelf.player.view];
            [weakSelf.player play];
        }];
        mediaView.imageView.image = media.image;
        mediaView.tag = 1000 + i;
        [self.scrollView addSubview:mediaView];
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * self.medias.count, self.scrollView.bounds.size.height);
    self.page = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    self.countLabel.text = [NSString stringWithFormat:@"%d/%d", (int)self.page + 1, (int)self.medias.count];
    [self _checkVideo];
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

- (void)_checkVideo {
    
    /*
    FJMediaObject *media = [self.medias fj_arrayObjectAtIndex:self.page];
    if (media == nil) {
        return;
    }
    // FJMediaView *mediaView = (FJMediaView *)[self.scrollView viewWithTag:(1000 + self.page)];
    if (media.isVideo) {
        
    }else {
        
    }
    */
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (self.page == scrollView.contentOffset.x / scrollView.bounds.size.width) {
        return;
    }
    self.page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.countLabel.text = [NSString stringWithFormat:@"%d/%d", (int)self.page + 1, (int)self.medias.count];
    if (self.player.playbackState != MPMoviePlaybackStateStopped) {
        [self.player stop];
        self.player.view.hidden = YES;
    }
    [self _checkVideo];
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
