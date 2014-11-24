//
//  VoteCityTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-9-17.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteCityTableViewController.h"
#import "VoteSetUserInfoTableViewController.h"

@interface VoteCityTableViewController ()

@property (nonatomic, strong) NSMutableArray *totalCities;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSMutableArray *sectionA;
@property (nonatomic, strong) NSMutableArray *sectionB;
@property (nonatomic, strong) NSMutableArray *sectionC;
@property (nonatomic, strong) NSMutableArray *sectionD;
@property (nonatomic, strong) NSMutableArray *sectionE;
@property (nonatomic, strong) NSMutableArray *sectionF;
@property (nonatomic, strong) NSMutableArray *sectionG;
@property (nonatomic, strong) NSMutableArray *sectionH;
@property (nonatomic, strong) NSMutableArray *sectionI;
@property (nonatomic, strong) NSMutableArray *sectionJ;
@property (nonatomic, strong) NSMutableArray *sectionK;
@property (nonatomic, strong) NSMutableArray *sectionL;
@property (nonatomic, strong) NSMutableArray *sectionM;
@property (nonatomic, strong) NSMutableArray *sectionN;
@property (nonatomic, strong) NSMutableArray *sectionO;
@property (nonatomic, strong) NSMutableArray *sectionP;
@property (nonatomic, strong) NSMutableArray *sectionQ;
@property (nonatomic, strong) NSMutableArray *sectionR;
@property (nonatomic, strong) NSMutableArray *sectionS;
@property (nonatomic, strong) NSMutableArray *sectionT;
@property (nonatomic, strong) NSMutableArray *sectionU;
@property (nonatomic, strong) NSMutableArray *sectionV;
@property (nonatomic, strong) NSMutableArray *sectionW;
@property (nonatomic, strong) NSMutableArray *sectionX;
@property (nonatomic, strong) NSMutableArray *sectionY;
@property (nonatomic, strong) NSMutableArray *sectionZ;

@end

@implementation VoteCityTableViewController

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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.sectionA = [[NSMutableArray alloc] initWithObjects:@"鞍山", nil];
    self.sectionB = [[NSMutableArray alloc] initWithObjects:@"保定", @"宝鸡", @"包头", @"北海", @"北京", @"本溪", nil];
    self.sectionC = [[NSMutableArray alloc] initWithObjects:@"沧州", @"长治", @"长春", @"长沙", @"常州", @"潮州",@"承德", @"成都", @"赤峰", nil];
    self.sectionD = [[NSMutableArray alloc] initWithObjects:@"大连", @"大庆", @"大同", @"丹东", @"德州", @"东莞", nil];
    self.sectionE = [[NSMutableArray alloc] initWithObjects:@"鄂尔多斯", nil];
    self.sectionF = [[NSMutableArray alloc] initWithObjects:@"佛山", @"抚顺", @"阜新", @"福州", nil];
    self.sectionG = [[NSMutableArray alloc] initWithObjects:@"广州", @"桂林", @"贵阳", nil];
    self.sectionH = [[NSMutableArray alloc] initWithObjects:@"哈尔滨", @"海口", @"邯郸", @"汉中", @"杭州", @"合肥", @"衡水", @"衡阳", @"红河", @"呼和浩特", @"葫芦岛", @"呼伦贝尔", @"湖州", @"淮安", @"黄山", @"黄石", nil];
    self.sectionJ = [[NSMutableArray alloc] initWithObjects:@"吉林", @"济南", @"嘉兴", @"嘉峪关", @"晋城", @"晋中", @"锦州", @"荆州", @"景德镇", @"九江", nil];
    self.sectionK = [[NSMutableArray alloc] initWithObjects:@"开封", @"昆明", nil];
    self.sectionL = [[NSMutableArray alloc] initWithObjects:@"拉萨", @"兰州", @"廊坊", @"乐山", @"丽江",@"连云港", @"辽阳", @"临汾", @"六盘水", @"洛阳", @"吕梁", nil];
    self.sectionM = [[NSMutableArray alloc] initWithObjects:@"绵阳", nil];
    self.sectionN = [[NSMutableArray alloc] initWithObjects:@"南昌", @"南京", @"南宁", @"南通", @"南阳", @"宁波", nil];
    self.sectionP = [[NSMutableArray alloc] initWithObjects:@"盘锦", @"攀枝花", @"普洱", nil];
    self.sectionQ = [[NSMutableArray alloc] initWithObjects:@"齐齐哈尔", @"秦皇岛", @"青岛", nil];
    self.sectionS = [[NSMutableArray alloc] initWithObjects:@"三亚", @"汕头", @"上海", @"绍兴", @"沈阳", @"深圳", @"石家庄", @"朔州", @"苏州", nil];
    self.sectionT = [[NSMutableArray alloc] initWithObjects:@"太原", @"台州", @"泰州", @"唐山", @"天津", @"铁岭", @"通辽", @"吐鲁番", nil];
    self.sectionW = [[NSMutableArray alloc] initWithObjects:@"威海", @"温州", @"乌海", @"乌鲁木齐", @"武汉", @"无锡", nil];
    self.sectionX = [[NSMutableArray alloc] initWithObjects:@"西安", @"西宁", @"西双版纳", @"厦门", @"咸阳", @"湘潭", @"襄阳", @"忻州", @"邢台", @"许昌", @"徐州", nil];
    self.sectionY = [[NSMutableArray alloc] initWithObjects:@"延安", @"烟台", @"阳泉", @"扬州", @"宜昌", @"宜春", @"银川", @"营口", @"榆林", @"岳阳", @"运城", nil];
    self.sectionZ = [[NSMutableArray alloc] initWithObjects:@"张家界", @"张家口", @"镇江", @"郑州", @"中山", @"舟山", @"珠海", @"遵义", nil];
    self.totalCities = [[NSMutableArray alloc] initWithObjects:self.sectionA, self.sectionB, self.sectionC, self.sectionD, self.sectionE, self.sectionF, self.sectionG, self.sectionH, self.sectionJ, self.sectionK, self.sectionL, self.sectionM, self.sectionN, self.sectionP, self.sectionQ, self.sectionS, self.sectionT, self.sectionW, self.sectionX, self.sectionY, self.sectionZ, nil];
    
    self.sectionTitles = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"J", @"K", @"L", @"M", @"N", @"P", @"Q", @"S", @"T", @"W", @"X", @"Y", @"Z", nil];
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
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
    return [self.totalCities count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.totalCities objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionTitles objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionTitles;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"City" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[self.totalCities objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.changeCity) {
        NSString *city = [[self.totalCities objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        self.changeCity(city);
        if ([self.identifier isEqualToString:@"User Change City"]) {
            NSArray *navArr = self.navigationController.viewControllers;
            for (UIViewController *nav in navArr)
            {
                if ([nav isKindOfClass:[VoteSetUserInfoTableViewController class]])
                {
                    [self.navigationController popToViewController:nav animated:YES];
                    break;
                }
            }
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
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
