//
//  VoteDefaultOptionsListViewController.m
//  Vote
//
//  Created by 丁 一 on 14-6-12.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteDefaultOptionsListViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+AFNetworking.h"
#import "DianPingAPI.h"
#import "WGS84ToGCJ02.h"
#import "WYPopoverController.h"
#import "WYStoryboardPopoverSegue.h"
#import "VotePopoverTableViewController.h"
#import "VoteBusinessDetailsTableViewController.h"
#import "YIInnerShadowView.h"
#import "NSString+NSStringHelper.h"
#import "VoteAddOptionsTableViewController.h"
#import "VoteOptionsAddrListTableViewCell.h"
#import "VoteKeywordOptionsListTableViewController.h"

@interface VoteDefaultOptionsListViewController () <CLLocationManagerDelegate, UITextViewDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, WYPopoverControllerDelegate, GetPopOverTableViewCellTextDelegate, UISearchBarDelegate>
{
    WYPopoverController *popoverController;
    NSInteger currentPage;
    BOOL noMoreList;
    NSArray *width;
    NSNumber *currentMenuIndex;
    CGFloat startContentOffsetX;
    
}

@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocation *preLocation;
@property (strong, nonatomic) NSArray *menuList;
@property (strong, nonatomic) NSMutableDictionary *businessListContainer;
@property (strong, nonatomic) NSMutableDictionary *businessListUpdateTime;
@property (strong, nonatomic) NSMutableArray *businessList;
@property (strong, nonatomic) NSMutableArray *currentBusinessList;
@property (strong, nonatomic) NSString *currentCategory;

@property (strong, nonatomic) UITableView *leftTableView;
@property (strong, nonatomic) UITableView *middleTableView;
@property (strong, nonatomic) UITableView *rightTableView;
@property (strong, nonatomic) UIView *underline;
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UIScrollView *menuScrollView;

@property (weak, nonatomic) IBOutlet UIButton *sortBtn;
@property (strong, nonatomic) NSDictionary *sortType;
@property (strong, nonatomic) NSString *sortKey;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;

@property (strong, nonatomic) UISearchBar *searchBar;

//大众点评网logo
@property (weak, nonatomic) IBOutlet UIView *dpLogo;


@end

@implementation VoteDefaultOptionsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.currentCategory = [[NSString alloc] init];
        self.businessList = [[NSMutableArray alloc] init];
        self.currentBusinessList = [[NSMutableArray alloc] init];
        self.preLocation = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //搜索栏设置
    self.navigationItem.titleView = self.searchBar;
    //初始化菜单
    self.menuList = [NSArray arrayWithObjects:@"美食", @"休闲娱乐", @"运动健身", @"购物", @"生活服务", @"美容", @"酒店", @"爱车", @"家装", nil];
    [self createMenuScrollView];
    //初始化下载数据的container
    self.businessListContainer = [[NSMutableDictionary alloc] initWithCapacity:[self.menuList count]];
    self.businessListUpdateTime = [[NSMutableDictionary alloc] initWithCapacity:[self.menuList count]];
    //初始化tableview
    [self createMainScrollView];
    self.sortBtn.backgroundColor = UIColorFromRGB(0xF5F5F5);
    [self.sortBtn setTintColor:[UIColor blackColor]];
    [self.view bringSubviewToFront:self.sortBtn];
    //是否同城
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *userCity = [ud stringForKey:SERVER_CITY];
    if ([self.city isEqualToString:userCity]) {
        self.sortType = [[NSDictionary alloc] initWithObjectsAndKeys:@7, @"距离最近", @2, @"星级最高", @6, @"评论最多", @8, @"人均最低", @5, @"服务最好", @4, @"环境最优", nil];
        //默认排序
        self.sortKey = @"距离最近";
    } else {
        self.sortType = [[NSDictionary alloc] initWithObjectsAndKeys:@2, @"星级最高", @6, @"评论最多", @8, @"人均最低", @5, @"服务最好", @4, @"环境最优", nil];
        //默认排序
        self.sortKey = @"星级最高";
    }

    [self.sortBtn setTitle:self.sortKey forState:UIControlStateNormal];
    self.currentCategory = [self.menuList objectAtIndex:0];
    currentPage = 1;
    noMoreList = NO;
    currentMenuIndex = @0;
    //创建自定义视图
    //[self createCustomLocationView];
    //[self segmentedCtrlRightViewHidden:YES];
    
    //建立点评网logo
    UIImageView *dpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(98, 3, 12, 12)];
    dpImageView.image = [UIImage imageNamed:@"dpLogo.png"];
    dpImageView.layer.cornerRadius = 2.0;
    dpImageView.clipsToBounds = YES;
    UILabel *dpLabel = [[UILabel alloc] initWithFrame:CGRectMake(114, 3, 108, 12)];
    dpLabel.text = @"数据来自大众点评网";
    dpLabel.textColor = [UIColor whiteColor];
    dpLabel.font = [UIFont systemFontOfSize:12.0f];
    //dpLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    //dpLabel.layer.borderWidth = 1.0;
    [self.dpLogo addSubview:dpImageView];
    [self.dpLogo addSubview:dpLabel];
    self.dpLogo.alpha = 0.6;
    self.dpLogo.backgroundColor = [UIColor blackColor];
    [self.view bringSubviewToFront:self.dpLogo];
    //[self.dpLogo setHidden:YES];
    //建立定位服务
    [self setupLocationManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (IBAction)rightBarButtonItemAction:(id)sender {

    [self performSegueWithIdentifier:@"Custom Address" sender:self];
}

#pragma mark -  UISearchBar

- (UISearchBar *)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.backgroundColor = [UIColor clearColor];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"输入商户名称";
        _searchBar.searchResultsButtonSelected = NO;
        _searchBar.showsSearchResultsButton = NO;
        _searchBar.showsCancelButton = NO;
        _searchBar.showsBookmarkButton = NO;
        _searchBar.tintColor = [UIColor blueColor];
    }
    
    return _searchBar;
}

#pragma mark - UISearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //增加手势，点击空白处收起键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];
}

//收起键盘
- (void)hideKeyBoard:(id)sender
{
    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)sender;
    [self.searchBar  resignFirstResponder];
    [self.view removeGestureRecognizer:tapGestureRecognizer];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([NSString checkWhitespaceAndNewlineCharacter:searchBar.text] == YES) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"无法进行搜索" message:@"搜索栏输入不可为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
    } else {
        [self performSegueWithIdentifier:@"Keyword Search" sender:self];
    }
    
}


#pragma mark - CLLocationManagerDelegate

- (void)setupLocationManager
{
    if ([CLLocationManager locationServicesEnabled] == NO || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"user doesn't enable the location service!");
        //如果没有开启定位服务，则在此处刷新table数据
        [self getDataFromServerWithCategory:self.currentCategory inTableView:self.middleTableView withIndex:currentMenuIndex loadMore:NO refreshAll:YES];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"无法使用定位服务" message:@"请在手机[设置]->[隐私]->[定位服务]中打开并允许找乐儿使用定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
        return;
    }
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 50.0;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.currentLocation = [[CLLocation alloc] init];
    //IOS 8 新增权限申请
    if (SYSTEM_VERSION >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
        //[self.locationManager requestAlwaysAuthorization];
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
    NSLog(@"current location: %@", self.currentLocation);
    CLLocationDistance distance = [self.currentLocation distanceFromLocation:self.preLocation];
    if (distance > SHOULD_UPDATE_DISTANCE) {
        self.preLocation = self.currentLocation;
        [self getDataFromServerWithCategory:self.currentCategory inTableView:self.middleTableView withIndex:currentMenuIndex loadMore:NO refreshAll:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"get location failed, error msg:%@", error);
}

#pragma mark - Create Scroll View

- (void)createMenuScrollView
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.menuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, rect.size.width - self.sortBtn.frame.size.width, 44)];
    
    width = [NSArray arrayWithObjects:@28.0, @56.0, @56.0, @28.0, @56.0, @28.0, @28.0, @28.0, @28.0, nil];
    float x = 0;
    for (int i = 0; i < [self.menuList count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        x = x + 10;
        NSString *title = [NSString stringWithFormat:@"%@", [self.menuList objectAtIndex:i]];
        CGFloat textWidth = [NSString calculateTextWidth:title font:[UIFont systemFontOfSize:14.0]];
        button.frame = CGRectMake(x, 7.0, textWidth+6, 30.0);
        //[NSString stringWithFormat:@"%@", [menuList objectAtIndex:i]]
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        button.tintColor = [UIColor blackColor];
        button.backgroundColor = [UIColor clearColor];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:8.0];
        [button addTarget:self action:@selector(getList:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 2000 + i;
        [self.menuScrollView addSubview:button];
        
        x += button.frame.size.width;
    }
    PrintRect(rect);
    PrintRect(self.sortBtn.frame);
    PrintRect(self.menuScrollView.frame);
    NSLog(@"x = %f", x);
    
    self.menuScrollView.contentSize = CGSizeMake(x+10, 44);
    if (SYSTEM_VERSION >= 8.0) {
        self.menuScrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    }
    self.menuScrollView.backgroundColor = UIColorFromRGB(0xEEEEEE);
    self.menuScrollView.tag = DOLVC_MENU_SCROLL_VIEW_TAG;
    self.menuScrollView.delegate = self;
    self.menuScrollView.panGestureRecognizer.delaysTouchesBegan = YES;
    self.menuScrollView.alwaysBounceVertical = NO;
    self.menuScrollView.alwaysBounceHorizontal = NO;
    //self.menuScrollView.scrollEnabled = NO;
    self.menuScrollView.showsHorizontalScrollIndicator = NO;
    self.menuScrollView.showsVerticalScrollIndicator = NO;
    //self.menuView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.menuScrollView];
    //设置underline
    UIButton *button = (UIButton *)[self.menuScrollView viewWithTag:2000];
    PrintRect(button.frame);
    self.underline = [[UIView alloc] init];
    [self setUnderlineFrameWithButtonIndex:button];
    self.underline.backgroundColor = [UIColor orangeColor];
    [self.menuScrollView addSubview:self.underline];
    
}

- (void)createMainScrollView
{
    CGRect screen = [[UIScreen mainScreen] bounds];
    PrintRect(screen);
    CGRect rect = CGRectMake(screen.origin.x, screen.origin.y + NAVIGATION_BAR_HEIGHT + self.menuScrollView.frame.size.height, screen.size.width, screen.size.height - NAVIGATION_BAR_HEIGHT - self.menuScrollView.frame.size.height);
    const CGFloat offset = screen.size.width;
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
    self.mainScrollView.contentSize = CGSizeMake(rect.size.width*3, rect.size.height);
    self.mainScrollView.delegate = self;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.tag = DOLVC_MAIN_SCROLL_VIEW_TAG;
    CGPoint p = CGPointZero;
    p.x = rect.size.width;
    [self.mainScrollView setContentOffset:p animated:NO];
    //第一个TableView
    self.leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) style:UITableViewStylePlain];
    self.leftTableView.delegate = self;
    self.leftTableView.dataSource= self;
    [self.leftTableView registerClass:[VoteOptionsAddrListTableViewCell class] forCellReuseIdentifier:@"Business List"];
    [self.leftTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"More Business"];
    //第二个TableView
    self.middleTableView = [[UITableView alloc] initWithFrame:CGRectMake(0 + offset, 0, rect.size.width, rect.size.height) style:UITableViewStylePlain];
    self.middleTableView.delegate = self;
    self.middleTableView.dataSource = self;
    [self.middleTableView registerClass:[VoteOptionsAddrListTableViewCell class] forCellReuseIdentifier:@"Business List"];
    [self.middleTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"More Business"];
    //第三个TableView
    self.rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(0 + offset*2, 0, rect.size.width, rect.size.height) style:UITableViewStylePlain];
    self.rightTableView.delegate = self;
    self.rightTableView.dataSource = self;
    [self.rightTableView registerClass:[VoteOptionsAddrListTableViewCell class] forCellReuseIdentifier:@"Business List"];
    [self.rightTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"More Business"];

    
    [self.leftTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.middleTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.rightTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.mainScrollView addSubview:self.leftTableView];
    [self.mainScrollView addSubview:self.middleTableView];
    [self.mainScrollView addSubview:self.rightTableView];
    
    [self.view addSubview:self.mainScrollView];
}


- (void)getList:(UIButton *)button
{
    int i = button.tag%1000;
    currentMenuIndex = [NSNumber numberWithInteger:i];
    self.currentCategory = [self.menuList objectAtIndex:i];
    [self setUnderlineFrameWithButtonIndex:button];
    [self adjustButtonDisplayPosition:button];
    [self getDataFromServerWithCategory:self.currentCategory inTableView:self.middleTableView withIndex:currentMenuIndex loadMore:NO refreshAll:YES];
    
}

#pragma mark - Network functions

- (void)startLoadingView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIView *loadingView;
    UILabel *label;
    UIActivityIndicatorView *activityIndicator;
    if ([self.view viewWithTag:DOLVC_LOADING_VIEW_TAG] == nil) {
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        loadingView.center = self.view.center;
        loadingView.backgroundColor = [UIColor blackColor];
        loadingView.alpha = 0.6;
        loadingView.tag = DOLVC_LOADING_VIEW_TAG;
        loadingView.layer.cornerRadius = 6.0;
        [self.view addSubview: loadingView];
        
        CGRect loadingViewFrame = loadingView.bounds;
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        label.center = CGPointMake(loadingViewFrame.origin.x + loadingViewFrame.size.width/2, loadingViewFrame.origin.y + loadingViewFrame.size.height/2 - 25);
        label.text = @"请稍等...";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [loadingView addSubview:label];
        
        
        activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
        activityIndicator.center = CGPointMake(loadingViewFrame.origin.x + loadingViewFrame.size.width/2, loadingViewFrame.origin.y + loadingViewFrame.size.height/2 + 25);
        [loadingView addSubview: activityIndicator];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.tag = DOLVC_ACTIVITY_INDICATOR_TAG;
        
        [activityIndicator startAnimating];
    }
}

- (void)endLoadingView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIView *loadingView = (UIView *)[self.view viewWithTag:DOLVC_LOADING_VIEW_TAG];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[loadingView viewWithTag:DOLVC_ACTIVITY_INDICATOR_TAG];
    [activityIndicator stopAnimating];
    [loadingView removeFromSuperview];
}

- (void)getDataFromServerWithCategory:(NSString *)category inTableView:(UITableView *)tableView withIndex:(NSNumber *)index loadMore:(BOOL)loadMore refreshAll:(BOOL)refreshAll
{

    [self startLoadingView];

    if (refreshAll == YES) {
        noMoreList = NO;
        currentPage = 1;
    }
    NSLog(@"original location: %f, %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    CLLocationCoordinate2D coordinate = [WGS84ToGCJ02 transformFromWGSToGCJ:self.currentLocation.coordinate];
    NSString *userInfoURL = [[NSString alloc] initWithFormat:@"http://api.dianping.com/v1/business/find_businesses"];
    NSNumber *radius = @5000;
    NSNumber *platform = @2;
    NSNumber *sort = [self.sortType objectForKey:self.sortKey];
    if (loadMore == YES) {
        currentPage++;
    }
    NSNumber *page = [[NSNumber alloc] initWithInteger:currentPage];
    NSNumber *limit = @20;
    NSNumber *offsetType = @1;
    //
    NSDictionary *optionPara;
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *userCity = [ud stringForKey:SERVER_CITY];
    NSLog(@"city: %@", self.city);
    if ([self.city isEqualToString:userCity]) {
        optionPara = @{DIANPING_LATITUDE:[NSNumber numberWithFloat:(float)coordinate.latitude], DIANPING_LONGITUDE:[NSNumber numberWithFloat:(float)coordinate.longitude], DIANPING_OFFSET_TYPE:offsetType, DIANPING_RADIUS:radius, DIANPING_CATEGORY:category, DIANPING_SORT:sort, DIANPING_PAGE:page, DIANPING_LIMIT:limit, DIANPING_PLATFORM:platform};
    } else {
        optionPara = @{DIANPING_CITY:self.city, DIANPING_CATEGORY:category, DIANPING_SORT:sort, DIANPING_PAGE:page, DIANPING_LIMIT:limit, DIANPING_PLATFORM:platform};
    }
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:15];
    [parameters setValuesForKeysWithDictionary:optionPara];
    NSString *sign = [DianPingAPI signGeneratedInSHA1With:optionPara];
    [parameters setObject:APPKEY forKey:DIANPING_APPKEY];
    [parameters setObject:sign forKey:DIANPING_SIGN];
    NSLog(@"Get parameters: %@", parameters);
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:userInfoURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        [self endLoadingView];
        if ([[responseObject objectForKey:DIANPING_STATUS] isEqualToString:@"OK"]) {
            self.currentBusinessList = [NSMutableArray arrayWithArray:[responseObject objectForKey:DIANPING_BUSINESS]];
            if (refreshAll == YES) {
                NSMutableArray *tmpList = [NSMutableArray arrayWithArray:self.currentBusinessList];
                [self.businessListContainer setObject:tmpList forKey:index];
            } else {
                NSMutableArray *tmpList = [self.businessListContainer objectForKey:index];
                [tmpList addObjectsFromArray:self.currentBusinessList];
                //[self.businessListContainer setObject:tmpList forKey:index];
            }
            //NSLog(@"%@", [self.businessList class]);
            //NSLog(@"dd%@", self.businessList);
            //NSLog(@"dd%@", self.businessListContainer);
            if (loadMore == NO) {
                [tableView reloadData];
            } else {
                if ([self.currentBusinessList count] > 0) {
                    [self performSelectorOnMainThread:@selector(appendTableWith) withObject:nil waitUntilDone:NO];
                } else {
                    noMoreList = YES;
                    [tableView reloadData];
                }
                
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        [self endLoadingView];
        
    }];
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.tag == DOLVC_MAIN_SCROLL_VIEW_TAG) {
        startContentOffsetX = scrollView.contentOffset.x;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == DOLVC_MAIN_SCROLL_VIEW_TAG) {
        if (scrollView.contentOffset.x > startContentOffsetX) {
            [self.rightTableView reloadData];
        } else if (scrollView.contentOffset.x < startContentOffsetX) {
            [self.leftTableView reloadData];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == DOLVC_MAIN_SCROLL_VIEW_TAG) {
        CGFloat pageWidth = scrollView.frame.size.width;
        // 0 1 2
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if(page == 1) {
            return;
        } else if (page == 0) {
            [self pageMoveToRight];
        } else {
            [self pageMoveToLeft];
        }
        
        CGPoint p = CGPointZero;
        p.x = pageWidth;
        [scrollView setContentOffset:p animated:NO];
    }
}

- (void)setScrollViewPageFrame
{
    self.leftTableView.frame = CGRectMake(0, 0, self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height);
    self.middleTableView.frame = CGRectMake(0 + self.mainScrollView.frame.size.width, 0, self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height);
    self.rightTableView.frame = CGRectMake(0 + self.mainScrollView.frame.size.width * 2, 0, self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height);
}

- (void)pageMoveToRight
{
    NSInteger tmpIndex = [currentMenuIndex integerValue];
    NSInteger index = (tmpIndex - 1 >= 0)?(tmpIndex - 1):(self.menuList.count - 1);
    currentMenuIndex = [NSNumber numberWithInteger:index];
    self.currentCategory = [self.menuList objectAtIndex:index];
    [self getDataFromServerWithCategory:self.currentCategory inTableView:self.leftTableView withIndex:currentMenuIndex loadMore:NO refreshAll:YES];
    UITableView *tmp = self.middleTableView;
    self.middleTableView = self.leftTableView;
    self.leftTableView = self.rightTableView;
    self.rightTableView = tmp;
    [self.middleTableView reloadData];
    UIButton *button = (UIButton *)[self.menuScrollView viewWithTag:(2000 + index)];
    [self setUnderlineFrameWithButtonIndex:button];
    [self adjustButtonDisplayPosition:button];
    [self setScrollViewPageFrame];
}

- (void)pageMoveToLeft
{
    NSInteger tmpIndex = [currentMenuIndex integerValue];
    NSInteger index = (tmpIndex + 1 < self.menuList.count)?(tmpIndex + 1):0;
    currentMenuIndex = [NSNumber numberWithInteger:index];
    self.currentCategory = [self.menuList objectAtIndex:index];
    [self getDataFromServerWithCategory:self.currentCategory inTableView:self.rightTableView withIndex:currentMenuIndex loadMore:NO refreshAll:YES];
    UITableView *tmp = self.middleTableView;
    self.middleTableView = self.rightTableView;
    self.rightTableView = self.leftTableView;
    self.leftTableView = tmp;
    [self.middleTableView reloadData];
    UIButton *button = (UIButton *)[self.menuScrollView viewWithTag:(2000 + index)];
    [self setUnderlineFrameWithButtonIndex:button];
    [self adjustButtonDisplayPosition:button];
    [self setScrollViewPageFrame];
}

- (void)setUnderlineFrameWithButtonIndex:(UIButton *)button
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                             self.underline.frame = CGRectMake(button.frame.origin.x, self.menuScrollView.frame.size.height - 3, button.frame.size.width, 3);
                     } completion:nil];
}

- (void)adjustButtonDisplayPosition:(UIButton *)button
{
    CGPoint p = CGPointZero;
    p.x = button.center.x - 160;
    if (p.x <= 0.001) {
        p.x = 0.0;
    } else if (p.x + self.menuScrollView.frame.size.width > self.menuScrollView.contentSize.width) {
        p.x = self.menuScrollView.contentSize.width - self.menuScrollView.frame.size.width;
    }
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.menuScrollView setContentOffset:p animated:NO];
                     } completion:nil];
    //[self.menuScrollView setContentOffset:p animated:YES];
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
    NSInteger menuIndex;
    NSInteger tmpIndex = [currentMenuIndex integerValue];
    if (tableView == self.leftTableView) {
        menuIndex = (tmpIndex - 1 >= 0)?(tmpIndex - 1):(self.menuList.count - 1);
    } else if (tableView == self.rightTableView) {
        menuIndex = (tmpIndex + 1 < self.menuList.count)?(tmpIndex + 1):0;
    } else {
        menuIndex = tmpIndex;
    }
    NSLog(@"currentMenuIndex=%@", currentMenuIndex);
    NSLog(@"menuIndex=%ld", (long)menuIndex);
    //NSLog(@"businessListContainer=%@", self.businessListContainer);
    if ([self.businessListContainer count] > 0) {
        self.businessList = [self.businessListContainer objectForKey:[NSNumber numberWithInteger:menuIndex]];
        //NSLog(@"businessList=%@", self.businessList);
        if ([self.businessList count]) {
            return ([self.businessList count] + 1);
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.businessList count]) {
        return 50.0;
    } else {
        return OALTVC_CELL_HEIGHT;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.businessList count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"More Business" forIndexPath:indexPath];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        if (noMoreList == NO) {
            cell.textLabel.text = @"加载更多";
        } else {
            cell.textLabel.text = @"已加载到最后一条";
        }
        if ([cell.contentView viewWithTag:3000] == nil) {
            UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(0, FRAME_HEIGHT(cell)-0.5, FRAME_WIDTH(cell), 0.5)];
            uv.tag = 3000;
            uv.backgroundColor = SEPARATOR_COLOR;
            [cell.contentView addSubview:uv];
        }
        return cell;
    } else {
        VoteOptionsAddrListTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"Business List" forIndexPath:indexPath];
        [self configureCell:cell forRowAtIndexPath:indexPath];
        return cell;
    }
    
}

- (void)configureCell:(VoteOptionsAddrListTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasCoupon = [[[self.businessList objectAtIndex:indexPath.row] objectForKey:DIANPING_HAS_COUPON] boolValue];
    BOOL hasDeal = [[[self.businessList objectAtIndex:indexPath.row] objectForKey:DIANPING_HAS_DEAL] boolValue];
    NSLog(@"hasCoupon: %d, hasDeal: %d", hasCoupon, hasDeal);
    //商户图片
    NSString *photoURL = [[self.businessList objectAtIndex:indexPath.row] objectForKey:DIANPING_S_PHOTO_URL];
    NSURLRequest *photoRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:photoURL]];
    __weak UIImageView *tmpPhotoView = cell.photoView;
    [cell.photoView setImageWithURLRequest:photoRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        tmpPhotoView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    //商户名字
    NSString *business = [[self.businessList objectAtIndex:indexPath.row] objectForKey:DIANPING_NAME];
    NSString *branchName = [[self.businessList objectAtIndex:indexPath.row] objectForKey:DIANPING_BRANCH_NAME];
    if ([branchName isEqualToString:@""]) {
        cell.businessName.text = business;
    } else {
        cell.businessName.text = [business stringByAppendingFormat:@"(%@)", branchName];
    }
    //优惠券和团购
    if (hasCoupon && hasDeal) {
        [cell modifyBusinessNameWidth:OALTVC_BUSINESS_NAME_WIDTH2];
        cell.firstView.image = [UIImage imageNamed:@"tuan.png"];
        cell.secondView.image = [UIImage imageNamed:@"coupon.png"];
    } else if (hasCoupon || hasDeal) {
        [cell modifyBusinessNameWidth:OALTVC_BUSINESS_NAME_WIDTH1];
        if (hasCoupon) {
            cell.secondView.image = [UIImage imageNamed:@"coupon.png"];
        } else {
            cell.secondView.image = [UIImage imageNamed:@"tuan.png"];
        }
    } else {
        if (FRAME_WIDTH(cell.businessName) != OALTVC_BUSINESS_NAME_WIDTH) {
            [cell modifyBusinessNameWidth:OALTVC_BUSINESS_NAME_WIDTH];
        }
    }
    
    //商户评级
    NSString *ratingURL = [[self.businessList objectAtIndex:indexPath.row] objectForKey:DIANPING_RATING_IMAGE_URL];
    NSURLRequest *ratingRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:ratingURL]];
    __weak UIImageView *tmpRatingView = cell.ratingView;
    [cell.ratingView setImageWithURLRequest:ratingRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        tmpRatingView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    //人均价格
    cell.avgPrice.text = [NSString stringWithFormat:@"人均: ¥%@", [[[self.businessList objectAtIndex:indexPath.row] objectForKey:DIANPING_AVG_PRICE] stringValue]];
    //区域和分类，region and category
    NSArray *rgn = [[self.businessList objectAtIndex:indexPath.row] objectForKey:DIANPING_REGION_REP];
    NSArray *ctgry = [[self.businessList objectAtIndex:indexPath.row] objectForKey:DIANPING_CATEGORY_REP];
    NSString *rgnStr;
    NSString *ctgryStr;
    if ([rgn count] > 0) {
        rgnStr = [rgn firstObject];
    } else {
        rgnStr = @"暂无";
    }
    if ([ctgry count] > 0) {
        ctgryStr = [ctgry firstObject];
    } else {
        ctgryStr = @"暂无";
    }
    cell.rgnCtgry.text = [NSString stringWithFormat:@"%@  %@",rgnStr, ctgryStr];
    //距离
    //是否同城
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *userCity = [ud stringForKey:SERVER_CITY];
    if ([self.city isEqualToString:userCity]) {
        float distance = [[[self.businessList objectAtIndex:indexPath.row] objectForKey:DIANPING_DISTANCE] floatValue];
        if (distance < 1000) {
            cell.distance.text = [NSString stringWithFormat:@"%.0fm", distance];
        } else {
            cell.distance.text = [NSString stringWithFormat:@"%0.1fkm", distance/1000];
        }
        
    } else {
        cell.distance.text = @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.businessList count]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.text = @"正在加载...";
        [self performSelectorInBackground:@selector(loadMore) withObject:nil];
        [cell setHighlighted:NO];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [self performSegueWithIdentifier:@"Business Details" sender:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)loadMore
{
    //NSMutableArray *more;
    //加载你的数据
    [self getDataFromServerWithCategory:self.currentCategory inTableView:self.middleTableView withIndex:currentMenuIndex loadMore:YES refreshAll:NO];
}

//添加数据到列表:
- (void) appendTableWith
{
    self.businessList = [self.businessListContainer objectForKey:currentMenuIndex];
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    for (int ind = 0; ind < [self.currentBusinessList count]; ind++) {
        NSIndexPath *newPath =  [NSIndexPath indexPathForRow:[self.businessList indexOfObject:[self.currentBusinessList objectAtIndex:ind]] inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    [self.middleTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark - WYPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    popoverController.delegate = nil;
    popoverController = nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Change Sort Type"]) {
		VotePopoverTableViewController* popoverViewController = segue.destinationViewController;
        //是否同城
        NSArray *text;
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSString *userCity = [ud stringForKey:SERVER_CITY];
        if ([self.city isEqualToString:userCity]) {
            popoverViewController.preferredContentSize = CGSizeMake(92, 238);
            text = [NSArray arrayWithObjects:@"距离最近", @"星级最高", @"评论最多", @"人均最低", @"服务最好", @"环境最优", nil];
        } else {
            popoverViewController.preferredContentSize = CGSizeMake(92, 197);
            text = [NSArray arrayWithObjects:@"星级最高", @"评论最多", @"人均最低", @"服务最好", @"环境最优", nil];
        }
        popoverViewController.text = [[NSMutableArray alloc] initWithArray:text];
        popoverViewController.cellIdentifier = @"Sort Type";
        popoverViewController.getTVCTextDelegate = self;
        
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        popoverController = [popoverSegue popoverControllerWithSender:sender
                                             permittedArrowDirections:WYPopoverArrowDirectionAny
                                                             animated:YES];
        
        popoverController.popoverLayoutMargins = UIEdgeInsetsMake(4, 4, 4, 4);
        
        popoverController.delegate = self;
        
    } else if ([segue.identifier isEqualToString:@"Custom Address"]) {
        
        
	} else if ([segue.identifier isEqualToString:@"Business Details"]) {
        NSIndexPath *path = [self.middleTableView indexPathForSelectedRow];
        VoteBusinessDetailsTableViewController *businessDetailsTVC = segue.destinationViewController;
        businessDetailsTVC.businessID = [[self.businessList objectAtIndex:path.row] objectForKey:DIANPING_BUSINESS_ID];

    } else if ([segue.identifier isEqualToString:@"Keyword Search"]) {
        VoteKeywordOptionsListTableViewController *tvc = segue.destinationViewController;
        tvc.keyword = self.searchBar.text;
        tvc.currentLocation = self.currentLocation;
        tvc.city = self.city;
    }
    //设置返回键的标题
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    
}

#pragma mark - GetPopOverTableViewCellTextDelegate

- (void)getTableViewCellText:(NSString *)text withIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString:@"Sort Type"]) {
        [popoverController dismissPopoverAnimated:YES];
        self.sortKey = text;
        [self.sortBtn setTitle:self.sortKey forState:UIControlStateNormal];
        [self getDataFromServerWithCategory:self.currentCategory inTableView:self.middleTableView withIndex:currentMenuIndex loadMore:NO refreshAll:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Help Function

- (void)setBusinessList:(NSMutableArray *)businessList
{
    if (_businessList != businessList) {
        _businessList = [businessList mutableCopy];
    }
}

@end
