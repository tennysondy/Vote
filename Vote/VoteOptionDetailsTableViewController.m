//
//  VoteOptionDetailsTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-8-12.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteOptionDetailsTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "DianPingAPI.h"
#import "VoteBusinessDetailsHelper.h"
#import "NSString+NSStringHelper.h"
#import "VoteDealsDetailsViewController.h"

@interface VoteOptionDetailsTableViewController ()
{
    BOOL customFlag;
    
    int hasCoupon;
    int hasDeal;
    BOOL businessOK;
    BOOL commentsOK;
    BOOL dropDown;
    
    NSUInteger rowNumOfSection2;//从0开始计算
}

@property (strong, nonatomic) NSDictionary *businessInfo;
@property (strong, nonatomic) NSMutableArray *commentsInfo;

@property (strong, nonatomic) UILabel *loadingPrompt;

@end

@implementation VoteOptionDetailsTableViewController

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
    if ([self.businessID integerValue] == BUSINESS_ID_OF_CUSTOM_ADDR) {
        customFlag = YES;
    }
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    if (customFlag == NO) {
        [self getBusinessDataFromServer];
        [self getCommentsDataFromServer];
    }
    dropDown = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network functions

- (void)startLoadingView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (self.loadingPrompt == nil) {
        self.loadingPrompt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 20)];
        self.loadingPrompt.center = CGPointMake(self.view.center.x, self.view.center.y - 84);
        self.loadingPrompt.textColor = [UIColor lightGrayColor];
        self.loadingPrompt.textAlignment = NSTextAlignmentCenter;
        self.loadingPrompt.font = [UIFont boldSystemFontOfSize:15.0];
        [self.view addSubview:self.loadingPrompt];
    }
    self.loadingPrompt.text = @"正在加载...";
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    activityIndicator.tag = 250;
    activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y - 44);
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

- (void)endLoadingView:(BOOL)success
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (success) {
        [self.loadingPrompt removeFromSuperview];
    } else {
        self.loadingPrompt.text = @"加载失败";
    }
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:250];
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
}

- (void)getBusinessDataFromServer
{
    [self startLoadingView];
    NSString *userInfoURL = [[NSString alloc] initWithFormat:@"http://api.dianping.com/v1/business/get_single_business"];
    NSNumber *platform = @2;
    NSDictionary *optionPara = @{DIANPING_BUSINESS_ID:self.businessID, DIANPING_PLATFORM:platform};
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:4];
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
        [self endLoadingView:YES];
        if ([[responseObject objectForKey:DIANPING_STATUS] isEqualToString:@"OK"]) {
            self.businessInfo = [[responseObject objectForKey:DIANPING_BUSINESS] firstObject];
            hasCoupon = [[self.businessInfo objectForKey:DIANPING_HAS_COUPON] intValue];
            hasDeal = [[self.businessInfo objectForKey:DIANPING_HAS_DEAL] intValue];
            businessOK = YES;
            if (businessOK && commentsOK) {
                [self.tableView reloadData];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        [self endLoadingView:NO];
        
    }];
}

- (void)getCommentsDataFromServer
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *commentsURL = [[NSString alloc] initWithFormat:@"http://api.dianping.com/v1/review/get_recent_reviews"];
    NSNumber *platform = @2;
    NSNumber *limit = @1;
    NSDictionary *optionPara = @{DIANPING_BUSINESS_ID:self.businessID, DIANPING_PLATFORM:platform, DIANPING_LIMIT:limit};
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:4];
    [parameters setValuesForKeysWithDictionary:optionPara];
    NSString *sign = [DianPingAPI signGeneratedInSHA1With:optionPara];
    [parameters setObject:APPKEY forKey:DIANPING_APPKEY];
    [parameters setObject:sign forKey:DIANPING_SIGN];
    NSLog(@"Get parameters: %@", parameters);
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:commentsURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ([[responseObject objectForKey:DIANPING_STATUS] isEqualToString:@"OK"]) {
            self.commentsInfo = [[NSMutableArray alloc] initWithArray:[(NSDictionary *)responseObject objectForKey:DIANPING_REVIEWS]];
            commentsOK = YES;
            if (businessOK && commentsOK) {
                [self.tableView reloadData];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (customFlag == YES) {
        return 2;
    } else if (businessOK && commentsOK) {
        NSInteger count = 1;
        if (hasCoupon || hasDeal) {
            count++;
        }
        if ([self.commentsInfo count] > 0) {
            count++;
        }
        return 1+count;//1为主题
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (customFlag == YES) {
        return 1;
    } else {
        if (businessOK && commentsOK) {
            if (section == 0) {
                return 1;
            }
            if (section == 1) {
                return 3;
            } else if (section == 2) {
                if (hasCoupon || hasDeal) {
                    NSInteger count = 0;
                    if (hasCoupon) {
                        count++;
                    }
                    if (hasDeal) {
                        //判断用户是否点击收起或查看全部
                        NSNumber *dealsNum = [self.businessInfo objectForKey:DIANPING_DEAL_COUNT];
                        if (dropDown == NO) {
                            //收起
                            count++;
                        } else {
                            //查看全部
                            count = count + [dealsNum integerValue];
                        }
                        //增加收起查看全部栏
                        count++;
                    }
                    rowNumOfSection2 = count;
                    return count;
                } else {
                    return [self.commentsInfo count];
                }

            } else if (section == 3) {
                return [self.commentsInfo count];
            }
        }
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15.0;
    } else {
        return 5.0;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UIFont *font = [UIFont boldSystemFontOfSize:ODTVC_NAME_FONT_SIZE];
        CGFloat height = [NSString calculateTextHeight:self.name font:font width:ODTVC_NAME_WIDTH];
        return height + 20;
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        if (customFlag == YES) {
            UIFont *font = [UIFont systemFontOfSize:ODTVC_CUSTOM_ADDR_FONT_SIZE];
            CGFloat height = [NSString calculateTextHeight:self.address font:font width:ODTVC_CUSTOM_ADDR_WIDTH];

            return height + 20;
        } else {
            NSString *text = [[NSString alloc] initWithFormat:@"%@(%@)", [self.businessInfo objectForKey:DIANPING_NAME], [self.businessInfo objectForKey:DIANPING_BRANCH_NAME]];
            UIFont *font = [UIFont fontWithName:BDH_NAME_FONT size:BDH_NAME_FONT_SIZE];
            CGFloat height1 = [NSString calculateTextHeight:text font:font width:BDH_NAME_WIDTH];
            if (height1 < 20.0) {
                height1 = 20.0;
            }
            CGFloat height = BDH_NAME_COORDINATE_Y + height1 + 10.0 + BDH_S_PHOTO_HEIGHT + 10.0;
            return height;
        }
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        NSString *text = [self.businessInfo objectForKey:DIANPING_ADDRESS];
        UIFont *font = [UIFont fontWithName:BDH_ADDRESS_FONT size:BDH_ADDRESS_FONT_SIZE];
        CGFloat height = [NSString calculateTextHeight:text font:font width:BDH_ADDRESS_WIDTH];
        if (height < 30.0) {
            height = 30.0;
        }
        return height + 20;
        
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        NSString *text = [self.businessInfo objectForKey:DIANPING_TELEPHONE];
        UIFont *font = [UIFont fontWithName:BDH_TELEPHONE_FONT size:BDH_TELEPHONE_FONT_SIZE];
        CGFloat height = [NSString calculateTextHeight:text font:font width:BDH_TELEPHONE_WIDTH];
        
        return height + 20.0;
        
    } else if (indexPath.section == 2) {
        if (hasCoupon || hasDeal) {
            if (hasCoupon) {
                if (indexPath.row == rowNumOfSection2 - 1) {
                    //优惠券
                    NSString *text = [self.businessInfo objectForKey:DIANPING_COUPON_DESCR];
                    UIFont *font = [UIFont fontWithName:BDH_COUPON_FONT size:BDH_COUPON_FONT_SIZE];
                    CGFloat height = [NSString calculateTextHeight:text font:font width:BDH_COUPON_WIDTH];
                    if (height < 20.0) {
                        height = 20.0;
                    }
                    return height + 20.0;

                } else if (indexPath.row == rowNumOfSection2 - 2) {
                    return 44.0;
                } else {
                    NSString *text = [[[self.businessInfo objectForKey:DIANPING_DEALS] objectAtIndex:indexPath.row] objectForKey:DIANPING_DEALS_DESCR];
                    UIFont *font = [UIFont fontWithName:BDH_DEALS_FONT size:BDH_DEALS_FONT_SIZE];
                    CGFloat height = [NSString calculateTextHeight:text font:font width:BDH_DEALS_WIDTH];
                    if (height < 20.0) {
                        height = 20.0;
                    }
                    return height + 20.0;
                }
            } else {
                if (indexPath.row == rowNumOfSection2 - 1) {
                    return 44.0;
                } else {
                    NSString *text = [[[self.businessInfo objectForKey:DIANPING_DEALS] objectAtIndex:indexPath.row] objectForKey:DIANPING_DEALS_DESCR];
                    UIFont *font = [UIFont fontWithName:BDH_DEALS_FONT size:BDH_DEALS_FONT_SIZE];
                    CGFloat height = [NSString calculateTextHeight:text font:font width:BDH_DEALS_WIDTH];
                    if (height < 20.0) {
                        height = 20.0;
                    }
                    return height + 20.0;
                }
            }

        } else {
            NSString *text = [[self.commentsInfo objectAtIndex:indexPath.row] objectForKey:DIANPING_TEXT_EXCERPT];
            UIFont *font = [UIFont fontWithName:BDH_COMMENTS_TEXT_FONT size:BDH_COMMENTS_TEXT_FONT_SIZE];
            CGFloat height = [NSString calculateTextHeight:text font:font width:BDH_COMMENTS_TEXT_WIDTH];
            return BDH_COMMENTS_TEXT_COORDINATE_Y + height + 10;
        }
    } else if (indexPath.section == 3) {
        NSString *text = [[self.commentsInfo objectAtIndex:indexPath.row] objectForKey:DIANPING_TEXT_EXCERPT];
        UIFont *font = [UIFont fontWithName:BDH_COMMENTS_TEXT_FONT size:BDH_COMMENTS_TEXT_FONT_SIZE];
        CGFloat height = [NSString calculateTextHeight:text font:font width:BDH_COMMENTS_TEXT_WIDTH];
        return BDH_COMMENTS_TEXT_COORDINATE_Y + height + 10;
        
    } else {
        return 44.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Option Name" forIndexPath:indexPath];
        UILabel *nameLabel;
        if ([cell.contentView viewWithTag:ODTVC_NAME_TAG] == nil) {
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(ODTVC_NAME_COORDINATE_X, ODTVC_NAME_COORDINATE_Y, ODTVC_NAME_WIDTH, cell.frame.size.height - 20)];
            nameLabel.tag = ODTVC_NAME_TAG;
            nameLabel.font = [UIFont boldSystemFontOfSize:ODTVC_NAME_FONT_SIZE];
            [cell.contentView addSubview:nameLabel];
        } else {
            nameLabel = (UILabel *)[cell.contentView viewWithTag:ODTVC_NAME_TAG];
        }
        nameLabel.text = self.name;

    } else if (indexPath.section == 1 && indexPath.row == 0) {
        if (customFlag == YES) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Option Custom Address" forIndexPath:indexPath];
            UILabel *addressLabel;
            if ([cell.contentView viewWithTag:ODTVC_CUSTOM_ADDR_TAG] == nil) {
                addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(ODTVC_CUSTOM_ADDR_COORDINATE_X, ODTVC_CUSTOM_ADDR_COORDINATE_Y, ODTVC_CUSTOM_ADDR_WIDTH, cell.frame.size.height - 20)];
                addressLabel.tag = ODTVC_CUSTOM_ADDR_TAG;
                addressLabel.font = [UIFont systemFontOfSize:ODTVC_CUSTOM_ADDR_FONT_SIZE];
                [cell.contentView addSubview:addressLabel];
            } else {
                addressLabel = (UILabel *)[cell.contentView viewWithTag:ODTVC_CUSTOM_ADDR_TAG];
            }
            addressLabel.text = self.address;

        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Business Basic Info" forIndexPath:indexPath];
            [VoteBusinessDetailsHelper configureBasicCell:cell forRowAtIndexPath:indexPath withBusinessInfo:self.businessInfo];
            //添加cell间的分割线
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
            v.backgroundColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:v];
        }
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Business Address" forIndexPath:indexPath];
        [VoteBusinessDetailsHelper configureAddressCell:cell forRowAtIndexPath:indexPath withBusinessInfo:self.businessInfo];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
        v.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:v];
        
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Business Telephone" forIndexPath:indexPath];
        [VoteBusinessDetailsHelper configureTelephoneCell:cell forRowAtIndexPath:indexPath withBusinessInfo:self.businessInfo];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
        v.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:v];
        
    } else if (indexPath.section == 2) {
        if (hasCoupon || hasDeal) {
            //优惠券和团购信息
            if (hasCoupon) {
                if (indexPath.row == rowNumOfSection2 - 1) {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Business Coupon" forIndexPath:indexPath];
                    [VoteBusinessDetailsHelper configureCouponCell:cell forRowAtIndexPath:indexPath withBusinessInfo:self.businessInfo];
                } else if (indexPath.row == rowNumOfSection2 - 2) {
                    //Business Check All Deals
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Business Check All Deals" forIndexPath:indexPath];
                    UILabel *label;
                    if ([cell.contentView viewWithTag:ODTVC_CHECK_ALL_DEALS_TAG] == nil) {
                        label = [[UILabel alloc] initWithFrame:CGRectMake(FRAME_WIDTH(cell)/2-50, FRAME_HEIGHT(cell)/2-10, 100, 20.0)];
                        label.tag = ODTVC_CHECK_ALL_DEALS_TAG;
                        label.textColor = [UIColor orangeColor];
                        label.font = [UIFont systemFontOfSize:15.0];
                        label.textAlignment = NSTextAlignmentCenter;
                        [cell.contentView addSubview:label];
                    }
                    label = (UILabel *)[cell.contentView viewWithTag:ODTVC_CHECK_ALL_DEALS_TAG];
                    if (dropDown == YES) {
                        label.text = @"收起";
                    } else {
                        label.text = @"查看全部团购";
                    }
                } else {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Business Deal" forIndexPath:indexPath];
                    [VoteBusinessDetailsHelper configureDealsCell:cell forRowAtIndexPath:indexPath withBusinessInfo:self.businessInfo];
                }
            } else {
                if (indexPath.row == rowNumOfSection2 - 1) {
                    //Business Check All Deals
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Business Check All Deals" forIndexPath:indexPath];
                    UILabel *label;
                    if ([cell.contentView viewWithTag:ODTVC_CHECK_ALL_DEALS_TAG] == nil) {
                        label = [[UILabel alloc] initWithFrame:CGRectMake(FRAME_WIDTH(cell)/2-50, FRAME_HEIGHT(cell)/2-10, 100, 20.0)];
                        label.tag = ODTVC_CHECK_ALL_DEALS_TAG;
                        label.text = @"查看全部团购";
                        label.textColor = [UIColor orangeColor];
                        label.font = [UIFont boldSystemFontOfSize:15.0];
                        label.textAlignment = NSTextAlignmentCenter;
                        [cell.contentView addSubview:label];
                    }
                    label = (UILabel *)[cell.contentView viewWithTag:ODTVC_CHECK_ALL_DEALS_TAG];
                    if (dropDown == YES) {
                        label.text = @"收起";
                    } else {
                        label.text = @"查看全部团购";
                    }
                } else {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Business Deal" forIndexPath:indexPath];
                    [VoteBusinessDetailsHelper configureDealsCell:cell forRowAtIndexPath:indexPath withBusinessInfo:self.businessInfo];
                }
                
            }
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
            v.backgroundColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:v];
            
        } else {
            //如果没有优惠券和团购信息，则在section 2中显示评论
            cell = [tableView dequeueReusableCellWithIdentifier:@"Business Comments" forIndexPath:indexPath];
            [VoteBusinessDetailsHelper configureCommentsCell:cell forRowAtIndexPath:indexPath witCommentsInfo:self.commentsInfo];
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
            v.backgroundColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:v];
        }
    } else if (indexPath.section == 3) {
        //如果有优惠券和团购信息，评论放在section 3中
        cell = [tableView dequeueReusableCellWithIdentifier:@"Business Comments" forIndexPath:indexPath];
        [VoteBusinessDetailsHelper configureCommentsCell:cell forRowAtIndexPath:indexPath witCommentsInfo:self.commentsInfo];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
        v.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:v];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        if (hasCoupon || hasDeal) {
            if (hasCoupon) {
                if (indexPath.row == rowNumOfSection2 - 1) {
                    //优惠券与团购共用Deals Web
                    [self performSegueWithIdentifier:@"Deals Web" sender:indexPath];
                    
                } else if (indexPath.row == rowNumOfSection2 - 2) {
                    if (dropDown == YES) {
                        dropDown = NO;
                    } else {
                        dropDown = YES;
                    }
                    NSIndexSet *sections = [[NSIndexSet alloc] initWithIndex:indexPath.section];
                    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
                } else {
                    //团购
                    [self performSegueWithIdentifier:@"Deals Web" sender:indexPath];
                }
            } else {
                if (indexPath.row == rowNumOfSection2 - 1) {
                    if (dropDown == YES) {
                        dropDown = NO;
                    } else {
                        dropDown = YES;
                    }
                    NSIndexSet *sections = [[NSIndexSet alloc] initWithIndex:indexPath.section];
                    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
                } else {
                    //团购
                    [self performSegueWithIdentifier:@"Deals Web" sender:indexPath];
                }
            }
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:@"Deals Web"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        VoteDealsDetailsViewController *vc = [segue destinationViewController];
        if (hasCoupon && indexPath.row == rowNumOfSection2 - 1) {
            vc.url = [self.businessInfo objectForKey:DIANPING_COUPON_URL];
        } else {
            vc.url = [[[self.businessInfo objectForKey:DIANPING_DEALS] objectAtIndex:indexPath.row] objectForKey:DIANPING_DEALS_URL];
        }

    }
    //设置返回键的标题
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}


@end
