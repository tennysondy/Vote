//
//  VoteHotDetailsTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-9-22.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteHotDetailsTableViewController : UITableViewController

@property (strong, nonatomic) NSNumber *voteId;
@property (strong, nonatomic) NSString *imgUrl;

@end

#define HDTVC_OPTIONS_TITLE_X                  10.0
#define HDTVC_OPTIONS_TITLE_Y                  10.0
#define HDTVC_OPTIONS_TITLE_FONT               @"ChalkboardSE-Regular"
#define HDTVC_OPTIONS_TITLE_FONT_SIZE          13.0

#define HDTVC_OPTIONS_ADDR_X                   10.0