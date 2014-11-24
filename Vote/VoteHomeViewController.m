//
//  VoteHomeViewController.m
//  Vote
//
//  Created by 丁 一 on 14-2-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "VoteHomeViewController.h"
#import "VoteLoginViewController.h"
#import "CoreDataHelper.h"
#import "VoteFirstTableViewController.h"
#import "VoteSecondTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Users+UsersHelper.h"
#import "UIImage+UIImageHelper.h"
#import "City.h"

@interface VoteHomeViewController ()<CLLocationManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSString *curCity;

@end

@implementation VoteHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //更改tabbar样式
    //tabbar image color 8e8e8e, selected image color 27aae1(蓝)/7D4EFF(紫)
    [[UITabBar appearance] setBarTintColor:UIColorFromRGB(0xF7F7F7)];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Medium" size:10.0f], NSForegroundColorAttributeName:UIColorFromRGB(0x8E8E8E)} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Medium" size:10.0f], NSForegroundColorAttributeName:UIColorFromRGB(0x7D4EFF)} forState:UIControlStateSelected];
    UITabBarItem *item;
    NSArray *imageArray = [[NSArray alloc] initWithObjects:@"first.png", @"second.png", @"third.png", @"fourth.png", nil];
    NSArray *textArray = [[NSArray alloc] initWithObjects:@"首页", @"通讯录", @"热门", @"设置", nil];
    NSArray *selectedImageArray = [[NSArray alloc] initWithObjects:@"selectedFirst.png", @"selectedSecond.png", @"selectedThird.png", @"selectedFourth.png", nil];
    
    for (int i = 0; i < [imageArray count]; i++)
    {
        item = [self.tabBar.items objectAtIndex:i];
        NSString *imageName = [[NSString alloc] initWithString:[imageArray objectAtIndex:i]];
        NSString *selectedImageName = [[NSString alloc] initWithString:[selectedImageArray objectAtIndex:i]];
        item.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.title = [textArray objectAtIndex:i];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:19.0f]}];
    //UIImage *image = [UIImage imageNamed:@"green-menu-bar.png"];
    //[[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setBackgroundColor:UIColorFromRGB(0xEE0000)];
    //1D66F1 1744BD 325BCA 399FDF 257CD3 267CD3 1981ea
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x000000)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:17.0f]} forState:UIControlStateNormal];
    [self loadCookies];
    
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *city = [ud stringForKey:SERVER_CITY];
    if (city == nil) {
        city = @"北京";
        [ud setObject:city forKey:SERVER_CITY];
        [ud synchronize];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    authenticated = [ud boolForKey:SERVER_AUTHENTICATED];
    if ([ud boolForKey:SIGN_IN_FLAG] == NO) {
        [ud setBool:YES forKey:SIGN_IN_FLAG];
        //用户退出后，回到第一个tab界面
        [self setSelectedIndex:0];
    }
    //authenticated = YES;
    //增加一个覆盖view，让tabbarview不可见
    if (authenticated == NO) {
        CGRect rect = [[UIScreen mainScreen] bounds];
        UIImageView *uv = [[UIImageView alloc] initWithFrame:rect];
        uv.image = [UIImage imageNamed:@"launchImage.png"];
        uv.tag = HVC_PRELOAD_VIEW_TAG;
        uv.backgroundColor = [UIColor blackColor];
        [self.view addSubview:uv];
    } else {
        if ([self.view viewWithTag:HVC_PRELOAD_VIEW_TAG] != nil) {
            [[self.view viewWithTag:HVC_PRELOAD_VIEW_TAG] removeFromSuperview];
        }
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    authenticated = [ud boolForKey:SERVER_AUTHENTICATED];
    if (authenticated == YES) {
        //清除badge number
        NSLog(@"authen=%d", authenticated);
        [self setupTimerForLocationUpdate];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VoteLoginViewController *lvc=[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [lvc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [lvc setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:lvc animated:YES completion:nil];
    }
    
}

#pragma mark - Location update timer

- (void)setupTimerForLocationUpdate
{
    if (self.uTimer == nil) {
        self.uTimer = [NSTimer timerWithTimeInterval:180.0f target:self selector:@selector(setupLocationManager) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.uTimer forMode:NSRunLoopCommonModes];
    }

    [self.uTimer fire];
}

- (void)pauseTimer
{
    if (![self.uTimer isValid]) {
        return;
    }
    [self.uTimer setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer
{
    if (![self.uTimer isValid]) {
        return;
    }
    [self.uTimer setFireDate:[NSDate date]];
}

#pragma mark - CLLocationManagerDelegate

- (void)setupLocationManager
{
    if ([CLLocationManager locationServicesEnabled] == NO || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"user doesn't enable the location service!");
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"无法使用定位服务" message:@"请在手机[设置]->[隐私]->[定位服务]中打开并允许找乐儿使用定位服务，当前默认所在城市为北京，如不相同，请在[设置]->[个人信息]中手动修改" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        //更新间隔为5分钟
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSDate *lastCheck = [ud objectForKey:LOCATION_SERVICE_CHECK_TIMESTAMP];
        if (lastCheck == nil) {
            [av show];
            [ud setObject:[NSDate date] forKey:LOCATION_SERVICE_CHECK_TIMESTAMP];
            [ud synchronize];
        } else {
            NSTimeInterval sec = [lastCheck timeIntervalSinceNow];
            if (fabs(sec) > 600.0) {
                [av show];
                [ud setObject:[NSDate date] forKey:LOCATION_SERVICE_CHECK_TIMESTAMP];
                [ud synchronize];
            } else {
                
            }
        }
        return;
    }
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 100.0;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.currentLocation = [[CLLocation alloc] init];
    }
    if (self.locationManager != nil) {
        /*
        NSOperatingSystemVersion ios8_1_0 = (NSOperatingSystemVersion){8, 1, 0};
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios8_1_0]) {
        }
         */
        //IOS 8 新增权限申请
        if (SYSTEM_VERSION >= 8.0) {
            [self.locationManager requestWhenInUseAuthorization];
            //[self.locationManager requestAlwaysAuthorization];
        }
        
        //更新间隔为5分钟
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSDate *lastUpdate = [ud objectForKey:CITY_UPDATE_TIMESTAMP];
        if (lastUpdate == nil) {
            [self.locationManager startUpdatingLocation];
        } else {
            NSTimeInterval sec = [lastUpdate timeIntervalSinceNow];
            if (fabs(sec) > 600.0) {
                [self.locationManager startUpdatingLocation];
            } else {
                
            }
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
    NSLog(@"current location: %@", self.currentLocation);
    //CLLocation *tmpLoc = [[CLLocation alloc] initWithLatitude:43.37 longitude:122.15];
    self.geoCoder = [[CLGeocoder alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.geoCoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            //获取成功，停止定位
            [weakSelf.locationManager stopUpdatingLocation];
            //更新间隔至少为5分钟
            NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
            NSDate *lastUpdate = [ud objectForKey:CITY_UPDATE_TIMESTAMP];
            if (lastUpdate == nil) {
                [ud setObject:[NSDate date] forKey:CITY_UPDATE_TIMESTAMP];
                [ud synchronize];
            } else {
                NSTimeInterval sec = [lastUpdate timeIntervalSinceNow];
                if (fabs(sec) > 600.0) {
                    [ud setObject:[NSDate date] forKey:CITY_UPDATE_TIMESTAMP];
                    [ud synchronize];
                } else {
                    return;
                }
            }
            //位置信息
            CLPlacemark *placeMark = [placemarks objectAtIndex:0];
            NSString *country = placeMark.ISOcountryCode;
            NSString *province = placeMark.administrativeArea;
            NSString *city = placeMark.locality;
            //IOS 8 修改了直辖市字段
            if (SYSTEM_VERSION >= 8.0) {
                NSArray *array = [NSArray arrayWithObjects:@"北京", @"上海", @"天津", @"重庆", nil];
                for (NSString *str in array) {
                    if ([province rangeOfString:str].location != NSNotFound) {
                        city = province;
                        break;
                    }
                }
            } else {
                if (city == nil) {
                    city = placeMark.administrativeArea;
                }
            }
            //NSLog(@"%@", placemarks);
            NSLog(@"%@--%@--%@", country, placeMark.administrativeArea, city);
            //获取系统当前语言
            NSArray *languages = [NSLocale preferredLanguages];
            NSString *currentLanguage = [languages objectAtIndex:0];
            NSLog( @"%@" , currentLanguage);
            if ([currentLanguage isEqualToString:@"zh-Hans"] == NO) {
                City *tmp = [[City alloc] init];
                id value = [tmp.cityMap objectForKey:city];
                if ([value isKindOfClass:[NSString class]]) {
                    weakSelf.curCity = value;
                } else {
                    //通过省份排除掉拼音相同的城市
                    weakSelf.curCity = [value objectForKey:placeMark.administrativeArea];
                }
            } else {
                //如果系统语言是中文，则去掉“市”字
                weakSelf.curCity = [city substringToIndex:city.length-1];
            }
            NSLog(@"city::%@", weakSelf.curCity);
            NSString *preCity = [ud stringForKey:SERVER_CITY];
            if ([weakSelf.curCity isEqualToString:preCity] == NO) {
                NSString *msg = [NSString stringWithFormat:@"系统定位您在%@，是否切换？", weakSelf.curCity];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:weakSelf cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"get location failed, error msg:%@", error);
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    [ud setObject:self.curCity forKey:SERVER_CITY];
    [ud synchronize];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"所在城市已更新，如有错误，请在[设置]->[个人信息]中手动修改" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [av show];
}

#pragma mark - Cookies

- (void)loadCookies{
    
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
    if ([cookies count] == 0) {
        return;
    }
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies){
        [cookieStorage setCookie: cookie];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
