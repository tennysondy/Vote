//
//  VoteAppDelegate.m
//  Vote
//
//  Created by 丁 一 on 14-2-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteAppDelegate.h"
#import "CoreDataHelper.h"
#import "VoteHomeViewController.h"
#import "VoteFirstTableViewController.h"
#import "AFHTTPRequestOperationManager.h"

@implementation VoteAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //IOS 8 推送申请
    if (SYSTEM_VERSION >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    // Override point for customization after application launch.

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if (launchOptions != nil) {
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSLog(@"Launched from push notification: %@", userInfo);
        if ( userInfo != nil )
        {
            [self application:application handleRemoteNotification:userInfo updateUI:NO];
        }

    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    VoteHomeViewController *rootVC = (VoteHomeViewController *)self.window.rootViewController;
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    BOOL authenticated = [ud boolForKey:SERVER_AUTHENTICATED];
    if (authenticated) {
        if ([rootVC.uTimer isValid]) {
            [rootVC pauseTimer];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    BOOL authenticated = [ud boolForKey:SERVER_AUTHENTICATED];
    VoteHomeViewController *rootVC = (VoteHomeViewController *)self.window.rootViewController;
    if (authenticated) {
        [self getUnreadMsg];
        if ([rootVC.uTimer isValid]) {
            [rootVC resumeTimer];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //删除定位时间戳
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:CITY_UPDATE_TIMESTAMP];
    [ud synchronize];
}

//IOS 8 注册远程通知服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

//处理自定义通知
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    NSString *deviceTokenStr = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@", deviceTokenStr);
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:deviceTokenStr forKey:DEVICE_TOKEN];
    [ud synchronize];
}

//处理通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Received remote notification: %@", userInfo);
    [self getUnreadMsg];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application handleRemoteNotification:(NSDictionary *)userInfo updateUI:(BOOL)updateUI
{
    NSLog(@"Received notification: %@", userInfo);
    if (updateUI) {
        NSDictionary *aps = [userInfo objectForKey:@"aps"];
        NSString *prompt = [[aps objectForKey:@"alert"] objectForKey:@"loc-key"];
        NSNumber *badge = [aps objectForKey:@"badge"];
        VoteHomeViewController *rootVC = (VoteHomeViewController *)self.window.rootViewController;
        if ([prompt isEqualToString:SERVER_ADD_FRIEND_REQ] || [prompt isEqualToString:SERVER_AGREE_FRIEND_RESP] || [prompt isEqualToString:SERVER_REFUSE_FRIEND_RESP]) {
            [[[[rootVC viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:[badge stringValue]];
        }
    } else {
        
    }

}

//收取当前用户的未读信息个数
- (void)getUnreadMsg
{
    //设置提示信息
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_badge.php"];
    NSDictionary *para = @{SERVER_USERNAME:username};
    NSLog(@"URL para = %@", para);
    VoteHomeViewController *rootVC = (VoteHomeViewController *)self.window.rootViewController;
    VoteFirstTableViewController *ftvc = [[[[rootVC viewControllers] objectAtIndex:0] viewControllers] firstObject];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        NSNumber *usrVoteBadgeNum = [[NSNumber alloc] init];
        usrVoteBadgeNum = [responseObject objectForKey:SERVER_USR_VOTE_BADGE_NUM];
        NSNumber *friendsBadgeNum = [[NSNumber alloc] init];
        friendsBadgeNum = [responseObject objectForKey:SERVER_FRIEND_BADGE_NUM];
        if ([[usrVoteBadgeNum stringValue] isEqualToString:@"0"]) {
            [[[[rootVC viewControllers] objectAtIndex:0] tabBarItem] setBadgeValue:nil];
        } else {
            [[[[rootVC viewControllers] objectAtIndex:0] tabBarItem] setBadgeValue:[usrVoteBadgeNum stringValue]];
            [ud setBool:YES forKey:FTVC_LOADING_VIEW_FLAG];
            [ud synchronize];
            if (ftvc.view.window != nil) {
                [ftvc fetchVotesInfoListFromServer];
            }
        }
        if ([[friendsBadgeNum stringValue] isEqualToString:@"0"]) {
            [[[[rootVC viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:nil];
        } else {
            [[[[rootVC viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:[friendsBadgeNum stringValue]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
    }];
    
}

@end
