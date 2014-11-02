//
//  VoteFriendsReqListTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-4-13.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteFriendsReqListTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+UIImageHelper.h"
#import "CoreDataHelper.h"
#import "Friends+FriendsHelper.h"
#import "VoteFriendsDetailsInfoTableViewController.h"
#import "LoadingIconImageView.h"

@interface VoteFriendsReqListTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UILabel *loadingPrompt;

@property (strong, nonatomic) NSMutableSet *strangerSet;

@end

@implementation VoteFriendsReqListTableViewController

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
        //self.friendReqInfo = [[NSMutableArray alloc] init];
        self.strangerSet = [[NSMutableSet alloc] init];
    }
    
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [CoreDataHelper sharedDatabase:^(UIManagedDocument *database) {
        //create nsfetchresultcontroller...
        self.document = database;
        self.managedObjectContext = database.managedObjectContext;

    }];
    [self getFriendReqList];
}

- (void)getFriendReqList
{
    //设置提示信息
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.loadingPrompt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 20)];
    self.loadingPrompt.center = CGPointMake(self.view.center.x, self.view.center.y - 84);
    self.loadingPrompt.text = @"正在加载...";
    self.loadingPrompt.textColor = [UIColor lightGrayColor];
    self.loadingPrompt.textAlignment = NSTextAlignmentCenter;
    self.loadingPrompt.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:self.loadingPrompt];
    LoadingIconImageView *activityIndicator = [[LoadingIconImageView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y - 44);
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    //下载数据
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [[NSString alloc] initWithString:[ud stringForKey:USERNAME]];
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_stranger.php"];
    NSDictionary *para = @{SERVER_USERNAME:username};
    NSLog(@"URL para = %@", para);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        [self.loadingPrompt removeFromSuperview];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        if ((NSNull *)[responseObject objectForKey:SERVER_STRANGERS_ARRAY] == [NSNull null]) {
            return;
        }
        NSArray *tmp = [(NSDictionary *)responseObject objectForKey:SERVER_STRANGERS_ARRAY];
        self.friendReqInfo = [NSMutableArray arrayWithArray:tmp];
        NSLog(@"self.friendReqInfo = %@", self.friendReqInfo);
        //创建陌生人集合
        [self createStrangerSet];
        
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [activityIndicator stopAnimating];
        self.loadingPrompt.text = @"加载失败";
    }];

}

- (void)createStrangerSet
{
    if ([self.friendReqInfo count] > 0) {
        for (NSUInteger i = 0; i < [self.friendReqInfo count]; i++) {
            NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
            NSString *username = [ud stringForKey:USERNAME];
            NSString *friendName = [[self.friendReqInfo objectAtIndex:i] objectForKey:SERVER_USERNAME];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(whoseFriends.username == %@) AND (username == %@)", username, friendName];
            NSArray *friends = [CoreDataHelper searchObjectsForEntity:FRIENDS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:self.managedObjectContext];
            if ([friends count] == 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.strangerSet addObject:indexPath];
            }
        }
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friendReqInfo count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Friends Request List" forIndexPath:indexPath];

    // Configure the cell...
    cell.textLabel.text = [[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_SCREENNAME];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
    if ( ([[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_STRANGER_MSG] != nil) && ((NSNull *)[[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_STRANGER_MSG] != [NSNull null]) ) {
        cell.detailTextLabel.text = [[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_STRANGER_MSG];
    } else {
        cell.detailTextLabel.text = @"无";
    }
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    // 删除cell中的子对象,刷新覆盖问题。
    while ([cell.contentView.subviews lastObject])
    {
        [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    //添加cell间的分割线
    CGFloat sepratorHeight = cell.frame.size.height - 0.5;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(70.0, sepratorHeight, 250.0, 0.5)];
    v.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:v];
    //判断是否为friend
    if ([self.strangerSet containsObject:indexPath] == YES) {
        UIButton *agreeBtn;
        agreeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        agreeBtn.frame = CGRectMake(230.0, 15.0, 50.0, 30.0);
        [agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        //UIColorFromRGB(0x1AB5FF);0x3C78D8
        [agreeBtn setBackgroundColor:UIColorFromRGB(0x1AB5FF)];
        [agreeBtn setTintColor:[UIColor whiteColor]];
        agreeBtn.layer.cornerRadius = 6.0f;
        [agreeBtn addTarget:self action:@selector(agreeAddFriend:) forControlEvents:UIControlEventTouchUpInside];
        agreeBtn.tag = indexPath.row;
        [cell.contentView addSubview:agreeBtn];
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(240.0, 15.0, 50.0, 30.0)];
        label.text = @"已添加";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:13.0];
        label.textColor = [UIColor lightGrayColor];
        //label.layer.borderWidth = 1.0;
        //label.layer.borderColor = [[UIColor blackColor] CGColor];
        [cell.contentView addSubview:label];
    }
    [self downloadHeadImageInCell:cell withIndexPath:indexPath];
    
    return cell;
}

- (void)downloadHeadImageInCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *screennamePinyin = [[NSString alloc] init];
    screennamePinyin = [[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_SCREENNAME_PINYIN];
    //check directory like .../tmp/user/Strangers/username...
    /*
    __block BOOL success = YES;
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSString *path = NSTemporaryDirectory();
    NSString *userPath = [path stringByAppendingPathComponent:username];
    NSString *mainPath;
    mainPath = [userPath stringByAppendingPathComponent:STRANGERS];
    NSString *fullPath = [mainPath stringByAppendingPathComponent:screennamePinyin];
    NSString *filename = [NSString stringWithFormat:@"%@.%@", MEDIUM_HEAD_IMAGE_NAME, IMAGE_TYPE];
    __block BOOL isDir;
    __block BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:[fullPath stringByAppendingPathComponent:filename] isDirectory:&isDir];
    CGSize itemSize = CGSizeMake(40.0, 40.0);
    
    if (existed == YES) {
        UIImage *image = [UIImage imageWithContentsOfFile:[fullPath stringByAppendingPathComponent:filename]];
        cell.imageView.image = [UIImage imageWithImage:image scaledToSize:itemSize];
        return;
    }
     */
    CGSize itemSize = CGSizeMake(40.0, 40.0);
    NSString *url = [[NSString alloc] init];
    url = [[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_MEDIUM_HEAD_IMAGE_URL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSString *gender = [[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_GENDER];
    UIImage *headImage;
    if ([gender isEqualToString:@"m"]) {
        headImage = [UIImage imageNamed:@"defaultMaleHeadImage80.png"];
    } else {
        headImage = [UIImage imageNamed:@"defaultFemaleHeadImage80.png"];
    }

    __weak UIImageView *weakHeadImage = cell.imageView;
    [cell.imageView setImageWithURLRequest:(NSURLRequest *)request placeholderImage:(UIImage *)headImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        /*
        existed = [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
        if (!(isDir == YES && existed == YES)) {
            success = [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (success == NO) {
            NSLog(@"create Directory failed in Friends");
        }
        UIImage* newImage = [UIImage imageWithImage:image scaledToSize:itemSize];
        weakHeadImage.image = newImage;
        [UIImage saveImage:image withFileName:MEDIUM_HEAD_IMAGE_NAME ofType:IMAGE_TYPE inDirectory:fullPath];
         */
        UIImage* newImage = [UIImage imageWithImage:image scaledToSize:itemSize];
        weakHeadImage.image = newImage;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"operation: %@", request);
        NSLog(@"operation: %@", response);
        NSLog(@"Error: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    
}

- (void)agreeAddFriend:(UIButton *)button
{
    NSString *friendName = [[self.friendReqInfo objectAtIndex:button.tag] objectForKey:SERVER_USERNAME];
    NSString *addFriendsURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/friend.php"];
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSNumber *friendAction = [[NSNumber alloc] initWithInt:AGREE_FRIEND_REQUEST];
    NSDictionary *para = @{SERVER_USERNAME: username, SERVER_FRIEND_NAME:friendName, SERVER_FRIEND_ACTION:friendAction};
    NSLog(@"URL para = %@", para);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:addFriendsURL parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
        if ([self.strangerSet containsObject:indexPath] == YES) {
            [self.strangerSet removeObject:indexPath];
        }
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"请求发送失败"
                                           message:@"网络错误，请稍后再试"
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
        [alert show];
    }];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self deleteStrangersFromList:indexPath];
        [self.friendReqInfo removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Delete strangers from list

- (void)deleteStrangersFromList:(NSIndexPath *)indexPath
{
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [[NSString alloc] initWithString:[ud stringForKey:USERNAME]];
    NSString *strangerName = [[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_USERNAME];
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/delete_stranger.php"];
    NSDictionary *para = @{SERVER_USERNAME:username, SERVER_STRANGER_NAME:strangerName};
    NSLog(@"URL para = %@", para);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    VoteFriendsDetailsInfoTableViewController *voteFriendsDetailsVC = [segue destinationViewController];
    if ([self.strangerSet containsObject:indexPath]) {
        voteFriendsDetailsVC.isFriend = NO;
    } else {
        voteFriendsDetailsVC.isFriend = YES;
    }
    voteFriendsDetailsVC.username = [[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_USERNAME];
    voteFriendsDetailsVC.screenname = [[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_SCREENNAME];
    voteFriendsDetailsVC.gender = [[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_GENDER];
    voteFriendsDetailsVC.signature = [[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_USER_SIGNATURE];
    if ((NSNull *)voteFriendsDetailsVC.signature == [NSNull null]) {
        voteFriendsDetailsVC.signature = @"这家伙很懒，什么也没留下";
    }
    voteFriendsDetailsVC.originalHeadImageURL = [[self.friendReqInfo objectAtIndex:indexPath.row] objectForKey:SERVER_ORGINAL_HEAD_IMAGE_URL];
    
    //设置返回键的标题
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}


@end
