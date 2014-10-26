//
//  VoteThirdTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-9-7.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteThirdTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "VoteHotListTableViewCell.h"
#import "VoteHotDetailsTableViewController.h"
#import "VoteCityTableViewController.h"

@interface VoteThirdTableViewController ()
{
    BOOL noMore;
    
}

@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *startIndex;
@property (nonatomic, strong) NSArray *curHotList;
@property (nonatomic, strong) NSMutableArray *hotList;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (strong, nonatomic) NSString *city;

@property (strong, nonatomic) UIButton *dropDownBtn;

@property (strong, nonatomic) UILabel *loadingPrompt;

@end

@implementation VoteThirdTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.hotList = [[NSMutableArray alloc] init];
    //定位城市
    self.leftBarButtonItem.enabled = NO;
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    self.city = [ud stringForKey:SERVER_CITY];
    //添加城市下拉按钮
    self.dropDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dropDownBtn addTarget:self action:@selector(dropDown:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *imageDown = [UIImage imageNamed:@"down.png"];
    [self.dropDownBtn setBackgroundImage:imageDown forState:UIControlStateNormal];
    self.dropDownBtn.showsTouchWhenHighlighted = YES;
    [self.navigationController.navigationBar addSubview:self.dropDownBtn];
    if (self.city != nil) {
        self.leftBarButtonItem.title = self.city;
    } else {
        self.leftBarButtonItem.title = @"北京";
    }
    //设置城市下拉按钮位置和大小
    [self changeBtnFrameByCity:self.leftBarButtonItem.title];
    
    self.count = @20;
    self.startIndex = @0;
    noMore = NO;
    [self fetchDataFromServerLoadMore:NO withSender:nil withCity:self.city];
    
    
}

- (void)dropDown:(id)sender
{
    [self performSegueWithIdentifier:@"Hot Change City" sender:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.dropDownBtn setHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.dropDownBtn setHidden:YES];
}

#pragma mark - fetch data from server

- (void)fetchDataFromServerLoadMore:(BOOL)loadMore withSender:(id)sender withCity:(NSString *)city
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIActivityIndicatorView *activityIndicator;
    if (loadMore == YES) {
        NSUInteger tmpCount = [self.count unsignedIntegerValue];
        NSUInteger tmpStartIndex = [self.startIndex unsignedIntegerValue];
        self.startIndex = [NSNumber numberWithUnsignedInteger:(tmpCount+tmpStartIndex)];
    } else {
        if (self.loadingPrompt == nil) {
            self.loadingPrompt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 20)];
            self.loadingPrompt.center = CGPointMake(self.view.center.x, self.view.center.y - 84);
            self.loadingPrompt.textColor = [UIColor lightGrayColor];
            self.loadingPrompt.textAlignment = NSTextAlignmentCenter;
            self.loadingPrompt.font = [UIFont boldSystemFontOfSize:15.0];
            [self.view addSubview:self.loadingPrompt];
        }
        self.loadingPrompt.text = @"正在加载...";
        activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
        activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y - 44);
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:activityIndicator];
        [activityIndicator startAnimating];
        self.startIndex = @0;
        noMore = NO;
    }
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_vote_by_order.php"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [[NSString alloc] initWithString:[ud objectForKey:USERNAME]];
    NSDictionary *parameters = @{SERVER_USERNAME: username, SERVER_COUNT: self.count, SERVER_BEGIN_NUMBER: self.startIndex, SERVER_CITY:self.leftBarButtonItem.title};
    NSLog(@"parameters: %@", parameters);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        [self.loadingPrompt removeFromSuperview];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        if (sender != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem = sender;
            });
        }
        if ([responseObject objectForKey:SERVER_VOTES_BY_ORDER] != [NSNull null]) {
            self.curHotList = [NSArray arrayWithArray:(NSArray *)[responseObject objectForKey:SERVER_VOTES_BY_ORDER]];
        } else {
            self.curHotList = nil;
        }
        
        if (loadMore == NO) {
            if ([self.curHotList count] > 0) {
                self.hotList = [NSMutableArray arrayWithArray:self.curHotList];
            } else {
                self.hotList = nil;
            }
            [self.tableView reloadData];
        } else {
            if ([self.curHotList count] > 0) {
                [self.hotList addObjectsFromArray:self.curHotList];
                [self performSelectorOnMainThread:@selector(appendTableWith) withObject:nil waitUntilDone:NO];
            } else {
                noMore = YES;
                [self.tableView reloadData];
            }
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in second table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        if (sender != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem = sender;
            });
        }
        if (loadMore == NO) {
            self.loadingPrompt.text = @"加载失败";
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    
}

//添加数据到列表:
- (void) appendTableWith
{
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    for (int ind = 0; ind < [self.curHotList count]; ind++) {
        NSIndexPath *newPath =  [NSIndexPath indexPathForRow:[self.hotList indexOfObject:[self.curHotList objectAtIndex:ind]] inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}


- (IBAction)changeCity:(id)sender {
    [self performSegueWithIdentifier:@"Hot Change City" sender:self];
}



- (IBAction)refresh:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [self fetchDataFromServerLoadMore:NO withSender:sender withCity:self.city];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([self.hotList count] > 0) {
        return [self.hotList count] + 1;
    } else {
        return 0;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.hotList count]) {
        return 44.0;
    }
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VoteHotListTableViewCell *cell;
    
    if (indexPath.row == [self.hotList count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Load More" forIndexPath:indexPath];
        if (noMore == YES) {
            cell.textLabel.text = @"已加载到最后一条";
        } else {
            cell.textLabel.text = @"加载更多";
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        
        CGRect rect = CGRectMake(0.0, 43.5, 320.0, 0.5);
        UIView *separator = [[UIView alloc] initWithFrame:rect];
        separator.backgroundColor = SEPARATOR_COLOR;
        [cell.contentView addSubview:separator];
        
        return cell;
    }
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.imageUrl = [[self.hotList objectAtIndex:indexPath.row] objectForKey:SERVER_VOTE_IMAGE_URL];
    cell.title = [[self.hotList objectAtIndex:indexPath.row] objectForKey:SERVER_VOTE_TITLE];
    cell.titleLabel.font = [UIFont fontWithName:TTVC_TITLE_FONT size:TTVC_TITLE_FONT_SIZE];
    NSString *organizer = [[self.hotList objectAtIndex:indexPath.row] objectForKey:SERVER_VOTE_ORGANIZER_SCREENNAME];
    cell.organizer = [[NSString alloc] initWithFormat:@"发起人: %@", organizer];
    cell.organizerLabel.font = [UIFont fontWithName:TTVC_ORGANIZER_FONT size:TTVC_ORGANIZER_FONT_SIZE];
    cell.organizerLabel.textColor = [UIColor lightGrayColor];
    NSNumber *startTime = [[self.hotList objectAtIndex:indexPath.row] objectForKey:SERVER_VOTE_START_TIME];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[startTime doubleValue]];
    NSNumber *goodNum = [[self.hotList objectAtIndex:indexPath.row] objectForKey:SERVER_VOTE_PARTICIPANTS_NUM];
    cell.startTime = date;
    cell.timerLabel.font = [UIFont fontWithName:TTVC_TIMER_FONT size:TTVC_TIMER_FONT_SIZE];
    cell.timerLabel.textAlignment = NSTextAlignmentRight;
    cell.timerLabel.textColor = UIColorFromRGB(0x20124D);
    cell.goodNum = goodNum;
    cell.goodLabel.font = [UIFont fontWithName:TTVC_GOOD_FONT size:TTVC_GOOD_FONT_SIZE];
    cell.goodLabel.textColor = [UIColor lightGrayColor];
    cell.goodLabel.textAlignment = NSTextAlignmentRight;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.hotList count]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.text = @"正在加载...";
        [self performSelectorInBackground:@selector(loadMore) withObject:nil];
        [cell setHighlighted:NO];
        
    } else {
        [self performSegueWithIdentifier:@"Hot Details" sender:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)loadMore
{
    //加载你的数据
    [self fetchDataFromServerLoadMore:YES withSender:nil withCity:self.city];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Hot Details"]) {
        [self.dropDownBtn setHidden:YES];
        VoteHotDetailsTableViewController *tvc = [segue destinationViewController];
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        tvc.voteId = [[self.hotList objectAtIndex:indexPath.row] objectForKey:SERVER_VOTE_ID];
        tvc.imgUrl = [[self.hotList objectAtIndex:indexPath.row] objectForKey:SERVER_VOTE_IMAGE_URL];
    }
    if ([segue.identifier isEqualToString:@"Hot Change City"]) {
        VoteCityTableViewController *tvc = [[segue.destinationViewController viewControllers] firstObject];
        __weak __typeof(self)weakSelf = self;
        tvc.changeCity = ^(NSString *city){
            weakSelf.leftBarButtonItem.title = city;
            [weakSelf changeBtnFrameByCity:weakSelf.leftBarButtonItem.title];
            weakSelf.city = city;
            [weakSelf fetchDataFromServerLoadMore:NO withSender:nil withCity:city];
        };
    }
    //设置返回键的标题
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

#pragma mark - Help Function
- (void)changeBtnFrameByCity:(NSString *)city
{
    switch ([city length]) {
        case 2:
            [self.dropDownBtn setFrame:CGRectMake(50, 14.5, 15, 15)];
            break;
        case 3:
            [self.dropDownBtn setFrame:CGRectMake(68, 14.5, 15, 15)];
            break;
        case 4:
            [self.dropDownBtn setFrame:CGRectMake(83, 14.5, 15, 15)];
            break;
        default:
            [self.dropDownBtn setFrame:CGRectMake(83, 14.5, 15, 15)];
            break;
    }
}

@end
