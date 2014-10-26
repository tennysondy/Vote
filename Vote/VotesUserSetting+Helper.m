//
//  VotesUserSetting+Helper.m
//  Vote
//
//  Created by 丁 一 on 14-8-26.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VotesUserSetting+Helper.h"
#import "CoreDataHelper.h"
#import "VotesInfo+VotesInfoHelper.h"

@implementation VotesUserSetting (Helper)

+ (VotesUserSetting *)fetchVoteUserSetting:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context
{
    
    VotesUserSetting *aVoteUserSetting = nil;
    
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(whichVote.voteID == %@) AND (username == %@)", voteId, username];
    NSArray *results = [CoreDataHelper searchObjectsForEntity:VOTES_USER_SETTING withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
    if ([results count] == 1) {
        aVoteUserSetting = [results firstObject];
        NSLog(@"Find a vote user setting in the database!");
    } else if ([results count] == 0){
        NSLog(@"No vote user setting found in the database!");
    } else {
        NSLog(@"Fetch vote user setting error in the database!");
    }
    
    return aVoteUserSetting;
}

+ (void)insertVoteUserSetting:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context notificationFlag:(BOOL)notificaition deleteForever:(BOOL)forever;
{
    VotesUserSetting *aVoteUserSetting = [NSEntityDescription insertNewObjectForEntityForName:VOTES_USER_SETTING inManagedObjectContext:context];
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    aVoteUserSetting.username = username;
    aVoteUserSetting.notification = [NSNumber numberWithBool:notificaition];
    aVoteUserSetting.deleteForever = [NSNumber numberWithBool:forever];
    aVoteUserSetting.whichVote = [VotesInfo fetchVotesWithVoteID:voteId withContext:context];
    
}

+ (void)modifyVoteUserSetting:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context notificationFlag:(BOOL)notification deleteForever:(BOOL)forever
{
    VotesUserSetting *aVoteUserSetting = [VotesUserSetting fetchVoteUserSetting:voteId withContext:context];
    aVoteUserSetting.notification = [NSNumber numberWithBool:notification];
    aVoteUserSetting.deleteForever = [NSNumber numberWithBool:forever];
    
}

+ (void)modifyVoteUserSettingNotificationFlag:(BOOL)notification withVoteId:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context
{
    VotesUserSetting *aVoteUserSetting = [VotesUserSetting fetchVoteUserSetting:voteId withContext:context];
    aVoteUserSetting.notification = [NSNumber numberWithBool:notification];
}

+ (void)modifyVoteUserSettingDeleteForeverFlag:(BOOL)forever withVoteId:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context
{
    VotesUserSetting *aVoteUserSetting = [VotesUserSetting fetchVoteUserSetting:voteId withContext:context];
    aVoteUserSetting.deleteForever = [NSNumber numberWithBool:forever];
}

+ (void)deleteVoteUserSetting:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context
{
    VotesUserSetting *aVoteUserSetting = [VotesUserSetting fetchVoteUserSetting:voteId withContext:context];
    [context deleteObject:aVoteUserSetting];
}

@end
