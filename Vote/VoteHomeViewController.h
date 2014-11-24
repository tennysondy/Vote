//
//  VoteHomeViewController.h
//  Vote
//
//  Created by 丁 一 on 14-2-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteHomeViewController : UITabBarController
{
    BOOL authenticated;
}

@property (strong, nonatomic) NSTimer *uTimer;


- (void)pauseTimer;
- (void)resumeTimer;

@end

#define HVC_PRELOAD_VIEW_TAG       1001