//
//  LSVideoEditorViewController.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/31.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSVideoEditorViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LSVideoPlayerView.h"

#import "LSVideoEditor.h"
#import "LSAVCommand.h"
#import "LSDisplayCell.h"

static NSString* collectionHeaderViewIdentifier = @"collectionHeaderView";
static NSString* collectionFooterViewIdentifier = @"collectionFooterView";

@interface LSVideoEditorViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LSVideoPlayerViewDelegate>
@property (nonatomic, strong) LSVideoEditor* videoEditor;
@property (nonatomic, strong) LSVideoPlayerView* player;

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* images;

@property (nonatomic, strong) NSMutableArray* videoQueue;
@end

@implementation LSVideoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.images = [NSMutableArray array];
    self.videoEditor = [[LSVideoEditor alloc] init];
    
//    self.player = [[LSVideoPlayerView alloc] initWithAsset:self.asset frame:CGRectMake(0, 40, KScreenWidth, KScreenWidth)];
    
    NSMutableArray* videoQueue = [NSMutableArray array];
    self.videoQueue = videoQueue;
    NSString *firstVideoPath = [[NSBundle mainBundle] pathForResource:@"nnn" ofType:@"mp4"];
    AVAsset* asset1 = [AVAsset assetWithURL:[NSURL fileURLWithPath:firstVideoPath]] ;
    
    NSString *secondVideoPath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    AVAsset* asset2 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:secondVideoPath] options:nil];
    
    NSString *thirdVideoPath = [[NSBundle mainBundle] pathForResource:@"dance" ofType:@"mp4"];
    AVAsset* asset3 = [AVAsset assetWithURL:[NSURL fileURLWithPath:thirdVideoPath]] ;
    
    [videoQueue addObject:asset1];
    [videoQueue addObject:asset2];
    [videoQueue addObject:asset3];
    
    self.player = [[LSVideoPlayerView alloc] initWithVideoQueue:videoQueue frame:CGRectMake(0, 40, KScreenWidth, KScreenWidth)];
    
    self.player.isUsingRemoteCommand = YES;
    self.player.singleCirclePlay = NO;
    self.player.delegate = self;
    [self.view addSubview:self.player];
    [self.player play];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize = CGSizeMake(85, 85);
    flowLayout.headerReferenceSize = CGSizeMake(KScreenWidth/2+1, 85);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-1, KScreenWidth+60+10, KScreenWidth+2, 85) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    self.collectionView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.collectionView.layer.borderWidth = 1;
    self.collectionView.layer.masksToBounds = YES;
  
    [self.collectionView registerClass:[LSDisplayCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionHeaderViewIdentifier];
    [self.collectionView registerClass:[UICollectionElementKindSectionFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:collectionFooterViewIdentifier];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(KScreenWidth/2-1, self.collectionView.frame.origin.y, 2, self.collectionView.frame.size.height)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:lineView];
    
    UIButton* addMusicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addMusicBtn.frame = CGRectMake(35, KScreenHeight - 90, 100, 45);
    [addMusicBtn setTitle:@"add music" forState:UIControlStateNormal];
    [addMusicBtn addTarget:self action:@selector(addMusic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addMusicBtn];
    
    UIButton* addWatermarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addWatermarkBtn.frame = CGRectMake(170, KScreenHeight - 90, 45, 45);
    [addWatermarkBtn setTitle:@"水印" forState:UIControlStateNormal];
    [addWatermarkBtn addTarget:self action:@selector(addWatermark) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addWatermarkBtn];
    
    UIButton* exportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    exportBtn.frame = CGRectMake(KScreenWidth - 135, KScreenHeight - 90, 100, 45);
    [exportBtn setTitle:@"export" forState:UIControlStateNormal];
    [exportBtn addTarget:self action:@selector(export) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exportBtn];
    
    UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(15, 10, 45, 20);
    [backBtn setTitle:@"back" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}

#pragma mark -- LSVideoPlayerDelegate

- (void)LSVideoPlayerDidPlayedToTime:(CMTime)time{
    if (self.player.playerState == LSPlayerStatePlaying) {
        CGFloat currentTime = time.value*1.0/time.timescale;
        CGFloat timeLong = self.asset.duration.value*1.0/self.asset.duration.timescale;
        [self.collectionView setContentOffset:CGPointMake(85*self.images.count*currentTime/timeLong, 0)];
    }
}

- (void)LSVideoPlayer:(LSVideoPlayerView *)player readyToPlayVideoOfIndex:(NSInteger)index{
    // we need to get all images of the video to played
    AVAsset* asset = [self.videoQueue objectAtIndex:index];
    [self.images removeAllObjects];
    [self.videoEditor centerFrameImageWithAsset:asset completion:^(UIImage *image) {
        [self.images addObject:image];
        [self.collectionView reloadData];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (LSDisplayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LSDisplayCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImage* image = self.images[indexPath.row];
    [cell setContentImage:image];
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionHeaderViewIdentifier forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }else if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:collectionFooterViewIdentifier forIndexPath:indexPath];
        footerView.backgroundColor = [UIColor clearColor];
        return footerView;
    }
    return nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.player.playerState == LSPlayerStateStop) {
        CGPoint offset = scrollView.contentOffset;
        NSTimeInterval seconds =  offset.x*CMTimeGetSeconds(self.asset.duration)/(85*self.images.count);
        CMTime seekTime = CMTimeMakeWithSeconds(seconds, self.player.currentPlayItem.duration.timescale);
        [self.player seekToTime:seekTime];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.player pause];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.player play];
}

- (void)addMusic{
    __weak typeof(self) weakSelf = self;
    [self.videoEditor addMusicToAsset:self.asset completion:^(LSAVCommand *avCommand) {
        [weakSelf.player replaceItemWithAsset:avCommand.mutableComposition];
    }];
}

- (void)addWatermark{
    __weak typeof(self) weakSelf = self;
    [self.videoEditor addWatermark:LSWatermarkTypeImage inAsset:self.asset completion:^(LSAVCommand *avCommand) {
        //we have to create a layer manually added to the playerview, otherwise it will not show
        [weakSelf.player replaceItemWithAsset:avCommand.mutableComposition];
    }];
}

- (void)export{
    [self.videoEditor exportAsset:self.asset];
}

- (void)back{
    [self.player destroy];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc{
    NSLog(@"-- video editor view controller dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
