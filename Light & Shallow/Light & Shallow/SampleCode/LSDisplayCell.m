//
//  LSDisplayCell.m
//  Light & Shallow
//
//  Created by 王珑宾 on 2018/11/19.
//  Copyright © 2018年 com.TTFD. All rights reserved.
//

#import "LSDisplayCell.h"

@interface LSDisplayCell ()
@property (nonatomic, strong) UIImageView* imageView;

@end

@implementation LSDisplayCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

-(void)setContentImage:(UIImage *)image{
    self.imageView.image = image;
}

@end
