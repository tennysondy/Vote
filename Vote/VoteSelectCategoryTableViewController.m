//
//  VoteSelectCategoryTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-8-2.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteSelectCategoryTableViewController.h"
#import "VoteAddOptionsTableViewController.h"

@interface VoteSelectCategoryTableViewController ()

@property (strong, nonatomic) NSArray *sectionTitle;
@property (strong, nonatomic) NSArray *sectionContainer;

@end

@implementation VoteSelectCategoryTableViewController

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
    
    self.sectionTitle = [[NSArray alloc] initWithObjects:@"美食", @"聚会", @"娱乐", @"运动",@"旅游" , nil];
    NSArray *meal = [[NSArray alloc] initWithObjects:@"默认", @"吃个便饭", @"上档次", nil];
    NSArray *party = [[NSArray alloc] initWithObjects:@"默认", @"约会", @"小聚一下", @"生日聚会", @"团体聚会", nil];
    NSArray *entertainment = [[NSArray alloc] initWithObjects:@"默认", @"看电影", @"K歌", @"棋牌", @"游戏", nil];
    NSArray *sports = [[NSArray alloc] initWithObjects:@"默认", @"篮球", @"足球", @"羽毛球", @"徒步", @"跑步", @"桌球", @"瑜伽", @"游泳", @"网球", @"滑雪", @"自行车", @"跳舞", nil];
    NSArray *travel = [[NSArray alloc] initWithObjects:@"默认", @"城市周边", @"长途跋涉", nil];
    self.sectionContainer = [[NSArray alloc] initWithObjects:meal, party, entertainment, sports, travel, nil];
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
    return [self.sectionContainer count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.sectionContainer objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 35.0;
    }
    return 35.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 25.0)];
    //uv.layer.borderWidth = 1.0;
    //uv.layer.borderColor = [[UIColor blackColor] CGColor];
    uv.backgroundColor = UIColorFromRGB(0xEFEFF4);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10, 270, 15.0)];
    if (section == 0) {
        title.frame = CGRectMake(15.0, 10, 270, 15.0);
    }
    title.backgroundColor = [UIColor clearColor];
    title.text = [self.sectionTitle objectAtIndex:section];
    
    title.textColor = UIColorFromRGB(0x4C566C);
    title.font = [UIFont systemFontOfSize:14.0];
    [uv addSubview:title];
    
    return uv;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Category Name" forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.sectionContainer objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *category = [[self.sectionContainer objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([category isEqualToString:@"默认"]) {
        category = [self.sectionTitle objectAtIndex:indexPath.section];
    }
    [self.optionCategoryDelegate selectOptionCategory:category];
    
    NSArray *navArr = self.navigationController.viewControllers;
    for (UIViewController *nav in navArr)
    {
        if ([nav isKindOfClass:[VoteAddOptionsTableViewController class]])
        {
            [self.navigationController popToViewController:nav animated:YES];
        }
    }
    
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
