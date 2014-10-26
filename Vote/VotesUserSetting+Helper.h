//
//  VotesUserSetting+Helper.h
//  Vote
//
//  Created by 丁 一 on 14-8-26.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VotesUserSetting.h"

@interface VotesUserSetting (Helper)

+ (VotesUserSetting *)fetchVoteUserSetting:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context;

+ (void)insertVoteUserSetting:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context notificationFlag:(BOOL)notice deleteForever:(BOOL)forever;

+ (void)modifyVoteUserSetting:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context notificationFlag:(BOOL)notification deleteForever:(BOOL)forever;

+ (void)modifyVoteUserSettingNotificationFlag:(BOOL)notification withVoteId:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context;

+ (void)modifyVoteUserSettingDeleteForeverFlag:(BOOL)forever withVoteId:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context;

+ (void)deleteVoteUserSetting:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context;

@end
