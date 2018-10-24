//
//  ViewController.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/10/24.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "ViewController.h"
#import "RealtimeFilterViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 80, 45);
    [btn setTitle:@"跳转" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor blueColor];
    [btn addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
}

- (void) jump{
    RealtimeFilterViewController* vc = [[RealtimeFilterViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
}
@end
