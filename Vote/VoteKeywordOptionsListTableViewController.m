//
//  VoteKeywordOptionsListTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-8-18.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteKeywordOptionsListTableViewController.h"
#import "VoteAddOptionsTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+AFNetworking.h"
#import "WGS84ToGCJ02.h"
#import "VoteOptionsAddrListTableViewCell.h"
#import "DianPingAPI.h"
#import "VoteBusinessDetailsTableViewController.h"

@interface VoteKeywordOptionsListTableViewController ()
{
    NSInteger currentPage;
    BOOL noMoreList;
}
@property (strong, nonatomic) NSMutableArray *businessList;
@property (strong, nonatomic) NSMutableArray *currentBusinessList;

@property (strong, nonatomic) NSDictionary *sortType;

@end

@implementation VoteKeywordOptionsListTableViewController

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
        self.businessList = [[NSMutableArray alloc] init];
        self.currentBusinessList = [[NSMutableArray alloc] init];
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.sortType = [[NSDictionary alloc] initWithObjectsAndKeys:@7, @"距离最近", @2, @"星级最高", @6, @"评论最多", @8, @"人均最低", @5, @"服务最好", @4, @"环境最优", nil];
    [self getDataFromServerOfLoadMore:NO andRefreshAll:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Network functions

- (void)startLoadingView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIView *loadingView;
    UILabel *label;
    UIActivityIndicatorView *activityIndicator;
    if ([self.view viewWithTag:KOLTVC_LOADING_VIEW_TAG] == nil) {
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        loadingView.center = CGPointMake(self.view.center.x, self.view.center.y - 64);
        loadingView.backgroundColor = [UIColor blackColor];
        loadingView.alpha = 0.6;
        loadingView.tag = KOLTVC_LOADING_VIEW_TAG;
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
        activityIndicator.tag = KOLTVC_ACTIVITY_INDICATOR_TAG;
        
        [activityIndicator startAnimating];
    }
}

- (void)endLoadingView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIView *loadingView = (UIView *)[self.view viewWithTag:KOLTVC_LOADING_VIEW_TAG];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[loadingView viewWithTag:KOLTVC_ACTIVITY_INDICATOR_TAG];
    [activityIndicator stopAnimating];
    [loadingView removeFromSuperview];
}

- (void)getDataFromServerOfLoadMore:(BOOL)loadMore andRefreshAll:(BOOL)refreshAll
{
    [self startLoadingView];
    
    if (refreshAll == YES) {
        noMoreList = NO;
        currentPage = 1;
    }
    //NSLog(@"original location: %f, %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    //CLLocationCoordinate2D coordinate = [WGS84ToGCJ02 transformFromWGSToGCJ:self.currentLocation.coordinate];
    NSString *userInfoURL = [[NSString alloc] initWithFormat:@"http://api.dianping.com/v1/business/find_businesses"];
    //NSNumber *radius = @5000;
    NSNumber *platform = @2;
    //NSNumber *sort = [self.sortType objectForKey:@"距离最近"];
    if (loadMore == YES) {
        currentPage++;
    }
    NSNumber *page = [[NSNumber alloc] initWithInteger:currentPage];
    NSNumber *limit = @20;
    //NSNumber *offsetType = @1;
    //参数列表
    NSDictionary *optionPara;
    optionPara = @{DIANPING_CITY:self.city, DIANPING_KEYWORD:self.keyword, DIANPING_SORT:@1, DIANPING_PAGE:page, DIANPING_LIMIT:limit, DIANPING_PLATFORM:platform};
    /*
    if ([self.city isEqualToString:userCity]) {
        optionPara = @{DIANPING_LATITUDE:[NSNumber numberWithFloat:(float)coordinate.latitude], DIANPING_LONGITUDE:[NSNumber numberWithFloat:(float)coordinate.longitude], DIANPING_OFFSET_TYPE:offsetType, DIANPING_RADIUS:radius, DIANPING_KEYWORD:self.keyword, DIANPING_CITY:self.city, DIANPING_SORT:sort, DIANPING_PAGE:page, DIANPING_LIMIT:limit, DIANPING_PLATFORM:platform};
    } else {
        optionPara = @{DIANPING_CITY:self.city, DIANPING_KEYWORD:self.keyword, DIANPING_SORT:@1, DIANPING_PAGE:page, DIANPING_LIMIT:limit, DIANPING_PLATFORM:platform};
    }
     */

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
                self.businessList = [NSMutableArray arrayWithArray:self.currentBusinessList];
            } else {
                [self.businessList addObjectsFromArray:self.currentBusinessList];
            }
            //NSLog(@"dd%@", self.businessList);
            if (loadMore == NO) {
                [self.tableView reloadData];
            } else {
                if ([self.currentBusinessList count] > 0) {
                    [self performSelectorOnMainThread:@selector(appendTableWith) withObject:nil waitUntilDone:NO];
                } else {
                    noMoreList = YES;
                    [self.tableView reloadData];
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

- (void)loadMore
{
    //NSMutableArray *more;
    //加载你的数据
    [self getDataFromServerOfLoadMore:YES andRefreshAll:NO];
}

//添加数据到列表:
- (void) appendTableWith
{
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    for (int ind = 0; ind < [self.currentBusinessList count]; ind++) {
        NSIndexPath *newPath =  [NSIndexPath indexPathForRow:[self.businessList indexOfObject:[self.currentBusinessList objectAtIndex:ind]] inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    
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
    return [self.businessList count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.businessList count]) {
        return 50.0;
    }
    return OALTVC_CELL_HEIGHT;
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
            uv.alpha = 0.3;
            uv.tag = 3000;
            uv.backgroundColor = [UIColor lightGrayColor];
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
    cell.businessName.text = [business stringByAppendingFormat:@"(%@)", branchName];
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
    cell.rgnCtgry.text = [NSString stringWithFormat:@"%@  %@",[rgn firstObject], [ctgry firstObject]];
    //距离
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *userCity = [ud stringForKey:SERVER_CITY];
    if ([self.city isEqualToString:userCity]) {
        CLLocationDegrees latitude = [[[self.businessList objectAtIndex:indexPath.row] objectForKey:DIANPING_LATITUDE] doubleValue];
        CLLocationDegrees longitude = [[[self.businessList objectAtIndex:indexPath.row] objectForKey:DIANPING_LONGITUDE] doubleValue];
        CLLocation *tarPos = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        CLLocationDistance distance = [self.currentLocation distanceFromLocation:tarPos];
        if (distance < 1000) {
            cell.distance.text = [NSString stringWithFormat:@"%.0fm", distance];
        } else {
            cell.distance.text = [NSString stringWithFormat:@"%.1fkm", distance/1000];
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
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Business Details"]) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        VoteBusinessDetailsTableViewController *businessDetailsTVC = segue.destinationViewController;
        businessDetailsTVC.businessID = [[self.businessList objectAtIndex:path.row] objectForKey:DIANPING_BUSINESS_ID];
    }
    //设置返回键的标题
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}


@end
