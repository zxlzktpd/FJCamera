//
//  FJImagePreviewController.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/19.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJImagePreviewController.h"
#import <FJKit_OC/FJStorage.h>
#import "FJSaveMedia.h"
#import "FJAVCatpureCommonHeader.h"
#import <MediaPlayer/MediaPlayer.h>

@interface FJImagePreviewController ()
{
    CGRect        _frame;
}

@property (nonatomic, strong) FJMediaObject *mediaObject;
@property (nonatomic, copy) void(^callback)(BOOL saved, FJMediaObject *media);
@property (nonatomic, strong) MPMoviePlayerController *player;
@property (nonatomic, assign) BOOL dismissRoot;

@end

@implementation FJImagePreviewController

- (instancetype)initWithMedia:(FJMediaObject *)media callback:(void(^)(BOOL saved, FJMediaObject *media))callback {
    
    if (self = [super initWithNibName:nil bundle:nil]) {
        _mediaObject = media;
        _frame = [UIScreen mainScreen].bounds;
        _callback = callback;
    }
    return self;
}

- (instancetype)init {
    
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithImage: videoURL: callback:" userInfo:nil];
}

+ (instancetype)new {
    
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithImage: videoURL: callback:" userInfo:nil];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    return [self initWithMedia:nil callback:nil];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    return [self initWithMedia:nil callback:nil];
}

- (void)dismissToRoot {
    
    _dismissRoot = YES;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
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

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_buildUI {
    if (_mediaObject.isVideo) {
        // 视频
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:_mediaObject.videoURL];
        player.view.frame = self.view.bounds;
        [self.view addSubview:player.view];
        player.controlStyle = MPMovieControlStyleNone;
        player.shouldAutoplay = YES;
        player.movieSourceType = MPMovieSourceTypeFile;
        [player play];
        self.player = player;
        UIImage *image = [player thumbnailImageAtTime:0.1 timeOption:MPMovieTimeOptionNearestKeyFrame];
        _mediaObject.image = image;
    }else {
        // 图片
        UIImageView *imageView = [[UIImageView alloc] initWithImage:_mediaObject.image];
        imageView.layer.masksToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = CGRectMake(0, 0, _frame.size.width, _frame.size.height);
        [self.view addSubview:imageView];
    }
    
    CGFloat gap = (self.view.bounds.size.width - 160.0) / 5.0;
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(gap, self.view.bounds.size.height - 155.0, 80.0, 80.0)];
    [btnBack setImage:[FJStorage podImage:@"btn_camera_back" class:[self class]] forState:UIControlStateNormal];
    [btnBack setImage:[FJStorage podImage:@"btn_camera_back" class:[self class]] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(_tapBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
    
    UIButton *btnTake = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - gap - 80.0, self.view.bounds.size.height - 155.0, 80.0, 80.0)];
    [btnTake setImage:[FJStorage podImage:@"btn_camera_complete" class:[self class]] forState:UIControlStateNormal];
    [btnTake setImage:[FJStorage podImage:@"btn_camera_complete" class:[self class]] forState:UIControlStateHighlighted];
    [btnTake addTarget:self action:@selector(_tapTake) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnTake];
}

- (void)_tapBack {
    
    self.callback == nil ? : self.callback(NO, nil);
    [self fj_dismiss];
}

- (void)_tapTake {
    
    __weak typeof(self) weakSelf = self;
    if (_mediaObject.isVideo) {
        // 保存视频
        [FJSaveMedia saveMovieToCameraRoll:_mediaObject.videoURL completionBlock:^(NSURL *mediaURL, NSError *error) {
            if (error) {
                [weakSelf.view showError:error];
                return;
            }
            weakSelf.mediaObject.videoURL = mediaURL;
            weakSelf.callback == nil ? : weakSelf.callback(YES, weakSelf.mediaObject);
            if (weakSelf.dismissRoot) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                });
            }else {
                [weakSelf fj_dismiss];
            }
        }];
    }else {
        // 保存图片
        [FJSaveMedia savePhotoToPhotoLibrary:_mediaObject.image completionBlock:^(UIImage *image, NSURL *imageURL, NSError *error) {
            if (error) {
                [weakSelf.view showError:error];
                return;
            }
            weakSelf.mediaObject.image = image;
            weakSelf.mediaObject.imageURL = imageURL;
            weakSelf.callback == nil ? : weakSelf.callback(YES, weakSelf.mediaObject);
            if (weakSelf.dismissRoot) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                });
            }else {
                [weakSelf fj_dismiss];
            }
        }];
    }
}

@end
