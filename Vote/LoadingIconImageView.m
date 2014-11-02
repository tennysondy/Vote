//
//  LoadingIconImageView.m
//  LocationTest
//
//  Created by 丁 一 on 14-10-29.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "LoadingIconImageView.h"

@implementation LoadingIconImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        //self.layer.borderWidth = 1.0;
        //self.layer.borderColor = [UIColor redColor].CGColor;
        self.image = [UIImage imageNamed:@"loadingIcon.png"];
        [self setHidden:YES];
    }
    return self;
}

- (void)startAnimating
{
    [super startAnimating];
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1000;
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [self setHidden:NO];
    
}

- (void)stopAnimating
{
    [super stopAnimating];
    [self.layer removeAllAnimations];
    [self setHidden:YES];
}



@end
