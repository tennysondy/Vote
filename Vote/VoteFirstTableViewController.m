//
//  VoteFirstTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-3-2.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteFirstTableViewController.h"
#import "CoreDataHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "Users+UsersHelper.h"
#import "Friends+FriendsHelper.h"
#import "VoteCountDownTimerTableViewCell.h"
#import "VotesInfo+VotesInfoHelper.h"
#import "VoteCreateActivityTableViewController.h"
#import "VoteActivityDetailsTableViewController.h"
#import "VotesUserSetting+Helper.h"
#import "FailedDeletedVotes+Helper.h"
#import "FailedDeletedFriends+Helper.h"
#import "VoteCityTableViewController.h"
#import "City.h"
#import "LoadingIconImageView.h"

@interface VoteFirstTableViewController () <NSFetchedResultsControllerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) AFHTTPRequestOperationManager *AFManager;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSString *curCity;

@property (strong, nonatomic) UIButton *dropDownBtn;

@end

@implementation VoteFirstTableViewController

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
        self.AFManager = [[AFHTTPRequestOperationManager alloc] init];
        self.leftBarButtonItem.title = nil;
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
        NSEntityDescription *votesEntity = [NSEntityDescription entityForName:VOTES_INFO inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:votesEntity];
        
        NSSortDescriptor *sortFirstDescriptor = [NSSortDescriptor sortDescriptorWithKey:VOTE_IS_END ascending:YES];
        NSSortDescriptor *sortSecondDescriptor = [NSSortDescriptor sortDescriptorWithKey:VOTE_END_TIME ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortFirstDescriptor, sortSecondDescriptor, nil]];
        
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSString *username = [ud stringForKey:USERNAME];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"whoseVote.username == %@", username];
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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(resetDatabase:) name:@"Login" object:nil];
    //定位城市
    self.leftBarButtonItem.enabled = NO;
    //添加城市下拉按钮
    self.dropDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dropDownBtn addTarget:self action:@selector(dropDown:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *imageDown = [UIImage imageNamed:@"down.png"];
    [self.dropDownBtn setBackgroundImage:imageDown forState:UIControlStateNormal];
    self.dropDownBtn.showsTouchWhenHighlighted = YES;
    [self.navigationController.navigationBar addSubview:self.dropDownBtn];
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *city = [ud stringForKey:SERVER_CITY];
    if (city != nil) {
        self.leftBarButtonItem.title = city;
    } else {
        self.leftBarButtonItem.title = @"北京";
        [ud setObject:city forKey:SERVER_CITY];
        [ud synchronize];
    }
    //设置城市下拉按钮位置和大小
    [self changeBtnFrameByCity:self.leftBarButtonItem.title];
    
    //self.tableView.backgroundColor = UIColorFromRGB(0xEDEDED);
    self.imagesDownloadQueue = [[NSOperationQueue alloc] init];
    self.imagesDownloadQueue.name = @"download image";
    self.imagesDownloadQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    self.AFManager.operationQueue.maxConcurrentOperationCount = 1;
    self.AFManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    self.AFManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    LoadingIconImageView *activityIndicator = [[LoadingIconImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y - 64);
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    [CoreDataHelper sharedDatabase:^(UIManagedDocument *database) {
        //create nsfetchresultcontroller...
        self.document = database;
        self.managedObjectContext = database.managedObjectContext;
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        authenticated = [ud boolForKey:SERVER_AUTHENTICATED];
        if (authenticated) {
            [self.tableView reloadData];
            NSString *username = [ud objectForKey:USERNAME];
            if ([Users fetchUsersWithUsername:username withContext:self.managedObjectContext] != nil) {
                self.AFManager.operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
            }
            [self fetchUserInfoFromServer];
            [FailedDeletedFriends batchRemoveDeletedFriendsWithContext:self.managedObjectContext];
            [FailedDeletedVotes batchRemoveDeletedVotesWithContext:self.managedObjectContext];
            [self fetchFriendsFromServer];
            [self fetchVotesInfoListFromServer];
            
        }
    }];
}

- (void)dropDown:(id)sender
{
    [self performSegueWithIdentifier:@"Change City" sender:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    authenticated = [ud boolForKey:SERVER_AUTHENTICATED];
    if (authenticated) {
        //开启定位
        [self setupLocationManager];
        //收取未读信息
        [self getUnreadMsg];
        if (self.managedObjectContext) {
            //1. 读取数据库 并显示 2.联网获取数据，检查是否有新的数据，然后reload data
            [self fetchUserInfoFromServer];
            [FailedDeletedFriends batchRemoveDeletedFriendsWithContext:self.managedObjectContext];
            [FailedDeletedVotes batchRemoveDeletedVotesWithContext:self.managedObjectContext];
            [self fetchFriendsFromServer];
            [self fetchVotesInfoListFromServer];
        } else {
            
        }
        [self.dropDownBtn setHidden:NO];

    } else {

    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"will disappear");
    [self.locationManager stopUpdatingLocation];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //清除badge
    [[[[self.tabBarController viewControllers] objectAtIndex:0] tabBarItem] setBadgeValue:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.dropDownBtn setHidden:YES];
}

#pragma mark - CLLocationManagerDelegate

- (void)setupLocationManager
{
    if ([CLLocationManager locationServicesEnabled] == NO || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"user doesn't enable the location service!");
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"无法使用定位服务" message:@"请在手机[设置]->[隐私]->[定位服务]中打开并允许找乐儿使用定位服务，当前默认所在城市为北京，如不相同请手动修改" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        //更新间隔为5分钟
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSDate *lastCheck = [ud objectForKey:LOCATION_SERVICE_CHECK_TIMESTAMP];
        if (lastCheck == nil) {
            [av show];
            [ud setObject:[NSDate date] forKey:LOCATION_SERVICE_CHECK_TIMESTAMP];
            [ud synchronize];
        } else {
            NSTimeInterval sec = [lastCheck timeIntervalSinceNow];
            if (fabs(sec) > 300.0) {
                [av show];
                [ud setObject:[NSDate date] forKey:LOCATION_SERVICE_CHECK_TIMESTAMP];
                [ud synchronize];
            } else {
                
            }
        }
        return;
    }
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 100.0;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.currentLocation = [[CLLocation alloc] init];
    }
    if (self.locationManager != nil) {
        //更新间隔为5分钟
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSDate *lastUpdate = [ud objectForKey:CITY_UPDATE_TIMESTAMP];
        if (lastUpdate == nil) {
            [self.locationManager startUpdatingLocation];
        } else {
            NSTimeInterval sec = [lastUpdate timeIntervalSinceNow];
            if (fabs(sec) > 300.0) {
                [self.locationManager startUpdatingLocation];
            } else {
                
            }
        }
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
    NSLog(@"current location: %@", self.currentLocation);
    //CLLocation *tmpLoc = [[CLLocation alloc] initWithLatitude:43.37 longitude:122.15];
    self.geoCoder = [[CLGeocoder alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.geoCoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            //获取成功，停止定位
            [weakSelf.locationManager stopUpdatingLocation];
            //更新间隔至少为5分钟
            NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
            NSDate *lastUpdate = [ud objectForKey:CITY_UPDATE_TIMESTAMP];
            if (lastUpdate == nil) {
                [ud setObject:[NSDate date] forKey:CITY_UPDATE_TIMESTAMP];
                [ud synchronize];
            } else {
                NSTimeInterval sec = [lastUpdate timeIntervalSinceNow];
                if (fabs(sec) > 300.0) {
                    [ud setObject:[NSDate date] forKey:CITY_UPDATE_TIMESTAMP];
                    [ud synchronize];
                } else {
                    return;
                }
            }
            //位置信息
            CLPlacemark *placeMark = [placemarks objectAtIndex:0];
            NSString *country = placeMark.ISOcountryCode;
            NSString *city = placeMark.locality;
            if (city == nil) {
                city = placeMark.administrativeArea;
            }
            NSLog(@"%@", placemarks);
            NSLog(@"%@--%@--%@", country, placeMark.administrativeArea, city);
            //获取系统当前语言
            NSArray *languages = [NSLocale preferredLanguages];
            NSString *currentLanguage = [languages objectAtIndex:0];
            NSLog( @"%@" , currentLanguage);
            if ([currentLanguage isEqualToString:@"zh-Hans"] == NO) {
                City *tmp = [[City alloc] init];
                id value = [tmp.cityMap objectForKey:city];
                if ([value isKindOfClass:[NSString class]]) {
                    weakSelf.curCity = value;
                } else {
                    //通过省份排除掉拼音相同的城市
                    weakSelf.curCity = [value objectForKey:placeMark.administrativeArea];
                }
            } else {
                //如果系统语言是中文，则去掉“市”字
                weakSelf.curCity = [city substringToIndex:city.length-1];
            }
            NSLog(@"city::%@", weakSelf.curCity);
            NSString *preCity = [ud stringForKey:SERVER_CITY];
            if ([weakSelf.curCity isEqualToString:preCity] == NO) {
                NSString *msg = [NSString stringWithFormat:@"系统定位您在%@，是否切换？", weakSelf.curCity];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:weakSelf cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"get location failed, error msg:%@", error);
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }
    self.leftBarButtonItem.title = self.curCity;
    [self changeBtnFrameByCity:self.leftBarButtonItem.title];
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    [ud setObject:self.curCity forKey:SERVER_CITY];
    [ud synchronize];
}

- (IBAction)changeCity:(id)sender {
    
    //[self performSegueWithIdentifier:@"Change City" sender:self];
}


# pragma mark - reset database

- (void)resetDatabase:(NSNotification*)notification
{
    self.fetchedResultsController = nil;
}

# pragma mark - fetch data from server

- (void)fetchVotesInfoListFromServer
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *votesInfoURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_vote.php"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSDictionary *parameters = @{SERVER_USERNAME: username};
    __weak NSManagedObjectContext *context = self.managedObjectContext;
    [self.AFManager GET:votesInfoURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //1. 和数据库比对，如果存在并需要修改，则修改，不存在则创建，如果不存在创建新的
        NSArray *votes = (NSArray *)[responseObject objectForKey:SERVER_VOTES];
        if ((NSNull *)votes != [NSNull null]) {
            if ([votes count] > 0) {
                [VotesInfo updateDatabaseWithList:votes withContext:context];
                [context save:NULL];
            }
        }
        [self.tableView reloadData];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}


- (void)fetchUserInfoFromServer
{
    NSString *userInfoURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_user_info.php"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSDictionary *parameters = @{SERVER_USERNAME: username, SERVER_FETCH_NAME: username};
    __weak NSManagedObjectContext *context = self.managedObjectContext;
    __weak NSOperationQueue *queue = self.imagesDownloadQueue;
    [self.AFManager GET:userInfoURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        //1. 和数据库比对，如果存在并需要修改，则修改，不存在则创建，如果不存在创建新的
        [Users updateDatabaseWithData:(NSDictionary *)responseObject withContext:context withQueue:queue];
        [self.tableView reloadData];
        [context save:NULL];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        if (context) {
            //get login username
            NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
            NSString *username = [ud stringForKey:USERNAME];
            //get the name of a friend
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", username];
            NSArray *users = [CoreDataHelper searchObjectsForEntity:USERS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
            if ([users count] == 0) {
                [context performBlock:^{
                    [Users insertUsersToDatabaseWithData:nil withManagedObjectContext:context withQueue:nil];
                    [context save:NULL];
                    [self.tableView reloadData];
                }];
            } else if (users == nil) {
                NSLog(@"fetch data error from database in first table view");
            }

        }
    }];
}

- (void)fetchFriendsFromServer
{
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    
    NSString *friendsListURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_friend.php"];
    NSDictionary *parameters = @{SERVER_USERNAME: username};
    __weak NSManagedObjectContext *context = self.managedObjectContext;
    __weak NSOperationQueue *queue = self.imagesDownloadQueue;
    [self.AFManager GET:friendsListURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        if ((NSNull *)[responseObject objectForKey:SERVER_FRIENDS_ARRAY] == [NSNull null]) {
            return;
        }
        //1. 和数据库比对，如果存在并需要修改，则修改，不存在则创建，如果不存在创建新的
        NSArray *data = [[NSArray alloc] initWithArray:[responseObject objectForKey:SERVER_FRIENDS_ARRAY]];
        if ([data count]) {
            [Friends updateDatabaseWithData:data withContext:context withQueue:queue];
            [context save:NULL];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
    }];
    
}

- (void)fetchScreenNameFromServerOfUsername:(NSString *)username ofCell:(VoteCountDownTimerTableViewCell *)cell
{
    NSString *friendsListURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_screen_name.php"];
    NSDictionary *parameters = @{SERVER_USERNAME: username};
    [self.AFManager GET:friendsListURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    numberOfRows = [sectionInfo numberOfObjects];
    
    NSLog(@"section num = %ld, row num = %ld", (long)section, (long)numberOfRows);
    
    //添加友好提示信息
    UIImageView *imageView;
    if (numberOfRows == 0) {
        imageView = (UIImageView *)[self.view viewWithTag:FTVC_NOTHING_IMG_TAG];
        if (imageView == nil) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 193.5, 74.5)];
            imageView.image = [UIImage imageNamed:@"nothing.png"];
            imageView.center = CGPointMake(self.view.center.x, self.view.center.y - 64);
            imageView.tag = FTVC_NOTHING_IMG_TAG;
            [self.view addSubview:imageView];
        }
        self.tableView.backgroundColor = [UIColor whiteColor];
    } else {
        imageView = (UIImageView *)[self.view viewWithTag:FTVC_NOTHING_IMG_TAG];
        if (imageView != nil) {
            [imageView removeFromSuperview];
        }
        self.tableView.backgroundColor = UIColorFromRGB(0xEDEDED);
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Count Down Timer";
    VoteCountDownTimerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    VotesInfo *aVote = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.imageUrl = aVote.imageUrl;
    cell.title = aVote.title;
    if ([aVote.thePublic boolValue] == YES) {
        cell.thePublic = aVote.thePublic;
    } else {
        cell.anonymous = aVote.anonymous;
    }
    cell.endTime = aVote.endTime;
    NSString *screenname;
    for (NSDictionary *elem in aVote.participants) {
        if ([[elem objectForKey:USERNAME] isEqualToString:aVote.organizer]) {
            screenname = [elem objectForKey:SCREENNAME];
            break;
        }
    }
    //NSLog(@"participants: %@", aVote.participants);
    cell.organizer = [[NSString alloc] initWithFormat:@"发起人: %@", aVote.organizerSceenName];
    //设置字体
    cell.anonymousLabel.font = [UIFont boldSystemFontOfSize:FIRST_CELL_ANONYMOUS_FONT_SIZE];
    cell.anonymousLabel.textAlignment = NSTextAlignmentCenter;
    cell.anonymousLabel.textColor = [UIColor whiteColor];
    cell.titleLabel.font = [UIFont boldSystemFontOfSize:FIRST_CELL_TITLE_FONT_SIZE];
    cell.timerLabel.font = [UIFont fontWithName:FIRST_CELL_TIMER_FONT size:FIRST_CELL_TIMER_FONT_SIZE];
    if ([aVote.isEnd boolValue] == YES) {
        cell.timerLabel.textColor = [UIColor lightGrayColor];
    } else {
        //cell.timerLabel.textColor = UIColorFromRGB(0x0027E0);
        cell.timerLabel.textColor = UIColorFromRGB(0x20124D);
    }
    cell.timerLabel.textAlignment = NSTextAlignmentRight;
    cell.organizerLabel.font = [UIFont systemFontOfSize:FIRST_CELL_ORGANIZER_FONT_SIZE];
    cell.organizerLabel.textColor = [UIColor lightGrayColor];
    //到期之后的处理
    __weak VoteCountDownTimerTableViewCell *weakCell = cell;
    cell.voteExpireCallBack = ^{
        if ([aVote.isEnd boolValue] == NO) {
            aVote.isEnd = [NSNumber numberWithBool:YES];
            weakCell.timerLabel.textColor = [UIColor lightGrayColor];
        }
    };
    [cell startTimer];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        VotesInfo *aVote = [self.fetchedResultsController objectAtIndexPath:indexPath];
        VotesUserSetting *aVoteUS = [VotesUserSetting fetchVoteUserSetting:aVote.voteID withContext:self.managedObjectContext];
        //永久删除数据，向服务器发送永久删除信息
        [VotesInfo deleteVotesInfoOnServer:aVote.voteID withManagedObjectContext:self.managedObjectContext forever:YES];
        //从本地数据库删除
        [VotesInfo deleteVotesInfo:aVote withManagedObjectContext:self.managedObjectContext];
        /*
        if ([aVoteUS.deleteForever boolValue] == YES) {
            //永久删除数据，向服务器发送永久删除信息
            [VotesInfo deleteVotesInfoOnServer:aVote.voteID withManagedObjectContext:self.managedObjectContext forever:YES];
            //从本地数据库删除
            [VotesInfo deleteVotesInfo:aVote withManagedObjectContext:self.managedObjectContext];
        } else {
            //临时删除数据，向服务器发送临时删除信息
            //[VotesInfo deleteVotesInfoOnServer:aVote.voteID withManagedObjectContext:self.managedObjectContext forever:NO];
            //从本地数据库删除
            [VotesInfo deleteVotesInfo:aVote withManagedObjectContext:self.managedObjectContext];
        }
         */
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//收取当前用户的未读信息个数
- (void)getUnreadMsg
{
    //设置提示信息
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_badge.php"];
    NSDictionary *para = @{SERVER_USERNAME:username};
    NSLog(@"URL para = %@", para);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        NSNumber *usrVoteBadgeNum = [[NSNumber alloc] init];
        usrVoteBadgeNum = [responseObject objectForKey:SERVER_USR_VOTE_BADGE_NUM];
        NSNumber *friendsBadgeNum = [[NSNumber alloc] init];
        friendsBadgeNum = [responseObject objectForKey:SERVER_FRIEND_BADGE_NUM];
        if ([[usrVoteBadgeNum stringValue] isEqualToString:@"0"]) {
            [[[[self.tabBarController viewControllers] objectAtIndex:0] tabBarItem] setBadgeValue:nil];
        } else {
            [[[[self.tabBarController viewControllers] objectAtIndex:0] tabBarItem] setBadgeValue:[usrVoteBadgeNum stringValue]];
        }
        if ([[friendsBadgeNum stringValue] isEqualToString:@"0"]) {
            [[[[self.tabBarController viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:nil];
        } else {
            [[[[self.tabBarController viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:[friendsBadgeNum stringValue]];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
    }];

}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    if ([segue.identifier isEqualToString:@"Create Activity"]) {
        [self.dropDownBtn setHidden:YES];
        VoteCreateActivityTableViewController *vc = [segue destinationViewController];
        vc.imagesDownloadQueue = self.imagesDownloadQueue;
    }
    if ([segue.identifier isEqualToString:@"Activity Details"]) {
        [self.dropDownBtn setHidden:YES];
        VoteCountDownTimerTableViewCell *cell = (VoteCountDownTimerTableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        VotesInfo *aVote = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        VoteActivityDetailsTableViewController *vc = [segue destinationViewController];
        vc.voteId = aVote.voteID;
    }
    if ([segue.identifier isEqualToString:@"Change City"]) {
        VoteCityTableViewController *tvc = [[segue.destinationViewController viewControllers] firstObject];
        __weak __typeof(self)weakSelf = self;
        tvc.changeCity = ^(NSString *city){
            weakSelf.leftBarButtonItem.title = city;
            [weakSelf changeBtnFrameByCity:weakSelf.leftBarButtonItem.title];
            NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
            [ud setObject:city forKey:SERVER_CITY];
            [ud synchronize];
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
