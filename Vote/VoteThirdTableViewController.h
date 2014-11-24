//
//  VoteThirdTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-9-7.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FETCHED_ERROR = -1,
    NO_DATA_IN_CUR_CITY,
    FETCHED_DATA,
}FetchResp;

@interface VoteThirdTableViewController : UITableViewController

@property (assign, nonatomic) FetchResp respFlag;

@property (strong, nonatomic) UILabel *fetchRespLable;

@end

#define TTVC_FETCHED_RESP_TAG        1000

#define TTVC_TITLE_FONT              @"ChalkboardSE-Bold"
#define TTVC_TITLE_FONT_SIZE         15.0

#define TTVC_TIMER_FONT              @"ChalkboardSE-Regular"
#define TTVC_TIMER_FONT_SIZE         13.0

#define TTVC_ORGANIZER_FONT          @"ChalkboardSE-Light"
#define TTVC_ORGANIZER_FONT_SIZE     13.0

#define TTVC_GOOD_FONT               @"Verdana"
#define TTVC_GOOD_FONT_SIZE          12.0
