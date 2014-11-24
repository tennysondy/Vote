//
//  VoteCityTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-9-17.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CityCallBack)(NSString *city);

@interface VoteCityTableViewController : UITableViewController

@property (strong, nonatomic) CityCallBack changeCity;

@property (strong, nonatomic) NSString *identifier;

@end
