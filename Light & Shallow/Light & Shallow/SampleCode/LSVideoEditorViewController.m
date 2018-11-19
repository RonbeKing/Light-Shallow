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

@interface LSVideoEditorViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LSVideoPlayerViewDelegate>
@property (nonatomic, strong) LSVideoEditor* videoEditor;
@property (nonatomic, strong) LSVideoPlayerView* player;

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* images;

@end

@implementation LSVideoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.images = [NSMutableArray array];
    self.videoEditor = [[LSVideoEditor alloc] init];
    
    self.player = [[LSVideoPlayerView alloc] initWithAsset:self.asset frame:CGRectMake(0, 40, KScreenWidth, KScreenWidth)];
    self.player.delegate = self;
    [self.view addSubview:self.player];
    [self.player play];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    // 设置UICollectionView为横向滚动
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    // 每一行cell之间的间距
    flowLayout.minimumLineSpacing = 0;
    // 每一列cell之间的间距
    // flowLayout.minimumInteritemSpacing = 10;
    // 设置第一个cell和最后一个cell,与父控件之间的间距
    //flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    //    flowLayout.minimumLineSpacing = 1;// 根据需要编写
    //    flowLayout.minimumInteritemSpacing = 1;// 根据需要编写
    flowLayout.itemSize = CGSizeMake(85, 85);// 该行代码就算不写,item也会有默认尺寸

    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, KScreenWidth+60, KScreenWidth, 85) collectionViewLayout:flowLayout];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[LSDisplayCell class] forCellWithReuseIdentifier:@"cell"];

    [self.videoEditor centerFrameImageWithAsset:self.asset completion:^(UIImage *image) {
        [self.images addObject:image];
        [self.collectionView reloadData];
    }];
//    __block CGFloat time = self.asset.duration.value/self.asset.duration.timescale;
//    __block CGFloat trackedTime = 0;
//    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.006 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        if (trackedTime < time) {
//            [self.collectionView setContentOffset:CGPointMake(85*self.images.count*trackedTime/time, 0)];
//            trackedTime+=0.01;
//        }else{
//            [self.collectionView setContentOffset:CGPointMake(0, 0)];
//            trackedTime = 0;
//        }
//    }];
    
    
    UIButton* addMusicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addMusicBtn.frame = CGRectMake(35, KScreenHeight - 90, 100, 45);
    [addMusicBtn setTitle:@"add music" forState:UIControlStateNormal];
    [addMusicBtn addTarget:self action:@selector(addMusic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addMusicBtn];
    
    UIButton* addWatermarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addWatermarkBtn.frame = CGRectMake(170, KScreenHeight - 90, 100, 45);
    [addWatermarkBtn setTitle:@"添加水印" forState:UIControlStateNormal];
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

- (void)LSVideoPlayerDidPlayedToTime:(CMTime)time{
    CGFloat currentTime = time.value*1.0/time.timescale;
    CGFloat timeLong = self.asset.duration.value*1.0/self.asset.duration.timescale;
    [self.collectionView setContentOffset:CGPointMake(85*self.images.count*currentTime/timeLong, 0)];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
