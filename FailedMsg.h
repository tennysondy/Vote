//
//  FailedMsg.h
//  Vote
//
//  Created by 丁 一 on 14-8-25.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Users;

@interface FailedMsg : NSManagedObject

@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSString * method;
@property (nonatomic, retain) NSDictionary * parameters;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Users *whoseFailedMsg;

@end
