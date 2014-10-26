//
//  VoteAddActivityImageTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-8-11.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteAddActivityImageTableViewController.h"
#import "UIImage+UIImageHelper.h"
#import "VoteCreateActivityTableViewController.h"

@interface VoteAddActivityImageTableViewController ()

@property (strong, nonatomic) NSArray *sectionTitle;
@property (strong, nonatomic) NSArray *sectionContainer;

@property (strong, nonatomic) NSArray *imageContainer;

@end

@implementation VoteAddActivityImageTableViewController

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
    
    //self.sectionTitle = [[NSArray alloc] initWithObjects:@"聚会", @"饭团", @"休闲娱乐", @"运动健身", @"旅游" , nil];
    self.sectionTitle = [[NSArray alloc] initWithObjects:@"美食", @"聚会", @"娱乐", @"运动", nil];
    //NSArray *party = [[NSArray alloc] initWithObjects:@"小聚一下", @"生日聚会", @"好久不见", @"不醉不归", nil];
    NSArray *party = [[NSArray alloc] initWithObjects:@"约会", @"小聚一下", @"生日聚会", @"团体聚会", nil];
    NSArray *partyImages = [[NSArray alloc] initWithObjects:@"dating.png", @"chat.png", @"birthday.png", @"BigParty.png", nil];
    NSArray *meal = [[NSArray alloc] initWithObjects:@"吃个便饭", @"大宰一顿", nil];
    NSArray *mealImages = [[NSArray alloc] initWithObjects:@"rice.png", @"chicken.png", nil];
    //NSArray *entertainment = [[NSArray alloc] initWithObjects:@"约会", @"看电影", @"棋牌", @"K歌", @"游戏", nil];
    NSArray *entertainment = [[NSArray alloc] initWithObjects:@"看电影", @"K歌",@"棋牌", @"游戏", nil];
    NSArray *entertainmentImages = [[NSArray alloc] initWithObjects:@"film.png", @"ktv.png", @"cards.png", @"egame.png", nil];
    NSArray *sports = [[NSArray alloc] initWithObjects:@"运动", @"篮球", @"足球", @"羽毛球", @"徒步", @"跑步", @"桌球", @"瑜伽", @"游泳", @"网球", @"滑雪", @"自行车", @"跳舞", nil];
    NSArray *sportsImages = [[NSArray alloc] initWithObjects:@"sports.png", @"basketball.png", @"soccer.png", @"badminton.png", @"trekking.png", @"running.png", @"snooker.png", @"yoga.png", @"swimming.png", @"tennis.png", @"skiing.png", @"bike.png", @"dancing.png", nil];
    //NSArray *travel = [[NSArray alloc] initWithObjects:@"城市周边", @"长途跋涉", nil];
    self.sectionContainer = [[NSArray alloc] initWithObjects:meal, party, entertainment, sports, nil];
    self.imageContainer = [[NSArray alloc] initWithObjects:mealImages, partyImages, entertainmentImages, sportsImages, nil];
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
    title.font = [UIFont boldSystemFontOfSize:14.0];
    [uv addSubview:title];
    
    return uv;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Activity Image" forIndexPath:indexPath];
    
    // Configure the cell...
    //UIImage *image = [UIImage imageNamed:@"sports.png"];
    //CGSize itemSize = CGSizeMake(30.0, 30.0);
    //cell.imageView.image = [UIImage imageWithImage:image scaledToSize:itemSize];
    NSString *imageName = [[self.imageContainer objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.imageView.layer.cornerRadius = 6.0f;
    cell.imageView.clipsToBounds = YES;
    cell.textLabel.text = [[self.sectionContainer objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageName = [[self.imageContainer objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSDictionary *imageAttr = @{@"name":imageName, @"text":[[self.sectionContainer objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]};
    if (self.activityImgName) {
        self.activityImgName(imageAttr);
    }
    NSArray *navArr = self.navigationController.viewControllers;
    for (UIViewController *nav in navArr)
    {
        if ([nav isKindOfClass:[VoteCreateActivityTableViewController class]])
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
