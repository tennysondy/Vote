//
//  VoteHotListTableViewCell.m
//  Vote
//
//  Created by 丁 一 on 14-9-22.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteHotListTableViewCell.h"

@implementation VoteHotListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    CGRect rect;
    if (!self.ctgryImageView) {
        rect = CGRectMake(HLTVCELL_IMG_VIEW_X, HLTVCELL_IMG_VIEW_Y, HLTVCELL_IMG_VIEW_WIDTH, HLTVCELL_IMG_VIEW_HEIGHT);
        self.ctgryImageView = [[UIImageView alloc] initWithFrame:rect];
        self.ctgryImageView.layer.cornerRadius = 6.0f;
        self.ctgryImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.ctgryImageView];
    }
    if (!self.titleLabel) {
        rect = CGRectMake(HLTVCELL_TITLE_X, HLTVCELL_TITLE_Y, HLTVCELL_TITLE_WIDTH, HLTVCELL_TITLE_HEIGHT);
        self.titleLabel = [[UILabel alloc] initWithFrame:rect];
        //self.titleLabel.layer.borderWidth = 1.0;
        //self.titleLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        [self.contentView addSubview:self.titleLabel];
    }
    if (!self.timerLabel) {
        rect = CGRectMake(HLTVCELL_TIMER_X, HLTVCELL_TIMER_Y, HLTVCELL_TIMER_WIDTH, HLTVCELL_TIMER_HEIGHT);
        self.timerLabel = [[UILabel alloc] initWithFrame:rect];
        //self.timerLabel.layer.borderWidth = 1.0;
        //self.timerLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        [self.contentView addSubview:self.timerLabel];
    }
    if (!self.organizerLabel) {
        rect = CGRectMake(HLTVCELL_ORGANIZER_X, HLTVCELL_ORGANIZER_Y, HLTVCELL_ORGANIZER_WIDTH, HLTVCELL_ORGANIZER_HEIGHT);
        self.organizerLabel = [[UILabel alloc] initWithFrame:rect];
        //self.organizerLabel.layer.borderWidth = 1.0;
        //self.organizerLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        [self.contentView addSubview:self.organizerLabel];
    }
    if (!self.goodLabel) {
        rect = CGRectMake(HLTVCELL_GOOD_X, HLTVCELL_GOOD_Y, HLTVCELL_GOOD_WIDTH, HLTVCELL_GOOD_HEIGHT);
        self.goodLabel = [[UILabel alloc] initWithFrame:rect];
        //self.goodLabel.layer.borderWidth = 1.0;
        //self.goodLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        [self.contentView addSubview:self.goodLabel];
    }
    if (!self.goodImgView) {
        rect = CGRectMake(HLTVCELL_GOOD_IMG_X, HLTVCELL_GOOD_IMG_Y, HLTVCELL_GOOD_IMG_WIDTH, HLTVCELL_GOOD_IMG_HEIGHT);
        self.goodImgView = [[UIImageView alloc] initWithFrame:rect];
        self.goodImgView.image = [UIImage imageNamed:@"good.png"];
        [self.contentView addSubview:self.goodImgView];
    }
    if (!self.separator) {
        rect = CGRectMake(0.0, 69.5, 320.0, 0.5);
        self.separator = [[UIView alloc] initWithFrame:rect];
        self.separator.backgroundColor = SEPARATOR_COLOR;
        [self.contentView addSubview:self.separator];
    }
}

- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    self.ctgryImageView.image = [UIImage imageNamed:imageUrl];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setStartTime:(NSDate *)startTime
{
    _startTime = startTime;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.timerLabel.text = [formatter stringFromDate:startTime];
}

- (void)setOrganizer:(NSString *)organizer
{
    _organizer = organizer;
    self.organizerLabel.text = organizer;
}

- (void)setGoodNum:(NSNumber *)goodNum
{
    _goodNum = goodNum;
    self.goodLabel.text = [goodNum stringValue];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
