//
//  VotesUserSetting.h
//  Vote
//
//  Created by 丁 一 on 14-8-25.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VotesInfo;

@interface VotesUserSetting : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * deleteForever;
@property (nonatomic, retain) NSNumber * notification;
@property (nonatomic, retain) VotesInfo *whichVote;

@end
