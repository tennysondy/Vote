//
//  VoteActivityDetailsTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-6-27.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteActivityDetailsTableViewController.h"
#import "CoreDataHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "VotesInfo+VotesInfoHelper.h"
#import "Options+OptionsHelper.h"
#import "VoteBarResultsView.h"
#import "VoteChooseOptionsTableViewController.h"
#import "VoteOptionDetailsTableViewController.h"
#import "VoteLookUpParticipantsViewController.h"
#import "NSString+NSStringHelper.h"


@interface VoteActivityDetailsTableViewController () <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>
{
    NSUInteger votersTotalNum;
    NSUInteger timerCount[40];
    BOOL animtnBar[40];
    BOOL animtnLabel[40];
    float stepValue[40];
    NSUInteger voteNum[40];
}

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) VotesInfo *aVote;

@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *percent;

@property (strong, nonatomic) NSTimer *uTimer;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation VoteActivityDetailsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.document = nil;
        self.managedObjectContext = nil;
        self.fetchedResultsController = nil;
        memset(timerCount, 0, sizeof(timerCount));
        memset(animtnBar, 0, sizeof(animtnBar));
        memset(animtnLabel, 0, sizeof(animtnLabel));
    }
    
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return  _fetchedResultsController;
    }
    
    if (self.managedObjectContext) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *votesEntity = [NSEntityDescription entityForName:VOTES_OPTIONS inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:votesEntity];
        
        NSSortDescriptor *sortDescriptorRows = [NSSortDescriptor sortDescriptorWithKey:VOTE_OPTIONS_ORDER ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptorRows, nil]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"whichVote.voteID == %@", self.voteId];
        [fetchRequest setPredicate:predicate];
        
        [fetchRequest setFetchBatchSize:0];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *error = NULL;
        if (![self.fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        return _fetchedResultsController;
    }
    
    return nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [CoreDataHelper sharedDatabase:^(UIManagedDocument *database) {
        self.document = database;
        self.managedObjectContext = database.managedObjectContext;
        self.aVote = [VotesInfo fetchVotesWithVoteID:self.voteId withContext:self.managedObjectContext];
        votersTotalNum = [self getVotersNumber];
        [self.tableView reloadData];
        //[self fetchVotesInfoFromServer];
        [self startTimer];

    }];
    self.imagesDownloadQueue = [[NSOperationQueue alloc] init];
    self.imagesDownloadQueue.name = @"download options image";
    self.imagesDownloadQueue.maxConcurrentOperationCount = 3;
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchVotesInfoFromServer];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.uTimer = [NSTimer timerWithTimeInterval:0.05f target:self selector:@selector(updateCount:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.uTimer forMode:NSRunLoopCommonModes];
    [self.uTimer fire];

}

- (void)updateCount:(id)sender
{
    NSInteger numberOfRows;
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    numberOfRows = [sectionInfo numberOfObjects];
    for (int i = 0; i < numberOfRows; i++) {
        if (animtnLabel[i] == YES) {
            continue;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:2];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell == nil) {
            timerCount[i] = 0;
            continue;
        }
        UILabel *number = (UILabel *)[cell.contentView viewWithTag:ADTVC_OPTIONS_VOTE_PERCENT_TAG];
        NSArray *array = [number.text componentsSeparatedByString:@"%"];
        //将NSString转化为NSNumber
        NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
        [format setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *value = [format numberFromString:[array firstObject]];

        float num = [value floatValue] + stepValue[indexPath.row];
        number.text = [NSString stringWithFormat:@"%04.1f%%(%lu)",num, (unsigned long)voteNum[indexPath.row]];
        //NSLog(@"indexPath: %@, number.text: %@, flag: %d", indexPath, number.text, animtnLabel[i]);

        if (timerCount[i] == ADTVC_UTIMER_REPEAT_COUNT-1) {
            animtnLabel[i] = YES;
        }
        //NSLog(@"timerCount: %lu", (unsigned long)timerCount[i]);
        timerCount[i]++;
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    //[self.uTimer invalidate];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Network functions

- (void)startLoadingView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 134, 30)];
    //titleView.layer.borderColor = [UIColor whiteColor].CGColor;
    //titleView.layer.borderWidth = 1.0;
    titleView.backgroundColor = [UIColor clearColor];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 3, 24, 24)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    [titleView addSubview:activityIndicator];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 105, 30)];
    label.text = @"更新数据中...";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:17.0f];
    //label.layer.borderColor = [UIColor whiteColor].CGColor;
    //label.layer.borderWidth = 1.0;
    [titleView addSubview:label];
    self.navigationItem.titleView = titleView;
}

- (void)stopLoadingView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.titleView = nil;
    });
}

- (void)fetchVotesInfoFromServer
{
    [self startLoadingView];
    NSString *votesInfoURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_vote_detail.php"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSDictionary *parameters = @{SERVER_USERNAME: username, SERVER_VOTE_ID:self.voteId};
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:votesInfoURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        [self stopLoadingView];
        NSLog(@"vote update tag: %@", self.aVote.voteUpdateTag);
        NSNumber *voteUpdateTag;
        if ( [responseObject objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != nil && (NSNull *)[responseObject objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != [NSNull null] ) {
            voteUpdateTag = [responseObject objectForKey:SERVER_VOTE_VOTE_TIMESTAMP];
            if ([self.aVote.voteUpdateTag isEqualToNumber:voteUpdateTag] && [self.aVote.voteUpdateFlag boolValue] == NO ) {
                return;
            }
        }
        //1. 和数据库比对，如果存在并需要修改，则修改
        //如果不一样，则延迟1秒刷新数据，等待tableview柱状条动画完成
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.managedObjectContext) {
                [self.managedObjectContext performBlock:^{
                    [VotesInfo updateDatabaseWithDetails:(NSDictionary *)responseObject withContext:self.managedObjectContext withQueue:self.imagesDownloadQueue];
                    [self.managedObjectContext save:NULL];
                    /*
                     memset(timerCount, 0, sizeof(timerCount));
                     [self.tableView reloadData];
                     NSLog(@"responseObject: %lu, %lu, %lu", (unsigned long)timerCount[0], (unsigned long)timerCount[1], (unsigned long)timerCount[2]);
                     */
                }];
            }
        });

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        [self stopLoadingView];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger numberOfSections = [[self.fetchedResultsController sections] count];
    //NSLog(@"section = %ld", (long)numberOfSections);
    return numberOfSections + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 4;
    } else {
        NSInteger numberOfRows;
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        numberOfRows = [sectionInfo numberOfObjects];
        //NSLog(@"numberOfRows: %ld", (long)numberOfRows);
        
        return numberOfRows;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15.0;
    }
    return 5.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 25.0)];
    //uv.layer.borderWidth = 1.0;
    //uv.layer.borderColor = [[UIColor blackColor] CGColor];
    uv.backgroundColor = UIColorFromRGB(0xEFEFF4);

    return uv;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        //主题
        UIFont *font = [UIFont boldSystemFontOfSize:17.0];
        CGFloat width = 240.0;
        CGFloat height = [NSString calculateTextHeight:self.aVote.title font:font width:width];
        if (height < 50.0) {
            height = 50.0;
        }
        return height + 20;
        
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //描述
            UIFont *font = [UIFont systemFontOfSize:15.0];
            CGFloat width = 290.0;
            CGFloat height = [NSString calculateTextHeight:self.aVote.voteDescription font:font width:width];
            if (height < 20.0) {
                height = 20.0;
            }
            return height + 20;
            
        } else if (indexPath.row == 1) {
            //参加人
            return 40.0;
        } else if (indexPath.row == 2) {
            //多选公开匿名
            return 40.0;
        } else if (indexPath.row == 3) {
            //截止时间
            return 40.0;
        } else {
            return 40.0;
        }
    } else {
        NSIndexPath *actualIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        Options *aOption = [self.fetchedResultsController objectAtIndexPath:actualIndexPath];
        UIFont *font = [UIFont fontWithName:ADTVC_OPTIONS_TITLE_FONT size:ADTVC_OPTIONS_TITLE_FONT_SIZE];
        NSString *text1 = [NSString stringWithFormat:@"A. %@", aOption.name];
        CGFloat width = 300;
        CGFloat height1 = [NSString calculateTextHeight:text1 font:font width:width];
        if ([aOption.businessID integerValue] == BUSINESS_ID_OF_NO_ADDR) {
            
            return 10.0 + height1 + 10.0 + 20.0 + 10.0;
            
        } else {
            NSString *text2 = aOption.address;
            CGFloat height2 = [NSString calculateTextHeight:text2 font:font width:width];
            
            return 10.0 + height1 + 10.0 + height2 + 10.0 + 20.0 + 10.0;
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    // Configure the cell...
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Subject" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([cell.contentView viewWithTag:ADTVC_SUBJECT_TAG] == nil) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, FRAME_HEIGHT(cell)/2 - 25, 50.0, 50.0)];
            imageView.image = [UIImage imageNamed:self.aVote.imageUrl];
            imageView.layer.cornerRadius = 6.0f;
            imageView.clipsToBounds = YES;
            [cell.contentView addSubview:imageView];
            UILabel *subject = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 10.0, 240.0, cell.frame.size.height - 20.0)];
            subject.tag = ADTVC_SUBJECT_TAG;
            subject.numberOfLines = 0;
            subject.lineBreakMode = NSLineBreakByWordWrapping;
            subject.text = self.aVote.title;
            subject.font = [UIFont boldSystemFontOfSize:17.0];
            [cell.contentView addSubview:subject];
        }

    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Description" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([cell.contentView viewWithTag:ADTVC_DESCRIPTION_TAG] == nil) {
                UILabel *decription = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, cell.frame.size.height - 20.0)];
                decription.tag = ADTVC_DESCRIPTION_TAG;
                decription.numberOfLines = 0;
                decription.lineBreakMode = NSLineBreakByWordWrapping;
                decription.text = self.aVote.voteDescription;
                decription.font = [UIFont systemFontOfSize:15.0];
                [cell.contentView addSubview:decription];
            } else {
                UILabel *decription = (UILabel *)[cell.contentView viewWithTag:ADTVC_DESCRIPTION_TAG];
                decription.text = self.aVote.voteDescription;
            }
            NSLog(@"decription: %@", self.aVote.voteDescription);
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Participants" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            while ([cell.contentView.subviews lastObject] != nil) {
                [[cell.contentView.subviews lastObject] removeFromSuperview];
            }
            NSUInteger count = [self.aVote.participants count];
            UILabel *participants;
            if ([self.aVote.anonymous boolValue] == NO) {
                NSString *text = [NSString stringWithFormat:@"共有%lu人参与,", (unsigned long)count];
                CGFloat width = [NSString calculateTextWidth:text font:[UIFont systemFontOfSize:15.0]];
                participants = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, width, cell.frame.size.height - 20.0)];
                participants.font = [UIFont systemFontOfSize:15.0];
                participants.text = text;
                
                if ([cell.contentView viewWithTag:ADTVC_PARTICIPANTS_BTN_TAG] == nil) {
                    UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    checkButton.frame = CGRectMake(10 + width, ADTVC_PARTICIPANTS_BTN_Y, ADTVC_PARTICIPANTS_BTN_WIDTH, ADTVC_PARTICIPANTS_BTN_HEIGHT);
                    checkButton.tag = ADTVC_PARTICIPANTS_BTN_TAG;
                    [checkButton setTitle:@"点击查看" forState:UIControlStateNormal];
                    checkButton.tintColor = [UIColor blueColor];
                    checkButton.backgroundColor = [UIColor whiteColor];
                    //[checkButton.layer setMasksToBounds:YES];
                    //[checkButton.layer setCornerRadius:8.0];
                    [checkButton addTarget:self action:@selector(lookUpParticipants:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:checkButton];
                }
            } else {
                NSString *text = [NSString stringWithFormat:@"共有%lu人参与", (unsigned long)count];
                CGFloat width = [NSString calculateTextWidth:text font:[UIFont systemFontOfSize:15.0]];
                participants= [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, width, cell.frame.size.height - 20.0)];
                participants.font = [UIFont systemFontOfSize:15.0];
                participants.text = text;
            }
            [cell.contentView addSubview:participants];
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Multi-Choice" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSString *anonymous;
            if ([self.aVote.anonymous boolValue]== YES) {
                anonymous = @"匿名投票";
            } else {
                anonymous = @"公开投票";
            }
            NSString *choice;
            if ([self.aVote.maxChoice intValue] > 1) {
                choice = [[NSString alloc] initWithFormat:@"多选:(最多可选%@项)", self.aVote.maxChoice];
            } else {
                choice = @"单选";
            }
            UILabel *voteSetting;
            if ([cell.contentView viewWithTag:ADTVC_VOTE_SETTING_TAG] == nil) {
                voteSetting = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 300, cell.frame.size.height - 20.0)];
                voteSetting.font = [UIFont systemFontOfSize:15.0];
                voteSetting.tag = ADTVC_VOTE_SETTING_TAG;
                [cell.contentView addSubview:voteSetting];
            } else {
                voteSetting = (UILabel *)[cell.contentView viewWithTag:ADTVC_VOTE_SETTING_TAG];
            }
            voteSetting.text = [NSString stringWithFormat:@"%@, %@", anonymous, choice];

        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Deadline" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *deadline;
            if ([cell.contentView viewWithTag:ADTVC_DEADLINE_TAG] == nil) {
                deadline = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 300, cell.frame.size.height - 20.0)];
                deadline.tag = ADTVC_DEADLINE_TAG;
                deadline.font = [UIFont systemFontOfSize:15.0];
                [cell.contentView addSubview:deadline];
            } else {
                deadline = (UILabel *)[cell.contentView viewWithTag:ADTVC_DEADLINE_TAG];
            }
            if ([self.aVote.isEnd boolValue] == YES) {
                deadline.text = @"活动已结束";
            } else {
                deadline.text = [NSString stringWithFormat:@"距结束还有:%@", self.endTime];
            }
            
        }

    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Options" forIndexPath:indexPath];
        while ([cell.contentView.subviews lastObject] != nil) {
            [[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        
        NSIndexPath *actualIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        Options *aOption = [self.fetchedResultsController objectAtIndexPath:actualIndexPath];
        UIFont *font = [UIFont fontWithName:ADTVC_OPTIONS_TITLE_FONT size:ADTVC_OPTIONS_TITLE_FONT_SIZE];
        NSString *text1 = [NSString stringWithFormat:@"A. %@", aOption.name];
        CGFloat width = 300;
        CGFloat height1 = [NSString calculateTextHeight:text1 font:font width:width];
        //投票选项标题
        UILabel *titleLabel;
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(ADTVC_OPTIONS_TITLE_X, ADTVC_OPTIONS_TITLE_Y, width, height1)];
        //titleLabel.tag = ADTVC_OPTIONS_TITLE_TAG;
        titleLabel.font = font;
        titleLabel.text = [[NSString alloc] initWithFormat:@"%@. %@", aOption.order, aOption.name];
        [cell.contentView addSubview:titleLabel];
        CGFloat barView_Y = 0.0;
         //投票选项地址
        UILabel *addrLabel;
        if ([aOption.businessID integerValue] == BUSINESS_ID_OF_NO_ADDR) {
            barView_Y = titleLabel.frame.origin.y + height1 + 10.0;

        } else {
            NSString *text2 = aOption.address;
            CGFloat height2 = [NSString calculateTextHeight:text2 font:font width:width];
            addrLabel = [[UILabel alloc] initWithFrame:CGRectMake(ADTVC_OPTIONS_ADDR_X, ADTVC_OPTIONS_TITLE_Y+height1+5.0, width, height2)];
            addrLabel.font = font;
            addrLabel.text = aOption.address;
            addrLabel.lineBreakMode = NSLineBreakByWordWrapping;
            addrLabel.numberOfLines = 0;
            //addrLabel.layer.borderWidth = 1.0;
            //addrLabel.layer.borderColor = [UIColor blackColor].CGColor;
            [cell.contentView addSubview:addrLabel];
            barView_Y = addrLabel.frame.origin.y + height2 + 10.0;
        }
        //投票选项横向柱状图
        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(ADTVC_OPTIONS_VOTE_BAR_X, barView_Y, ADTVC_OPTIONS_VOTE_BAR_WIDTH, ADTVC_OPTIONS_VOTE_BAR_HEIGHT)];
        bg.backgroundColor = UIColorFromRGB(0xCCCCCC);
        bg.layer.cornerRadius = 9.0f;
        bg.clipsToBounds = YES;
        [cell.contentView addSubview:bg];
        VoteBarResultsView *barView;
        CGRect frame = CGRectMake(ADTVC_OPTIONS_VOTE_BAR_X, barView_Y, ADTVC_OPTIONS_VOTE_BAR_WIDTH, ADTVC_OPTIONS_VOTE_BAR_HEIGHT);
        
        barView = [[VoteBarResultsView alloc] initWithFrame:CGRectMake(ADTVC_OPTIONS_VOTE_BAR_X, barView_Y, 0, ADTVC_OPTIONS_VOTE_BAR_HEIGHT)];
        barView.order = aOption.order;
        barView.tag = ADTVC_OPTIONS_VOTE_BAR_TAG;
        barView.layer.cornerRadius = 9.0f;
        barView.clipsToBounds = YES;
        voteNum[indexPath.row] = [aOption.voters count];
        float fPercent;
        if (votersTotalNum == 0) {
            fPercent = 0.0;
        } else {
            fPercent = voteNum[indexPath.row]/(float)votersTotalNum;
        }
        
        stepValue[indexPath.row] = fPercent*100/ADTVC_UTIMER_REPEAT_COUNT;
        barView.percent = [NSNumber numberWithFloat:fPercent];
        //动画效果
        if (animtnBar[indexPath.row] == NO) {
            [UIView animateWithDuration:ADTVC_BARVIEW_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                barView.frame = frame;
            } completion:^(BOOL finished) {
                animtnBar[indexPath.row] = YES;
            }];
        } else {
            barView.frame = frame;
        }

        [cell.contentView addSubview:barView];
        //投票选项百分比显示
        UILabel *percentLabel;
        percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(ADTVC_OPTIONS_VOTE_BAR_X, barView_Y, ADTVC_OPTIONS_VOTE_BAR_WIDTH, ADTVC_OPTIONS_VOTE_BAR_HEIGHT)];
        percentLabel.font = [UIFont fontWithName:ADTVC_OPTIONS_VOTE_PERCENT_FONT size:ADTVC_OPTIONS_VOTE_PERCENT_FONT_SIZE];
        percentLabel.tag = ADTVC_OPTIONS_VOTE_PERCENT_TAG;
        percentLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:percentLabel];
        if (animtnLabel[indexPath.row] == NO) {
            fPercent = 0.0;
            percentLabel.text = [NSString stringWithFormat:@"%04.1f%%(%lu)", fPercent*100, (unsigned long)voteNum[indexPath.row]];
        } else {
            percentLabel.text = [NSString stringWithFormat:@"%04.1f%%(%lu)", fPercent*100, (unsigned long)voteNum[indexPath.row]];
        }
    }
    
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    votersTotalNum = [self getVotersNumber];
    memset(timerCount, 0, sizeof(timerCount));
    NSLog(@"responseObject: %lu, %lu, %lu", (unsigned long)timerCount[0], (unsigned long)timerCount[1], (unsigned long)timerCount[2]);
    [self.tableView reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        Options *aOption = [self.fetchedResultsController objectAtIndexPath:self.selectedIndexPath];
        if ([aOption.businessID integerValue] == BUSINESS_ID_OF_NO_ADDR) {
            //
            UIActionSheet *myActionSheet;
            if ([self.aVote.anonymous boolValue] == YES) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该选项仅有标题信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [av show];
            } else {
                myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看选项投票人", nil];
                myActionSheet.tag = ADTVC_ACTION_SHEET_NO_ADDR_TAG;
                [myActionSheet showInView:self.view];
            }
        } else {
            UIActionSheet *myActionSheet;
            if ([self.aVote.anonymous boolValue] == YES) {
                myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看选项信息", nil];
            } else {
                myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看选项信息", @"查看选项投票人", nil];
            }
            myActionSheet.tag = ADTVC_ACTION_SHEET_NORMAL_TAG;
            [myActionSheet showInView:self.view];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"取消");
    } else {
        if (actionSheet.tag == ADTVC_ACTION_SHEET_NORMAL_TAG) {
            switch (buttonIndex) {
                case 0:
                    //查看选项信息
                    [self performSegueWithIdentifier:@"Option Details" sender:self];
                    break;
                case 1:
                    //查看投票人信息
                    [self performSegueWithIdentifier:@"Look Up Voters" sender:self];
                    break;
                default:
                    break;
            }
        } else {
            switch (buttonIndex) {
                case 0:
                    //查看投票人信息
                    [self performSegueWithIdentifier:@"Look Up Voters" sender:self];
                    break;
                default:
                    break;
            }
        }

    }
}


- (void)startTimer
{
    // invalidate a previous timer in case of reuse
    if (self.timer)
        [self.timer invalidate];
    
    // create a new timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateCounter) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [self.timer fire];
}


- (void)updateCounter
{
    NSDate *now = [NSDate date];
    //NSLog(@"now = %@, endDate = %@", now, self.endTime);
    // has the target time passed?
    if ([self.aVote.endTime earlierDate:now] == self.aVote.endTime) {
        [self.timer invalidate];
    } else {
        NSUInteger flags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:flags fromDate:now toDate:self.aVote.endTime options:0];
        
        //NSLog(@"there are %ld days, %ld hours, %ld minutes and %ld seconds remaining", (long)[components day], (long)[components hour], (long)[components minute], (long)[components second]);
        if (components.day > 0) {
            self.endTime = [NSString stringWithFormat:@"%ld天%02ld小时%02ld分钟", (long)[components day], (long)[components hour], (long)[components minute]];
        } else {
            NSString *timerString = [NSString stringWithFormat:@"%02ld小时%02ld分钟", (long)[components hour], (long)[components minute]];
            
            self.endTime = [NSString stringWithFormat:@"%@", timerString];
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

- (void)lookUpParticipants:(UIButton *)button
{
    [self performSegueWithIdentifier:@"Look Up Participants" sender:self];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Choose Options"]) {
        VoteChooseOptionsTableViewController *vc = (VoteChooseOptionsTableViewController *)[segue destinationViewController];
        vc.voteId = self.voteId;
    } else if ([segue.identifier isEqualToString:@"Option Details"]) {
        NSLog(@"%lu, %ld", (unsigned long)self.selectedIndexPath.section, (long)self.selectedIndexPath.row);
        Options *aOption = [self.fetchedResultsController objectAtIndexPath:self.selectedIndexPath];
        VoteOptionDetailsTableViewController *vc = [segue destinationViewController];
        vc.name = aOption.name;
        vc.businessID = aOption.businessID;
        vc.address = aOption.address;
        
    } else if ([segue.identifier isEqualToString:@"Look Up Participants"]) {
        VoteLookUpParticipantsViewController *vc = [segue destinationViewController];
        vc.identifier = segue.identifier;
        vc.participants = [NSMutableArray arrayWithArray:self.aVote.participants];
    } else if ([segue.identifier isEqualToString:@"Look Up Voters"]) {
        VoteLookUpParticipantsViewController *vc = [segue destinationViewController];
        vc.identifier = vc.identifier;
        NSLog(@"%lu, %ld", (unsigned long)self.selectedIndexPath.section, (long)self.selectedIndexPath.row);
        Options *aOption = [self.fetchedResultsController objectAtIndexPath:self.selectedIndexPath];
        NSLog(@"voters: %@", aOption.voters);
        NSMutableArray *participants = [[NSMutableArray alloc] init];
        for (NSString *key in aOption.voters) {
            NSString *username = key;
            NSString *screenname = [aOption.voters objectForKey:key];
            NSDictionary *tmp = @{SERVER_USERNAME: username, SERVER_SCREENNAME: screenname};
            [participants addObject:tmp];
        }
        vc.participants = [NSMutableArray arrayWithArray:participants];
    }
    //设置返回键的标题
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

#pragma mark - Vote statics

- (NSUInteger)getVotersNumber
{
    NSUInteger number;
    NSMutableSet *votersSet = [[NSMutableSet alloc] init];
    NSArray *options = [Options fetchOptionsWithVoteID:self.voteId withContext:self.managedObjectContext];
    for (Options *aOption in options) {
        if ([aOption.voters count] > 0) {
            for (NSString *username in aOption.voters) {
                if ([votersSet containsObject:username] == NO) {
                    [votersSet addObject:username];
                }
            }
        }
    }
    number = [votersSet count];
    
    return number;
}

@end
