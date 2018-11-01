//
//  LSSliderView.m
//  Light & Shallow
//
//  Created by zhang benwei on 2018/10/29.
//  Copyright © 2018 com.TTFD. All rights reserved.
//

#import "LSSliderView.h"

@implementation LSSliderView

- (CGRect)trackRectForBounds:(CGRect)bounds{
    return CGRectMake(4, 0, CGRectGetWidth(bounds)-8, 4);
}
@end
