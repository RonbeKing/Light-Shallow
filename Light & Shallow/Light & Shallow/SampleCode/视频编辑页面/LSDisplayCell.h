//
//  LSDisplayCell.h
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/19.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSDisplayCell : UICollectionViewCell
@property (nonatomic, strong) UIImage* image;

- (void)setContentImage:(UIImage*)image;
@end
