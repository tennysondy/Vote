//
//  VoteHotDetailsTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-9-22.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteHotDetailsTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "NSString+NSStringHelper.h"
#import "VoteOptionDetailsTableViewController.h"

@interface VoteHotDetailsTableViewController ()
{
    BOOL displayFlag;
}

@property (strong, nonatomic) NSString *aTitle;
@property (strong, nonatomic) NSString *aDescription;
@property (strong, nonatomic) NSArray *options;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;

@property (strong, nonatomic) UILabel *loadingPrompt;

@end

@implementation VoteHotDetailsTableViewController

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
    displayFlag = NO;
    //[self.rightBarButtonItem setBackgroundImage:[UIImage imageNamed:@"good44.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.tableView.separatorColor = SEPARATOR_COLOR;
    [self fetchDataFromServer];
}

- (void)fetchDataFromServer
{
    [self startLoadingView];
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_vote_detail.php"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [[NSString alloc] initWithString:[ud objectForKey:USERNAME]];
    NSDictionary *parameters = @{SERVER_USERNAME: username, SERVER_VOTE_ID: self.voteId};
    NSLog(@"parameters: %@", parameters);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        [self endLoadingView:YES];
        //self.imgUrl = [responseObject objectForKey:SERVER_VOTE_IMAGE_URL];
        self.aTitle = [responseObject objectForKey:SERVER_VOTE_TITLE];
        self.aDescription = [responseObject objectForKey:SERVER_VOTE_DESCRIPTION];
        self.options = [NSArray arrayWithArray:(NSArray *)[responseObject objectForKey:SERVER_VOTE_OPTIONS]];
        NSLog(@"%@", self.options);
        displayFlag = YES;
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in second table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        [self endLoadingView:NO];

    }];
    
}

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

#pragma mark - Click good

- (IBAction)good:(id)sender {
    //显示loading动画
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [[NSString alloc] initWithString:[ud stringForKey:USERNAME]];
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/add_support.php"];
    NSDictionary *para = @{SERVER_USERNAME:username, SERVER_VOTE_ID:self.voteId};
    NSLog(@"URL para = %@", para);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        if (sender != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem = sender;
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        if (sender != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem = sender;
            });
        }
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (displayFlag == NO) {
        return 0;
    }
    if (section  == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else {
        return [self.options count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15.0;
    }
    return 5.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        //主题
        UIFont *font = [UIFont boldSystemFontOfSize:17.0];
        CGFloat width = 240.0;
        CGFloat height = [NSString calculateTextHeight:self.aTitle font:font width:width];
        if (height < 50.0) {
            height = 50.0;
        }
        return height + 20;
        
    } else if (indexPath.section == 1) {
        //描述
        UIFont *font = [UIFont systemFontOfSize:15.0];
        CGFloat width = 290.0;
        CGFloat height = [NSString calculateTextHeight:self.aDescription font:font width:width];
        if (height < 20.0) {
            height = 20.0;
        }
        return height + 20;
        
    } else {
        UIFont *font = [UIFont fontWithName:HDTVC_OPTIONS_TITLE_FONT size:HDTVC_OPTIONS_TITLE_FONT_SIZE];
        NSString *text1 = [NSString stringWithFormat:@"A. %@", [[self.options objectAtIndex:indexPath.row] objectForKey:SERVER_OPTIONS_NAME]];
        CGFloat width = 300;
        CGFloat height1 = [NSString calculateTextHeight:text1 font:font width:width];
        if ([[[self.options objectAtIndex:indexPath.row] objectForKey:SERVER_OPTIONS_BUSINESS_ID] integerValue] == BUSINESS_ID_OF_NO_ADDR) {
            
            return 10.0 + height1 + 10.0;
            
        } else {
            NSString *text2 = [[self.options objectAtIndex:indexPath.row] objectForKey:SERVER_OPTIONS_ADDRESS];
            CGFloat height2 = [NSString calculateTextHeight:text2 font:font width:width];
            
            return 10.0 + height1 + 10.0 + height2 + 10.0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Title" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, FRAME_HEIGHT(cell)/2 - 25, 50.0, 50.0)];
        imageView.image = [UIImage imageNamed:self.imgUrl];
        imageView.layer.cornerRadius = 6.0f;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
        UILabel *subject = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 10.0, 240.0, cell.frame.size.height - 20.0)];
        subject.numberOfLines = 0;
        subject.lineBreakMode = NSLineBreakByWordWrapping;
        subject.text = self.aTitle;
        subject.font = [UIFont boldSystemFontOfSize:17.0];
        [cell.contentView addSubview:subject];
        
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Description" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *decription = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, cell.frame.size.height - 20.0)];
        decription.numberOfLines = 0;
        decription.lineBreakMode = NSLineBreakByWordWrapping;
        decription.text = self.aDescription;
        decription.font = [UIFont systemFontOfSize:15.0];
        [cell.contentView addSubview:decription];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Options" forIndexPath:indexPath];
        while ([cell.contentView.subviews lastObject] != nil) {
            [[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        UIFont *font = [UIFont fontWithName:HDTVC_OPTIONS_TITLE_FONT size:HDTVC_OPTIONS_TITLE_FONT_SIZE];
        NSString *name = [[self.options objectAtIndex:indexPath.row] objectForKey:SERVER_OPTIONS_NAME];
        NSNumber *businessId = [[self.options objectAtIndex:indexPath.row] objectForKey:SERVER_OPTIONS_BUSINESS_ID];
        NSString *order = [[self.options objectAtIndex:indexPath.row] objectForKey:SERVER_OPTIONS_ORDER];
        NSString *address = [[self.options objectAtIndex:indexPath.row] objectForKey:SERVER_OPTIONS_ADDRESS];
        NSString *text1 = [NSString stringWithFormat:@"A. %@", name];
        CGFloat width = 300;
        CGFloat height1 = [NSString calculateTextHeight:text1 font:font width:width];
        //投票选项标题
        UILabel *titleLabel;
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(HDTVC_OPTIONS_TITLE_X, HDTVC_OPTIONS_TITLE_Y, width, height1)];
        titleLabel.font = font;
        titleLabel.text = [[NSString alloc] initWithFormat:@"%@. %@", order, name];
        [cell.contentView addSubview:titleLabel];
        //投票选项地址
        UILabel *addrLabel;
        if ([businessId integerValue] == BUSINESS_ID_OF_NO_ADDR) {
           
            
        } else {
            NSString *text2 = address;
            CGFloat height2 = [NSString calculateTextHeight:text2 font:font width:width];
            addrLabel = [[UILabel alloc] initWithFrame:CGRectMake(HDTVC_OPTIONS_ADDR_X, HDTVC_OPTIONS_TITLE_Y+height1+5.0, width, height2)];
            addrLabel.font = font;
            addrLabel.text = address;
            addrLabel.lineBreakMode = NSLineBreakByWordWrapping;
            addrLabel.numberOfLines = 0;
            //addrLabel.layer.borderWidth = 1.0;
            //addrLabel.layer.borderColor = [UIColor blackColor].CGColor;
            [cell.contentView addSubview:addrLabel];
        }
        
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *businessID = [[self.options objectAtIndex:indexPath.row] objectForKey:SERVER_OPTIONS_BUSINESS_ID];
    if ([businessID integerValue] == BUSINESS_ID_OF_NO_ADDR) {
        //
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该选项仅有标题信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
    } else {
        [self performSegueWithIdentifier:@"Hot Options Details" sender:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    VoteOptionDetailsTableViewController *vc = [segue destinationViewController];
    vc.name = [[self.options objectAtIndex:indexPath.row] objectForKey:SERVER_OPTIONS_NAME];
    vc.businessID = [[self.options objectAtIndex:indexPath.row] objectForKey:SERVER_OPTIONS_BUSINESS_ID];
    vc.address = [[self.options objectAtIndex:indexPath.row] objectForKey:SERVER_OPTIONS_ADDRESS];
    //设置返回键的标题
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}


@end
