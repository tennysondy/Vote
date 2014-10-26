//
//  VoteHotListTableViewCell.h
//  Vote
//
//  Created by 丁 一 on 14-9-22.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteHotListTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *ctgryImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *timerLabel;
@property (strong, nonatomic) UILabel *organizerLabel;
@property (strong, nonatomic) UILabel *goodLabel;
@property (strong, nonatomic) UIImageView *goodImgView;
@property (strong, nonatomic) UIView *separator;

@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *organizer;
@property (strong, nonatomic) NSNumber *goodNum;

@end


#define HLTVCELL_IMG_VIEW_X              10.0
#define HLTVCELL_IMG_VIEW_Y              10.0
#define HLTVCELL_IMG_VIEW_WIDTH          50.0
#define HLTVCELL_IMG_VIEW_HEIGHT         50.0

#define HLTVCELL_TITLE_X                 70.0  //HLTVCELL_IMG_VIEW_X + HLTVCELL_IMG_VIEW_WIDTH + 10
#define HLTVCELL_TITLE_Y                 10.0
#define HLTVCELL_TITLE_WIDTH             160.0
#define HLTVCELL_TITLE_HEIGHT            20.0

#define HLTVCELL_TIMER_X                 230.0
#define HLTVCELL_TIMER_Y                 10.0
#define HLTVCELL_TIMER_WIDTH             80.0
#define HLTVCELL_TIMER_HEIGHT            20.0

#define HLTVCELL_ORGANIZER_X             70.0  //HLTVCELL_TITLE_X
#define HLTVCELL_ORGANIZER_Y             40.0  //HLTVCELL_TITLE_Y + HLTVCELL_TITLE_HEIGHT + 10
#define HLTVCELL_ORGANIZER_WIDTH         160.0
#define HLTVCELL_ORGANIZER_HEIGHT        20.0

//赞参数
#define HLTVCELL_GOOD_X                  243.0
#define HLTVCELL_GOOD_Y                  40.0  
#define HLTVCELL_GOOD_WIDTH              52.0
#define HLTVCELL_GOOD_HEIGHT             20.0

//赞图片
#define HLTVCELL_GOOD_IMG_X              297.0
#define HLTVCELL_GOOD_IMG_Y              43.5
#define HLTVCELL_GOOD_IMG_WIDTH          13.0
#define HLTVCELL_GOOD_IMG_HEIGHT         13.0



