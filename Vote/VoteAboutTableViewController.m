//
//  VoteAboutTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-9-29.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteAboutTableViewController.h"

@interface VoteAboutTableViewController ()

@end

@implementation VoteAboutTableViewController

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
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIImageView *imageView;
    if (iPhone5) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 640, 1136)];
        imageView.image = [UIImage imageNamed:@"aboutBg5S.png"];
    } else {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 640, 960)];
        imageView.image = [UIImage imageNamed:@"aboutBg.png"];
    }
    
    [self.tableView setBackgroundView:imageView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 180.0;
    } else {
        return 35.0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Logo" forIndexPath:indexPath];
        CGRect rect = [UIScreen mainScreen].bounds;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(rect.size.width/2-50, 20.0, 100.0, 100.0)];
        imageView.image = [UIImage imageNamed:@"aboutLogo.png"];
        imageView.layer.cornerRadius = 6.0;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(rect.size.width/2-130, 125, 260, 20)];
        label.text = @"找乐儿 WhereIsFun 1.0";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:20.0];
        [cell.contentView addSubview:label];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
    } else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, 280, 35)];
        textView.text = @"官方微博: http://weibo.com/whereisfun";
        textView.textColor = [UIColor blackColor];
        textView.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        textView.scrollEnabled = NO;
        textView.editable = NO;
        textView.textAlignment = NSTextAlignmentLeft;
        textView.dataDetectorTypes = UIDataDetectorTypeAll;
        [cell.contentView addSubview:textView];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
        textView.backgroundColor = [UIColor clearColor];
    } else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, 280, 35)];
        textView.text = @"官方邮箱: whereisfun@163.com";
        textView.textColor = [UIColor blackColor];
        textView.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        textView.scrollEnabled = NO;
        textView.editable = NO;
        textView.textAlignment = NSTextAlignmentLeft;
        textView.dataDetectorTypes = UIDataDetectorTypeAll;
        [cell.contentView addSubview:textView];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
        textView.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
