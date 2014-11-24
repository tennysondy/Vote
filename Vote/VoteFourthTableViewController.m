//
//  VoteFourthTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-8-29.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import "VoteFourthTableViewController.h"
#import "VoteLoginViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface VoteFourthTableViewController ()

@end

@implementation VoteFourthTableViewController

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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     static NSString *CellIdentifier = @"Personal Setting";
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //添加cell间的分割线
    while ([[cell.contentView subviews] lastObject] != nil) {
        [[[cell.contentView subviews] lastObject] removeFromSuperview];
    }
     cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
     switch (indexPath.row) {
         case 0:
             cell.textLabel.text = @"个人信息";
             cell.imageView.image = [UIImage imageNamed:@"personalInfo.png"];
             break;
         case 1:
             cell.textLabel.text = @"问题反馈";
             cell.imageView.image = [UIImage imageNamed:@"feedback.png"];
             break;
         case 2:
             cell.textLabel.text = @"找乐儿印象";
             cell.imageView.image = [UIImage imageNamed:@"rate.png"];
             break;
         case 3:
             cell.textLabel.text = @"新版本检测";
             cell.imageView.image = [UIImage imageNamed:@"newVersion.png"];
             break;
         case 4:
             cell.textLabel.text = @"关于找乐儿";
             cell.imageView.image = [UIImage imageNamed:@"about.png"];
             break;
         default:
             break;
     }
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(49.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
    v.backgroundColor = SEPARATOR_COLOR;
    [cell.contentView addSubview:v];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"modify personal info" sender:self];
    } else if (indexPath.row == 1) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        [mail.navigationBar setTintColor:[UIColor whiteColor]];
        
         mail.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self;
        [mail setSubject:@"意见反馈"];
        [mail setToRecipients:@[@"whereisfun@163.com"]];
        
        [self presentViewController:mail animated:YES completion:^{

        }];
    } else if (indexPath.row == 2) {
        NSString *str = [NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@",  @"926964742"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    } else if (indexPath.row == 3) {
        NSString *str = [NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@",  @"926964742"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    } else if (indexPath.row == 4) {
        [self performSegueWithIdentifier:@"about" sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//发送邮件的回调函数
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result){
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled…");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved…");
            break;
        case MFMailComposeResultSent:
        {
            NSLog(@"Mail sent…");
            break;
        }
        case MFMailComposeResultFailed:
        {
            NSLog(@"Mail send errored: %@…", [error localizedDescription]);
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    if ([segue.identifier isEqualToString:@"about"]) {
        
    }
    //设置返回键的标题
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}


@end
